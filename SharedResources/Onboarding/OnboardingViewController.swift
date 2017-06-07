//
//  OnboardingViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 17/02/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // TODO: When refactoring, move all common Onboarding vc variables to this view controller
    
    // Call this function to dismiss the view controller from a storyboard vc button
    @IBAction func dismissViewController(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
