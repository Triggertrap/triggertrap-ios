//
//  OnboardingNavigationViewController.swift
//  Timelapse Pro
//
//  Created by Valentin Kalchev on 18/11/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class OnboardingNavigationViewController: UINavigationController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        if !(UIDevice.current.model == "iPad") && !(UIDevice.current.model == "iPad Simulator") {
            // Force the device in portrait mode when the navigation controller gets loaded
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        
        // Hide the status bar with animation
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.slide)
    }
    
    override var shouldAutorotate : Bool {
        // Lock autorotate
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        
        // Only allow Portrait for the onboarding
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        
        // Only allow Portrait for the onboarding
        return UIInterfaceOrientation.portrait
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Show the status bar with animation
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.slide)
    }
}
