//
//  DARGraphView.swift
//  DARGraphDrawer
//
//  Created by Alessio Roberto on 26/08/15.
//  Copyright © 2015 Alessio Roberto. All rights reserved.
//

import UIKit

struct Params {
    let margin:CGFloat = 90.0
    let topBorder:CGFloat = 30.0
    let bottomBorder:CGFloat = 80.0
    
    let maxValue: Double = 6.0  // log10(10^6)
}

class ETKVGraphView: UIView {
    
    private var graph: Graph
    private var parameters = Params()
    
    override init(frame: CGRect) {
        self.graph = Graph(width: 0.0,
            height: 0.0,
            margin: parameters.margin,
            topBorder: parameters.topBorder,
            bottomBorder: parameters.bottomBorder,
            maxValue: parameters.maxValue)
        
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.graph = Graph(width: 0.0,
            height: 0.0,
            margin: parameters.margin,
            topBorder: parameters.topBorder,
            bottomBorder: parameters.bottomBorder,
            maxValue: parameters.maxValue)
        
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        
        graph.width = rect.width
        graph.height = rect.height
  
        graph.drawColoredSingleLine([0.1, 2, 3.4, 1, 0.34], color: Colors().colors[1])
    }
}