//
//  GradientOverlayView.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 15/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GradientOverlayView: UIView {
    @IBInspectable var color: UIColor = UIColor.whiteColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var direction: Int = 1
    
    // Assign a value to this variable if you want the theme gray scale to be ignored; range 0.0 - 1.0
    var grayScale: CGFloat? {
        didSet {
            grayScale = componentInBounds(grayScale!)
            setNeedsDisplay()
        }
    }
    
    enum GradientDirection: Int {
        case Up = 1,
        Down = 2,
        Left = 3,
        Right = 4
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        UIColor.clearColor().setFill()
        
        let rect = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations = [0.0, 1.0] as [CGFloat]
        
        var colors: [CGColor]!
        
        if let grayScale = grayScale {
            colors = [color.CGColor, UIColor(white: grayScale, alpha: 0.0).CGColor]
        } else {
            switch AppTheme() {
            case .Normal:
                colors = [color.CGColor, UIColor(white: 1.0, alpha: 0.0).CGColor]
                break
                
            case .Night:
                colors = [color.CGColor, UIColor(white: 0.0, alpha: 0.0).CGColor]
                break
            }
        }
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        
        var startPoint: CGPoint?
        var endPoint: CGPoint?
        
        switch GradientDirection(rawValue: direction)! {
        case .Up:
            startPoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMaxY(rect))
            endPoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMinY(rect))
            break
            
        case .Down:
            startPoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMinY(rect))
            endPoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMaxY(rect))
            break
            
        case .Left:
            startPoint = CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMidY(rect))
            endPoint = CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMidY(rect))
            break
            
        case .Right:
            startPoint = CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMidY(rect))
            endPoint = CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMidY(rect))
            break
        }
        
        CGContextSaveGState(context)
        CGContextAddRect(context, rect)
        CGContextClip(context)
        
        CGContextDrawLinearGradient(context, gradient, startPoint!, endPoint!, CGGradientDrawingOptions(rawValue: 0))
        CGContextRestoreGState(context)
    }
}
