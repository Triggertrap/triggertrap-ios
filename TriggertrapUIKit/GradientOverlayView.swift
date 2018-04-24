//
//  GradientOverlayView.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 15/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

@IBDesignable class GradientOverlayView: UIView {
    @IBInspectable var color: UIColor = UIColor.white {
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
        case up = 1,
        down = 2,
        left = 3,
        right = 4
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        UIColor.clear.setFill()
        
        let rect = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations = [0.0, 1.0] as [CGFloat]
        
        var colors: [CGColor]!
        
        if let grayScale = grayScale {
            colors = [color.cgColor, UIColor(white: grayScale, alpha: 0.0).cgColor]
        } else {
            switch AppTheme() {
            case .normal:
                colors = [color.cgColor, UIColor(white: 1.0, alpha: 0.0).cgColor]
                break
                
            case .night:
                colors = [color.cgColor, UIColor(white: 0.0, alpha: 0.0).cgColor]
                break
            }
        }
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors! as CFArray, locations: locations)
        
        var startPoint: CGPoint?
        var endPoint: CGPoint?
        
        switch GradientDirection(rawValue: direction)! {
        case .up:
            startPoint = CGPoint(x: rect.midX, y: rect.maxY)
            endPoint = CGPoint(x: rect.midX, y: rect.minY)
            break
            
        case .down:
            startPoint = CGPoint(x: rect.midX, y: rect.minY)
            endPoint = CGPoint(x: rect.midX, y: rect.maxY)
            break
            
        case .left:
            startPoint = CGPoint(x: rect.maxX, y: rect.midY)
            endPoint = CGPoint(x: rect.minX, y: rect.midY)
            break
            
        case .right:
            startPoint = CGPoint(x: rect.minX, y: rect.midY)
            endPoint = CGPoint(x: rect.maxX, y: rect.midY)
            break
        }
        
        context?.saveGState()
        context?.addRect(rect)
        context?.clip()
        
        context?.drawLinearGradient(gradient!, start: startPoint!, end: endPoint!, options: CGGradientDrawingOptions(rawValue: 0))
        context?.restoreGState()
    }
}
