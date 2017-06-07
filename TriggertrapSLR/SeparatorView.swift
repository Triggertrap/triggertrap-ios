//
//  SeparatorView.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 10/11/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

import UIKit

@IBDesignable
public class SeparatorView: UIView {
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func drawRect(rect: CGRect) {
        // Drawing code
        
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.triggertrap_separatorColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 0.7)
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 1.0
        self.layer.shadowPath = shadowPath.CGPath
    }
}