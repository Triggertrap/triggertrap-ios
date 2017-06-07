//
//  TTShutterButton.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 01/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit
import QuartzCore

class ShutterButton: UIButton {
    
    // MARK: - Inspectables
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var ringColor : UIColor = UIColor.triggertrap_naturalColor(1.0) {
        didSet {
            refreshView()
        }
    }
    
    var centerColor : UIColor = UIColor.triggertrap_primaryColor(1.0) {
        didSet {
            refreshView()
        }
    }
    
    var strokeColor : UIColor = UIColor.triggertrap_foregroundColor(1.0) {
        didSet {
            refreshView()
        }
    }
    
    var ringAlpha : CGFloat = 1.0 {
        didSet {
            refreshView()
        }
    }
    
    var centerAlpha : CGFloat = 1.0 {
        didSet {
            refreshView()
        }
    }
    
    var strokeAlpha : CGFloat = 0.7 {
        didSet {
            refreshView()
        }
    }
    
    var ringWidth : CGFloat = 5.0 {
        didSet {
            refreshView()
        }
    }
    
    var centerRadius : CGFloat = 40.0 {
        didSet {
            refreshView()
        }
    }
    
    var strokeWidth : CGFloat = 1.0 {
        didSet {
            refreshView()
        }
    }

    // MARK: - Properties
    
    let animationInterval = 1.0
    let ringScaleSize: CGFloat = 2.4
    
    // Not currently using the UIMotionEffect as this is causing
    // issues with animation and rotation whilst the button animates
    let motionOffset = 0
    
    var animating = false
    var continuous = true
    var timer = NSTimer()
    var ring1 = CAShapeLayer()
    var ring2 = CAShapeLayer()
    var animationLayer = CALayer()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - Public
    
    func animateOnce() {
        startAnimating()
    }
    
    func performThemeUpdate() {
        
        ringColor = UIColor.triggertrap_naturalColor(1.0)
        centerColor = UIColor.triggertrap_primaryColor(1.0) 
        strokeColor = UIColor.triggertrap_foregroundColor(1.0)
    }
    
    func startAnimating() {
        addAnimationLayers()
        animateRing1()
        timer = NSTimer.scheduledTimerWithTimeInterval(animationInterval, target: self, selector: Selector("timerFired"), userInfo: nil, repeats: true)
        animating = true
//        } else {
//            ringColor = UIColor.triggertrap_primaryColor(1.0)
//        }
    }
    
    func stopAnimating() {
        
        animating = false
        timer.invalidate()
        removeAnimationLayers()
//        } else {
//            ringColor = UIColor.triggertrap_naturalColor(1.0)
//        }
    }
    
    // #pragma mark - Private
    
    private func commonInit() {
        // Initialization code

        let verticalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -motionOffset
        verticalMotionEffect.maximumRelativeValue = motionOffset
        
        let horizontalMotionEffect: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -motionOffset
        horizontalMotionEffect.maximumRelativeValue = motionOffset
        
        let group: UIMotionEffectGroup = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        self.addMotionEffect(group)
    }
    
    func refreshView() {
        self.layoutIfNeeded()
        self.setNeedsDisplay()
        
        let shapePosition = self.superview?.convertPoint(self.center, fromView: self.superview)
        
        ring1.position = shapePosition!
        ring2.position = shapePosition!
        ring1.setNeedsDisplay()
        ring2.setNeedsDisplay()
    }
    
    func timerFired() {
        if continuous {
            animateRing1()
        } else {
            stopAnimating()
        }
    }
    
    func animateRing1() {
        let scaleAnimation = CABasicAnimation()
        scaleAnimation.keyPath = "transform"
        scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        scaleAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(ringScaleSize, ringScaleSize, 1.0))
        
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.fromValue = 0.7
        alphaAnimation.toValue = 0.0
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, alphaAnimation]
        animation.duration = 0.7
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        ring1.addAnimation(animation, forKey: "sonarAnimation")
        
        let offset = 0.3
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(offset * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.animateRing2()
        })
    }
    
    func animateRing2() {
        let scaleAnimation = CABasicAnimation()
        scaleAnimation.keyPath = "transform"
        scaleAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        scaleAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(ringScaleSize, ringScaleSize, 1.0))
        
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.fromValue = 0.7
        alphaAnimation.toValue = 0.0
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, alphaAnimation]
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        self.ring2.addAnimation(animation, forKey: "sonarAnimation2")
    }
    
    func addAnimationLayers() {
        let pathFrame = CGRectMake(-CGRectGetMidX(bounds), -CGRectGetMidY(bounds), bounds.size.width, bounds.size.height)
        // This is a bit of a hack and could be done better.
        let reducedRect = CGRectMake(pathFrame.origin.x + 20, pathFrame.origin.y + 20, pathFrame.size.width - 40, pathFrame.size.height - 40)
        let path = UIBezierPath(roundedRect: reducedRect, cornerRadius: layer.cornerRadius)
        
        let shapePosition = self.superview?.convertPoint(self.center, fromView: self.superview)
        ring1.path = path.CGPath
        ring1.position = shapePosition!
        ring1.fillColor = UIColor.clearColor().CGColor
        ring1.opacity = 0.0
        ring1.strokeColor = centerColor.CGColor
        ring1.lineWidth = ringWidth
        
        animationLayer.addSublayer(ring1)
        
        ring2.path = path.CGPath
        ring2.position = shapePosition!
        ring2.fillColor = UIColor.clearColor().CGColor
        ring2.opacity = 0.0
        ring2.strokeColor = centerColor.CGColor
        ring2.lineWidth = ringWidth
        
        animationLayer.addSublayer(ring2)
        self.superview?.layer.addSublayer(animationLayer)
    }
    
    func removeAnimationLayers() {
        animationLayer.removeFromSuperlayer()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        // Get the center point
        let centerPoint = CGPointMake(rect.size.width / 2, rect.size.height / 2)
        
        // Draw the center circle
        let circleLayer = CAShapeLayer()
        
        let innerRect = CGRectMake(bounds.origin.x + ((bounds.size.width / 2.0) - centerRadius) , bounds.origin.y + ((bounds.size.height / 2.0) - centerRadius), (2 * centerRadius), (2 * centerRadius))
        
        let circlePath = UIBezierPath(roundedRect: innerRect, cornerRadius: innerRect.size.width / 2.0).CGPath

        circleLayer.bounds = rect
        circleLayer.path = circlePath
        circleLayer.fillColor = centerColor.colorWithAlphaComponent(centerAlpha).CGColor
        
        circleLayer.position = centerPoint
        
        // Add the stroke to the circle
        circleLayer.strokeColor = strokeColor.colorWithAlphaComponent(strokeAlpha).CGColor
        circleLayer.lineWidth = strokeWidth
        
        layer.addSublayer(circleLayer)
        
        // Draw the outer ring
        let ringLayer = CAShapeLayer()
        
        let ringPath = CGPathCreateWithEllipseInRect(rect, nil)
        ringLayer.bounds = rect
        ringLayer.path = ringPath
        
        ringLayer.position = centerPoint
        
        layer.mask = ringLayer
        
        layer.cornerRadius = CGRectGetHeight(rect) / 2
        layer.borderColor = ringColor.colorWithAlphaComponent(ringAlpha).CGColor
        layer.borderWidth = ringWidth
    }
}
