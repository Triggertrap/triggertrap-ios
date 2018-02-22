//
//  CenterViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 01/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

@IBDesignable class CenterViewController: UIViewController {
    
    // MARK - Lifecycle
    
    @IBInspectable var displayMenuButton: Bool = true
    @IBInspectable var displayOptionsButton: Bool = true
    
    var leftButton: UIButton?
    var rightButton: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if displayMenuButton {
            
            leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            leftButton?.addTarget(self.navigationController, action: Selector("menuButtonTapped:"), forControlEvents: UIControlEvents.TouchDown)
            leftButton?.setBackgroundImage(ImageWithColor(UIImage(named: "MenuIcon")!, color: UIColor.triggertrap_fillColor()) , forState: .Normal)
            
            let leftBarButton = UIBarButtonItem(customView: leftButton!)
            leftBarButton.style = UIBarButtonItemStyle.Plain
            
            // This does not need translation.
            leftBarButton.accessibilityLabel = "Menu"
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
        
        if displayOptionsButton {
            // Set the right bar button item.
            
            rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
            rightButton?.addTarget(self.navigationController, action: Selector("optionsButtonTapped:"), forControlEvents: UIControlEvents.TouchDown)
            rightButton?.setBackgroundImage(ImageWithColor(UIImage(named: "OptionsIcon")!, color: UIColor.triggertrap_fillColor()) , forState: .Normal)
            let rightBarButton = UIBarButtonItem(customView: rightButton!)
            rightBarButton.style = UIBarButtonItemStyle.Plain
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
    }
}
