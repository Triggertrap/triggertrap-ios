//
//  PressAndLockViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class PressAndLockViewController: CableReleaseViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() { 
                sequenceManager.activeViewController = self
                showFeedbackView(ConstStoryboardIdentifierCableReleaseFeedbackView)
            }
            
        } else {
            self.sequenceManager.cancel()
        }
    }
    
    // MARK: - Overrides
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is PressAndLockViewController {
            feedbackViewController.circleTimer?.progress = 0.4
            
            // 1 = true, 0 = false
            feedbackViewController.circleTimer?.indeterminate = 1
            
            feedbackViewController.startAnimations()
            
            prepareForSequence()
            self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: Double.infinity, unit: .hours))]), repeatSequence: false)
        }
    }
}

extension PressAndLockViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton()) 
    }
}
