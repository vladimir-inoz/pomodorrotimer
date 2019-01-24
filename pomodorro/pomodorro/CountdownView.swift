//
//  CountdownView.swift
//  pomodorro
//
//  Created by User on 14/01/2019.
//  Copyright © 2019 ult_v. All rights reserved.
//

import UIKit

protocol CountdownViewDelegate {
    //on long tap
    func countdownViewCancelled(_ : CountdownView)
    //on tap
    func countdownViewTapped()
}

class CountdownView: UIView {
    
    private var rectView: UIView!
    private var timeLabel: UILabel!
    
    ///Converting TimeInterval to string 01:12
    fileprivate func stringFromTimeInterval(interval: TimeInterval) -> String {
        let intervalInt = Int(interval)
        let minutes = intervalInt / 60
        let seconds = intervalInt % 60
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    ///How much time is remaining
    public var timeRemaining: TimeInterval = 0.8 {
        didSet {
            if timeRemaining < 0 {
                timeRemaining = 0
                return
            }
            if timeRemaining > timeTotal {
                timeRemaining = timeTotal
            }
            timeLabel.text = stringFromTimeInterval(interval: timeRemaining)
            setNeedsDisplay()
        }
    }
    ///Bold width of red arc
    public var boldWidth: CGFloat = 10.0
    ///Regular width of black arc
    public var regularWidth: CGFloat = 1.0
    
    ///Full time
    ///Cannot be more than timeRemaining
    public var timeTotal: TimeInterval = 1.0 {
        didSet {
            if timeTotal < 0 {
                timeTotal = timeRemaining
            }
            setNeedsDisplay()
        }
    }
    
    ///Animator of full rectangle
    private var animator: UIViewPropertyAnimator?
    
    ///Delegate
    public var delegate: CountdownViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        rectView = UIView(frame: CGRect(x: 0.0, y: bounds.height, width: bounds.width, height: 0.0))
        rectView.backgroundColor = UIColor.yellow
        addSubview(rectView)
        
        timeLabel = UILabel(frame: CGRect.zero)
        timeLabel.text = "00:00"
        timeLabel.textColor = UIColor.red
        timeLabel.font = timeLabel.font.withSize(40.0)
        addSubview(timeLabel)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        //add some gesture recognizers
        //standard 0.5s is enough
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        addGestureRecognizer(longTapGestureRecognizer)
        //tap recognizer to play/pause
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIRectFill(bounds)
        
        let percentComplete: CGFloat = CGFloat(timeRemaining / timeTotal)
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = min(bounds.width, bounds.height)
        let startAngle: CGFloat = 1.5 * .pi
        let endAngle: CGFloat = startAngle + 2 * .pi * (percentComplete - 0.0001)
        
        //first create mask and draw fullfillment rectangle
        if layer.mask == nil {
            let fullCirclePath = UIBezierPath(arcCenter: center, radius: radius/2 - regularWidth/2 - boldWidth/2, startAngle: 0.0, endAngle: 2 * .pi, clockwise: true).cgPath
            let maskLayer = CAShapeLayer()
            maskLayer.path = fullCirclePath
            maskLayer.fillColor = UIColor.black.cgColor
            layer.mask = maskLayer
        }
        
        let pathRegular = UIBezierPath(arcCenter: center, radius: radius/2 - regularWidth/2 - boldWidth/2, startAngle: 0.0, endAngle: 2 * .pi, clockwise: true)
        pathRegular.lineWidth = regularWidth
        UIColor.black.setStroke()
        pathRegular.stroke()
        
        let path = UIBezierPath(arcCenter: center, radius: radius/2 - boldWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.lineWidth = boldWidth
        UIColor.red.setStroke()
        path.stroke()
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: 200.0, height: 200.0)
        }
    }
    
}

/// handlers
extension CountdownView {
    var rectViewInitialFrame: CGRect {
        return CGRect(x: 0.0, y: self.bounds.height, width: self.bounds.width, height: 0.0)
    }
    
    var rectViewFinishFrame: CGRect {
        return CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.bounds.height)
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            self.rectView.frame = rectViewInitialFrame
            animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut) {
                self.rectView.frame = self.rectViewFinishFrame
                self.rectView.setNeedsDisplay()
            }
            animator?.addCompletion {
                if $0 == .end {
                    self.delegate?.countdownViewCancelled(self)
                    self.animator?.stopAnimation(false)
                    self.animator = nil
                    let completionAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
                        self.rectView.frame = self.rectViewInitialFrame
                        self.rectView.setNeedsDisplay()
                    }
                    completionAnimator.startAnimation()
                }
            }
            animator?.startAnimation()
        case .ended:
            animator?.isReversed = true
        default:
            break
        }
        
    }
    
    @objc func tap() {
        self.delegate?.countdownViewTapped()
    }
}
