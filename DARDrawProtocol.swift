//
//  DARDrawProtocol.swift
//  DARGraphDrawer
//
//  Created by Alessio Roberto on 26/08/15.
//  Copyright © 2015 Alessio Roberto. All rights reserved.
//

import UIKit

/// Color management of the curves in the graph.
struct Colors {
    enum Color: Int {
        case ColorOne   = 0xdd2d2d
        case ColorTwo   = 0x31b033
        case ColorThree = 0x3331b0
        case ColorFour  = 0xb031ae
        case ColorFive  = 0xfc6c2d
    }
    
    let colors = [
        UIColor(hex: Color.ColorOne.rawValue, alpha:1),
        UIColor(hex: Color.ColorTwo.rawValue, alpha:1),
        UIColor(hex: Color.ColorThree.rawValue, alpha:1),
        UIColor(hex: Color.ColorFour.rawValue, alpha:1),
        UIColor(hex: Color.ColorFive.rawValue, alpha:1)
    ]
}

//MARK: - Main struct
/// Graph management
struct Graph {
    /// Return X axix point according to graph view size and graph margin
    func getColumnXPoint(points: [Double], column:Int) -> CGFloat {
        //Calculate gap between points
        let spacer = (width - margin * 2 - 4) /
            CGFloat((points.count - 1))
        var x:CGFloat = CGFloat(column) * spacer
        x += self.margin + 2
        return x
    }
    
    /// Return Y point according to view size and graph margin
    func getColumnYPoint(graphPoint:CGFloat) -> CGFloat {
        let graphHeight = height - topBorder - bottomBorder
        var y:CGFloat = CGFloat(graphPoint) /
            CGFloat(maxValue) * graphHeight
        y = graphHeight + topBorder - y // Flip the graph
        return y
    }
    
    var width: CGFloat
    var height: CGFloat
    
    var margin: CGFloat
    var topBorder: CGFloat
    var bottomBorder: CGFloat
    var maxValue: Double
}

extension Graph {
    /**
    Draws a dash line.
    
    :param: startPoint The start point of the line
    :param: endPoint   The end point of the line
    :param: color      The color of the line
    */
    func drawDashLine(startPoint: CGPoint, endPoint: CGPoint, color: UIColor) {
        let linePath = UIBezierPath()
        
        let line = Line(startPoint: startPoint, endPoint: endPoint, color: color)
        let diagram = Diagram(elements: [line])
        
        diagram.draw(linePath)
        
        let pattern: [CGFloat] = [5.0, 5.0]
        linePath.setLineDash(pattern, count: 2, phase: 0)
        
        linePath.lineWidth = 1.5
        linePath.stroke()
    }
    
    /**
    Draws a list of lines/curves using, for each line a standard color from Colors.
    
    :param: graphs An array of [Double]
    */
    func drawColoredMultiLines(graphs:[[Double]]) {
        var i = 0
        _ = graphs.map{drawColoredSingleLine($0, color: Colors().colors[i++])}
    }
    
    /**
    Draws a single line.
    
    :param: points The points of the line
    :param: color  The color of the line
    */
    func drawColoredSingleLine(points: [Double], color: UIColor) {
        let linePath = UIBezierPath()
        
        var cgpoints = [CGPoint]()
        
        //go to start of line
        let yp = CGFloat(points[0])
        let startPoint = CGPoint(x:getColumnXPoint(points, column: 0),
            y:getColumnYPoint(log10(yp)))
        
        cgpoints.append(startPoint)
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        _ = (1 ..< points.count).map({
            let yp = CGFloat(points[$0])
            
            let nextPoint = CGPoint(x:getColumnXPoint(points, column: $0),
                y:getColumnYPoint(log10(yp)))
            
            cgpoints.append(nextPoint)
        })
        
        let curve = Curve(corners: cgpoints, color: color)
        let diagram = Diagram(elements: [curve])
        diagram.draw(linePath)
        
        linePath.lineWidth = 1.5
        linePath.stroke()
    }
    
