//
//  CountdownView.swift
//  pomodorro
//
//  Created by User on 14/01/2019.
//  Copyright © 2019 ult_v. All rights reserved.
//

import UIKit

class CountdownView: UIView {
    
    private struct Constants {
        static let boldWitdh: CGFloat = 10.0
        static let regularWidth: CGFloat = 20.0
    }
    
    public var timeInterval: TimeInterval = 0.8
    
    ///Starting time interval
    ///Cannot be more than timeInterval
    public var maxTimeInterval: TimeInterval = 1.0 {
        didSet {
            if maxTimeInterval < 0 || maxTimeInterval > timeInterval {
                maxTimeInterval = timeInterval
            }
        }
    }

    override func draw(_ rect: CGRect) {
        let percentComplete: CGFloat = CGFloat(timeInterval / maxTimeInterval)
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = min(bounds.width, bounds.height)
        let startAngle: CGFloat = 1.5 * .pi
        var endAngle: CGFloat = startAngle + 2 * .pi * percentComplete
        while endAngle > 2 * .pi {
            endAngle = endAngle - 2 * .pi
        }
        
        let path = UIBezierPath(arcCenter: center, radius: radius/2 - Constants.regularWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.lineWidth = Constants.regularWidth
        UIColor.red.setStroke()
        path.stroke()
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: 200.0, height: 200.0)
        }
    }
    
}
