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

