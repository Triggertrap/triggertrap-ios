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
        
        if !(UIDevice.currentDevice().model == "iPad") && !(UIDevice.currentDevice().model == "iPad Simulator") {
            // Force the device in portrait mode when the navigation controller gets loaded
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        }
        
        // Hide the status bar with animation
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    override func shouldAutorotate() -> Bool {
        // Lock autorotate
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        // Only allow Portrait for the onboarding
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        
        // Only allow Portrait for the onboarding
        return UIInterfaceOrientation.Portrait
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Show the status bar with animation
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
}
