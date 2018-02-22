//
//  BorderButton.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 28/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable class BorderButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 2.0 {
        didSet {
            refreshView()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            refreshView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.triggertrap_primaryColor(1.0) {
        didSet {
            refreshView()
        }
    }
    
    @IBInspectable var fillColor: UIColor = UIColor.clear {
        didSet {
            refreshView()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshView()
    }
    
    func refreshView() {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.backgroundColor = fillColor.cgColor
        self.layoutIfNeeded()
        self.setNeedsDisplay()
    }
}