    /**
    Draws two circles on start and end of a line
    */
    func drawCirclesStartEnd(startPoint: CGPoint, endPoint: CGPoint) {
        var sPoint = startPoint
        sPoint.x -= 5.0/2
        sPoint.y -= 5.0/2
        
        var ePoint = endPoint
        ePoint.x -= 5.0/2
        ePoint.y -= 5.0/2
        
        let diagram = Diagram(elements: [
                Circle(origin: sPoint, diameter: 7.0, color: UIColor(hex: Colors.Color.ColorOne.rawValue, alpha: 1.0)),
                Circle(origin: endPoint, diameter: 7.0, color: UIColor(hex: Colors.Color.ColorOne.rawValue, alpha: 1.0))
            ])
        diagram.draw(UIBezierPath())
    }
}

extension Graph {
    /**
    Create an UILabel respect a CGPoint
    
    :param: center  The center of the UILabel
    :param: value   The text of the UILabel
    
    :returns: tag   The UILabel
    */
    func drawGraphLineLabels(center: CGPoint, value: String) -> UILabel {
        let tag = UILabel(frame: CGRectMake(0, 0, 50, 18))
        tag.text = value
        tag.textColor = UIColor.whiteColor()
        tag.textAlignment = NSTextAlignment.Center
        tag.font = UIFont.boldSystemFontOfSize(12)
        tag.center = center
        return tag
    }
    
    /**
    Draws background of the graph with a gradient
    
    :param: startColor  The start color of the gradient
    :param: endColor    The last color of the gradient
    */
    func drawGradient(startColor: CGColor, endColor: CGColor) {
        //get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor, endColor]
        
        //set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //create the gradient
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        //draw the gradient
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:height)
        CGContextDrawLinearGradient(context,
            gradient,
            startPoint,
            endPoint,
            CGGradientDrawingOptions.DrawsBeforeStartLocation)
    }
}

/// Instances of conforming types can rappresent data with graph
protocol Renderer {
    /// Moves the pen to `position` without drawing anything.
    func moveTo(position: CGPoint)
    
    /// Draws a line from the pen's current position to `position`, updating
    /// the pen position.
    func lineTo(position: CGPoint)
}

protocol Drawable {
    /// Issues drawing commands to `renderer` to represent `self`.
    func draw(renderer: Renderer?)
}

struct Line : Drawable {
    func draw(renderer: Renderer?) {
        guard let rend = renderer else { return }
        
        rend.moveTo(startPoint)
        rend.lineTo(endPoint)
        
        color.setStroke()
        color.setFill()
    }
    
    var startPoint: CGPoint
    var endPoint: CGPoint
    var color: UIColor
}

struct Circle : Drawable {
    func draw(renderer: Renderer?) {
        let circle = UIBezierPath(ovalInRect: CGRect(origin: origin, size: CGSize(width: diameter, height: diameter)))
        circle.fill()
    }
    
    var origin: CGPoint
    var diameter: CGFloat
    var color: UIColor
}

struct Curve : Drawable {
    func draw(renderer: Renderer?) {
        guard let rend = renderer else { return }
        
        rend.moveTo(corners.first!)
        for p in corners {
            rend.lineTo(p)
        }
        
        color.setStroke()
        color.setFill()
    }
    
    var corners: [CGPoint] = []
    var color: UIColor
}

/// A group of `Drawable`s
struct Diagram : Drawable {
    func draw(renderer: Renderer?) {
        guard let rend = renderer else { return }
        
        for f in elements {
            f.draw(rend)
        }
    }
    
    mutating func add(other: Drawable) {
        elements.append(other)
    }
    
    var elements: [Drawable] = []
}

/// Extend UIBezierPath to support Renderer protocol
extension UIBezierPath: Renderer {
    func moveTo(position: CGPoint) {
        moveToPoint(position)
    }
    
    func lineTo(position: CGPoint) {
        addLineToPoint(position)
    }
}

// Created by Berik Visschers
extension UIColor {
    // Usage: UIColor(hex: 0xFC0ACE, alpha: 0.25)
    convenience init(hex: Int, alpha: Double) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: CGFloat(alpha))
    }
}

