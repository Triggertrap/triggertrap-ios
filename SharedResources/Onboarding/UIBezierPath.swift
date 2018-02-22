//
//  DonglePath.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 29/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

public extension UIBezierPath {
    
    class func smoothPathWithPoints(_ point1: CGPoint, point2: CGPoint, centerPoint: CGPoint?, cp1: CGPoint, cp2: CGPoint, cp3: CGPoint?, cp4: CGPoint?) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        path.move(to: point1)
        
        if let centerPoint = centerPoint {
            path.addCurve(to: centerPoint, controlPoint1: cp1, controlPoint2: cp2)
            path.addCurve(to: point2, controlPoint1: cp3!, controlPoint2: cp4!)
        } else {
            path.addCurve(to: point2, controlPoint1: cp1, controlPoint2: cp2)
        }
        
        return path
    }
}
