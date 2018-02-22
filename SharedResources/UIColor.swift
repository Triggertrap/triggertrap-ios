//
//  Extensions.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 12/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

public extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 08) / 255.0
        let b = CGFloat((hex & 0x0000FF) >> 00) / 255.0
        self.init(red:r, green:g, blue:b, alpha:alpha)
    }
    
    
    /*
    color - color that need change
    percent - change to each of the color components except alpha in 0 - 1 range
    */
    class func triggertrap_color(_ color: UIColor, change percent: CGFloat) -> UIColor {
        
        let components = color.cgColor.components
        let red = (components?[0])! * (1.0 - percent)
        let green = (components?[1])! * (1.0 - percent)
        let blue = (components?[2])! * (1.0 - percent)
        let alpha = components?[3]
        
        return UIColor(red: componentInBounds(red), green: componentInBounds(green), blue: componentInBounds(blue), alpha: alpha!)
    }
    
    class func triggertrap_primaryColor(_ alpha: CGFloat = 1.0) -> UIColor {
        
        switch AppTheme() {
        case .normal: 
//                        return UIColor(hex: 0x26F545, alpha: alpha)
            return UIColor(hex: 0xE2231A, alpha: alpha)
            
        case .night:
            return UIColor(hex: 0x60010D, alpha: alpha)
        }
    }
    
    class func triggertrap_shadeRedColor (_ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: 0xCA1F17, alpha: alpha)
    }
    
    class func triggertrap_trackTintColor (_ alpha: CGFloat = 1.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(hex: 0xC1241C, alpha: alpha)
        case .night:
            return UIColor(hex: 0xE2231A, alpha: alpha)
        }
    }
    
    class func triggertrap_timeWarpDarkRedColor (_ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: 0x9E1812, alpha: alpha)
    }
    
    class func triggertrap_iconColor (_ alpha: CGFloat = 1.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(hex: 0xFFFFFF, alpha: alpha)
            
        case .night:
            return UIColor.black
        }
    }
    
    class func triggertrap_fillColor (_ alpha: CGFloat = 1.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(hex: 0xFFFFFF, alpha: alpha)
            
        case .night:
            return UIColor(hex: 0x151515, alpha: alpha)
        }
    }
    
    class func triggertrap_backgroundColor (_ alpha: CGFloat = 1.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(hex: 0xEFEFEF, alpha: alpha)
            
        case .night:
            return UIColor(hex: 0x2A2A2A, alpha: alpha)
        }
    }
    
    class func triggertrap_naturalColor (_ alpha: CGFloat = 1.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(hex: 0xDBDBDB, alpha: alpha)
            
        case .night:
            return UIColor(hex: 0x353535, alpha: alpha)
        }
    }
    
    class func triggertrap_mediumDarkGreyColor (_ alpha: CGFloat = 1.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(hex: 0x9F9F9F, alpha: alpha)
            
        case .night:
            return UIColor(hex: 0x9F9F9F, alpha: alpha)
        }
    }
    
    class func triggertrap_foregroundColor (_ alpha: CGFloat = 1.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(hex: 0x838383, alpha: alpha)
            
        case .night:
            return UIColor(hex: 0x5A5A5A, alpha: alpha)
        }
    }
    
    class func triggertrap_clearColor(_ alpha: CGFloat = 0.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(white: 1.0, alpha: alpha)
        case .night:
            return UIColor(white: 0.0, alpha: alpha)
        }
    }
    
    
    class func triggertrap_separatorColor() -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)
        case .night:
            return UIColor(red: 0.24, green: 0.24, blue: 0.24, alpha: 1.0)
        }
    }
    
    class func triggertrap_accentColor (_ alpha: CGFloat = 1.0) -> UIColor {
        switch AppTheme() {
        case .normal:
            return UIColor(hex: 0x313131, alpha: alpha)
            
        case .night:
            return UIColor(hex: 0x980013, alpha: alpha)
        }
    }
}
