
//
//  DongleCableView.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 29/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit
import QuartzCore

class DongleCableView: UIView {
    
    enum BezierPathType {
        case dongle,
        camera
    }
    
    var bezierType = BezierPathType.dongle
    
    var shapeLayer: CAShapeLayer!
    var displayLink: CADisplayLink!
    
    var point1: CGPoint = CGPoint.zero     
    var point2: CGPoint = CGPoint.zero
    
    var centerPoint: CGPoint = CGPoint.zero 
    var controlPoint1: CGPoint = CGPoint.zero
    var controlPoint2: CGPoint = CGPoint.zero
    var controlPoint3: CGPoint = CGPoint.zero
    var controlPoint4: CGPoint = CGPoint.zero

    var oldPath: CGPath!
    
    override func awakeFromNib() {
        addShapeLayer() 
    }
    
    func addShapeLayer() {
        updateControlPoints()
        
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineJoin = CAShapeLayerLineJoin.bevel
        shapeLayer.lineWidth = 7
        shapeLayer.strokeColor = UIColor(hex: 0xE2231A, alpha: 1.0).cgColor
        
        switch bezierType {
        case .dongle:
            shapeLayer.path = UIBezierPath.smoothPathWithPoints(point1, point2: point2, centerPoint: centerPoint, cp1: controlPoint1, cp2: controlPoint2, cp3: controlPoint3, cp4: controlPoint4).cgPath
            break
            
        case .camera:
            shapeLayer.path = UIBezierPath.smoothPathWithPoints(point1, point2: point2, centerPoint: nil, cp1: controlPoint1, cp2: controlPoint2, cp3: nil, cp4: nil).cgPath
            break 
        }
        
        oldPath = shapeLayer.path
        
        self.layer.addSublayer(shapeLayer)
//        self.layer.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.6).CGColor
    }
    
    func animateShapeLayereWithDuration(_ duration: Double) {
        
        updateControlPoints()
        
        // Set layer path to its old path
        shapeLayer.path = oldPath
        // Animate from the old path to the new path
        var newPath: CGPath!
        
        switch bezierType {
        case .dongle:
            newPath = UIBezierPath.smoothPathWithPoints(point1, point2: point2, centerPoint: centerPoint, cp1: controlPoint1, cp2: controlPoint2, cp3: controlPoint3, cp4: controlPoint4).cgPath
            break
            
        case .camera:
            newPath = UIBezierPath.smoothPathWithPoints(point1, point2: point2, centerPoint: nil, cp1: controlPoint1, cp2: controlPoint2, cp3: nil, cp4: nil).cgPath
            break
        }
        
        let curveAnimation = CABasicAnimation(keyPath: "path")
        curveAnimation.duration = duration
        curveAnimation.toValue = newPath
        curveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        curveAnimation.fillMode = CAMediaTimingFillMode.forwards
        curveAnimation.isRemovedOnCompletion = false
        
        self.shapeLayer.add(curveAnimation, forKey: "path")
        oldPath = newPath
    }
    
    fileprivate func updateControlPoints() {
        
        switch bezierType {
        case .dongle:
            centerPoint = CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            controlPoint1 = CGPoint(x: point1.x, y: point1.y + 50)
            controlPoint2 = CGPoint(x: (point1.x + centerPoint.x) / 2, y: point1.y + 50)
            controlPoint3 = CGPoint(x: (centerPoint.x + point2.x) / 2, y: point2.y - 50)
            controlPoint4 = CGPoint(x: point2.x, y: point2.y - 50)
            break
            
        case .camera:
            controlPoint1 = CGPoint(x: point1.x, y: point2.y)
            controlPoint2 = CGPoint(x: point1.x, y: point2.y)
            break 
        }
    }
}
