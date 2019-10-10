//
//  SplitLayoutViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 01/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//  Last updated by Valentin Kalchev 22/09/2015

import UIKit

class SplitLayoutViewController: CenterViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var topLeftView: UIView!
    @IBOutlet var bottomRightView: UIView!
    @IBOutlet var tlWidthConstraint: NSLayoutConstraint!
    @IBOutlet var tlHeightConstraint: NSLayoutConstraint!
    @IBOutlet var brWidthConstraint: NSLayoutConstraint!
    @IBOutlet var brHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var separatorView: UIView?
    
    // MARK: - Computed properties
    
    var layoutRatio: Dictionary <String, CGFloat> = iPhone ? ["top": CGFloat(2.0 / 3.0), "bottom": CGFloat(1.0 / 3.0)] : ["top": CGFloat(3.5 / 5.0), "bottom": CGFloat(1.5 / 5.0)]
    
    var viewControllerTheme: Theme = .normal
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    } 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(SplitLayoutViewController.performThemeUpdate), name: NSNotification.Name(rawValue: ConstThemeHasBeenUpdated), object: nil)
        
        // Check if the view controller's theme has been changed and perform theme update if needed
        if viewControllerTheme != AppTheme() {
            performThemeUpdate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *){
            performThemeUpdate()
        }
    }

    override func viewWillLayoutSubviews()  {
        super.viewWillLayoutSubviews()
        
        // If the ratios != nil
        if layoutRatio["top"] != nil && layoutRatio["bottom"] != nil {
            
            // Unwrap the values and update the constraints.
            let portrait = self.view.bounds.size.width < self.view.bounds.size.height ? true : false


            var insetPadding:CGFloat = 0


            let orientation = UIDevice.current.orientation

            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                if orientation == .landscapeLeft{
                    insetPadding =  window?.safeAreaInsets.left ?? 0
                } else if orientation == .landscapeRight{
                    insetPadding =  window?.safeAreaInsets.right ?? 0
                }

            }
            
            if #available(iOS 11.0, *) {
                self.tlWidthConstraint.constant = portrait ? self.view.frame.size.width : ((self.view.frame.size.width + self.view.safeAreaInsets.left / 2 + self.view.safeAreaInsets.right) * layoutRatio["top"]! - insetPadding)
            } else {
                self.tlWidthConstraint.constant = portrait ? self.view.frame.size.width : (self.view.frame.size.width * layoutRatio["top"]! - insetPadding)
            }
            self.tlHeightConstraint.constant = portrait ? (self.view.frame.size.height * layoutRatio["top"]!) : self.view.frame.size.height
            self.brWidthConstraint.constant = portrait ? self.view.frame.size.width : (self.view.frame.size.width * layoutRatio["bottom"]!)
            self.brHeightConstraint.constant = portrait ? (self.view.frame.size.height * layoutRatio["bottom"]!) : self.view.frame.size.height
            
            // Remove the separatorView if there is one
            separatorView?.removeFromSuperview()
            
            // Create a new separatorView
            separatorView = UIView()
            separatorView!.backgroundColor = UIColor.triggertrap_accentColor(1.0)
            separatorView?.translatesAutoresizingMaskIntoConstraints = false
            
            bottomRightView.addSubview(separatorView!)
        
            // Set the constraints for the separatorView
            if portrait {
                separatorView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[separatorView(==1)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["separatorView": separatorView!]))
                
                bottomRightView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[separatorView]-(0)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["separatorView": separatorView!]))
                
                bottomRightView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[separatorView]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["separatorView": separatorView!]))
            } else {
                separatorView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[separatorView(==1)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["separatorView": separatorView!]))
                
                bottomRightView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[separatorView]-(0)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["separatorView": separatorView!]))
                
                bottomRightView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[separatorView]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["separatorView": separatorView!]))
            }
        }
    }
    
    @objc func performThemeUpdate() {
        
        self.view.backgroundColor = UIColor.triggertrap_fillColor()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.triggertrap_metric_regular(23.0), NSAttributedString.Key.foregroundColor: UIColor.triggertrap_iconColor(1.0)]
        
        self.topLeftView.backgroundColor = UIColor.triggertrap_fillColor()
        self.bottomRightView.backgroundColor = UIColor.triggertrap_backgroundColor()
        
        self.separatorView?.backgroundColor = UIColor.triggertrap_accentColor(1.0)
        
        self.leftButton?.setBackgroundImage(#imageLiteral(resourceName: "MenuIcon"), for: .normal)
        self.leftButton?.tintColor = UIColor.triggertrap_fillColor(1)

        self.rightButton?.setBackgroundImage(#imageLiteral(resourceName: "OptionsIcon"), for: .normal)
        self.rightButton?.tintColor = UIColor.triggertrap_fillColor(1)
        
        self.viewControllerTheme = AppTheme()
    }
}
