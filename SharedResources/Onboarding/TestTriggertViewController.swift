//
//  TestTriggertViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 27/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

// TODO: @Valentin confirm that this class works correctly
// including the alert view and the case where a user has a mode running whilst looking
// at the onboarding. I've coded this 'blind' so there may be mistakes.

class TestTriggertViewController: OnboardingViewController {
    
    // MARK: - Lifecycle
    @IBOutlet var separatorLine: UIView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var triggertrapView: UIView!
    
    @IBOutlet var bottomRightView: UIView!
    @IBOutlet var topLeftView: UIView!
    
    @IBOutlet var shutterButton: ShutterButton!
    
    let sequenceManager = SequenceManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: 0xE2231A, alpha: 1.0)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.triggertrap_metric_regular(23.0), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        shutterButton.ringColor = UIColor(hex: 0xDBDBDB, alpha: 1.0)
        shutterButton.centerColor = UIColor(hex: 0xE2231A, alpha: 1.0)
        shutterButton.strokeColor = UIColor(hex: 0x838383, alpha: 1.0) 
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(_ shutterButton: ShutterButton) {
        
        // Usually we would check for the save pulse length in the settings manager
        // and use this value for the pulse duration. However, as this is only a test
        // case we can default to the standard 150ms pulse length.
        shutterButton.startAnimating()
        
        OutputDispatcher.sharedInstance.activeDispatchers = [HeadphoneDispatcher.sharedInstance, WifiDispatcher.sharedInstance]
        sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: 150.0, unit: .milliseconds))]), repeatSequence: false)
        
        delay(0.7) {
            shutterButton.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    } 
}
