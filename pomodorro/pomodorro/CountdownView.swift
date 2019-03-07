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
    ///Cancel view
    private var cancelView: UIView!
    ///Layers
    private var timeLayer: CATextLayer!
    private var rectLayer: CALayer!
    private var arcLayer: CAReplicatorLayer!
    private var cancelLayer: CAGradientLayer!
    private var maskLayer: CAShapeLayer!
    
    static private func cgColorForRed(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> AnyObject {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0).cgColor as AnyObject
    }
    
    private let colors: [AnyObject] = [cgColorForRed(209.0, green: 0.0, blue: 0.0),
    cgColorForRed(255.0, green: 102.0, blue: 34.0),
    cgColorForRed(255.0, green: 218.0, blue: 33.0),
    cgColorForRed(51.0, green: 221.0, blue: 0.0),
    cgColorForRed(17.0, green: 51.0, blue: 204.0),
    cgColorForRed(34.0, green: 0.0, blue: 102.0),
    cgColorForRed(51.0, green: 0.0, blue: 68.0)]
    private let locations: [Float] = [0, 1/6.0, 1/3.0, 0.5, 2/3.0, 5/6.0, 1.0]
    
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
            timeLayer.string = stringFromTimeInterval(interval: timeRemaining)
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
      
        timeLayer = CATextLayer()
        timeLayer.string = "00:00"
        timeLayer.font = UIFont.systemFont(ofSize: 40.0)
        timeLayer.contentsScale = UIScreen.main.scale
        timeLayer.alignmentMode = .center
        timeLayer.foregroundColor = UIColor.black.cgColor
        timeLayer.zPosition = 10
        
        layer.addSublayer(timeLayer)
        
        rectLayer = CALayer()
        rectLayer.backgroundColor = UIColor.black.cgColor
        
        arcLayer = CAReplicatorLayer()
        arcLayer.addSublayer(rectLayer)
        arcLayer.instanceCount = Int(60)
        let angle: CGFloat = 2 * .pi / CGFloat(arcLayer.instanceCount)
        arcLayer.instanceTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        arcLayer.zPosition = 5
        
        layer.addSublayer(arcLayer)
        
        maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.black.cgColor
        layer.mask = maskLayer
        
        //add cancel view
        cancelView = UIView()
        cancelLayer = CAGradientLayer()
        cancelLayer.colors = colors
        cancelLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        cancelLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        cancelLayer.locations = locations as [NSNumber]?
        cancelView.layer.addSublayer(cancelLayer)
        addSubview(cancelView)
        
        //add some gesture recognizers
        //standard 0.5s is enough
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        addGestureRecognizer(longTapGestureRecognizer)
        //tap recognizer to play/pause
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //change frames of sublayers
        let center = CGPoint(x: (bounds.maxX - bounds.minX)/2.0, y: (bounds.maxY - bounds.minY)/2.0)
        let origin = CGPoint(x: center.x - timeLayer.bounds.width / 2.0, y: center.y - timeLayer.bounds.height / 2.0)
        let size = CGSize(width: bounds.width, height: 40.0)
        let frame = CGRect(origin: origin, size: size)
        timeLayer.frame = frame
        //change rectLayer
        let rectWidth: CGFloat = 5.0
        let midX = center.x - rectWidth / 2.0
        rectLayer.frame = CGRect(x: midX, y: 0.0, width: rectWidth, height: rectWidth * 3.0)
        //change transform of arc layer
        arcLayer.frame = bounds
        arcMaskLayer.frame = bounds
        //change mask layer
        maskLayer.frame = bounds
        let radius: CGFloat = min(bounds.width, bounds.height)/2.0
        let fullCirclePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: 2 * .pi, clockwise: true).cgPath
        maskLayer.path = fullCirclePath
        //change gradient layer
        cancelLayer.frame = bounds
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
            self.cancelView.frame = rectViewInitialFrame
            animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut) {
                UIView.animate(withDuration: 1.0) {
                    self.cancelView.frame = self.rectViewFinishFrame
                }
            }
            animator?.addCompletion {
                if $0 == .end {
                    self.delegate?.countdownViewCancelled(self)
                    self.animator?.stopAnimation(false)
                    self.animator = nil
                    let completionAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
                        self.cancelView.frame = self.rectViewInitialFrame
                        self.cancelView.setNeedsDisplay()
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
