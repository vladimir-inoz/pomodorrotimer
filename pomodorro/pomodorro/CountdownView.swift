//
//  CountdownView.swift
//  pomodorro
//
//  Created by User on 14/01/2019.
//  Copyright © 2019 ult_v. All rights reserved.
//

import UIKit

class CountdownView: UIView {
    
    ///Converting TimeInterval to string 01:12
    fileprivate func stringFromTimeInterval(interval: TimeInterval) -> NSString {
        let intervalInt = Int(interval)
        let minutes = intervalInt / 60
        let seconds = intervalInt % 60
        return NSString(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    ///How much time is remaining
    public var timeRemaining: TimeInterval = 0.8 {
        didSet {
            if timeRemaining < 0 {
                timeRemaining = 0
            }
            setNeedsDisplay()
        }
    }
    public var boldWidth: CGFloat = 10.0
    public var regularWidth: CGFloat = 1.0
    
    ///Full time
    ///Cannot be more than timeRemaining
    public var timeTotal: TimeInterval = 1.0 {
        didSet {
            if timeTotal < 0 || timeTotal > timeRemaining {
                timeTotal = timeRemaining
            }
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let percentComplete: CGFloat = CGFloat(timeRemaining / timeTotal)
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = min(bounds.width, bounds.height)
        let startAngle: CGFloat = 1.5 * .pi
        var endAngle: CGFloat = startAngle + 2 * .pi * percentComplete
        while endAngle > 2 * .pi {
            endAngle = endAngle - 2 * .pi
        }
        
        let pathRegular = UIBezierPath(arcCenter: center, radius: radius/2 - regularWidth/2 - boldWidth/2, startAngle: 0.0, endAngle: 2 * .pi, clockwise: true)
        pathRegular.lineWidth = regularWidth
        UIColor.black.setStroke()
        pathRegular.stroke()
        
        let path = UIBezierPath(arcCenter: center, radius: radius/2 - boldWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.lineWidth = boldWidth
        UIColor.red.setStroke()
        path.stroke()
        
        let string = stringFromTimeInterval(interval: timeRemaining)
        let attributes = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 40),
            NSAttributedString.Key.foregroundColor : UIColor.red
        ]
        let stringSize = string.size(withAttributes: attributes)
        let stringRect = CGRect(x: center.x - stringSize.width/2, y: center.y - stringSize.height/2, width: stringSize.width, height: stringSize.height)
        string.draw(in: stringRect, withAttributes: attributes)
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: 200.0, height: 200.0)
        }
    }
    
}
