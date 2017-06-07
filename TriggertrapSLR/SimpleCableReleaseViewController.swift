//
//  SimpleCableReleaseViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 12/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class SimpleCableReleaseViewController: CableReleaseViewController {
    
    /*!
    * Measured in milliseconds. If the pulse length is less than this value there is not
    * enough time to animate the red view down, so don't run the animations.
    */
    let minimumAnimationDuration = 500
    
    // MARK: - Lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad() 
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        WearablesManager.sharedInstance.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchDown(sender : UIButton) { 
        
        // Check for an active view controller
        if sequenceManager.activeViewController == nil {

            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                
                // If the length of the sequence is greater than the
                // minimum animation duration, then show the red view
                if self.settingsManager.pulseLength.integerValue > self.minimumAnimationDuration {
                    
                    self.showFeedbackView(ConstStoryboardIdentifierCableReleaseFeedbackView)
                    
                    self.feedbackViewController.counterLabel?.countDirection = kCountDirection.CountDirectionDown.rawValue;
                    self.feedbackViewController.counterLabel?.startValue = self.settingsManager.pulseLength.unsignedLongLongValue
                    
                    self.feedbackViewController.circleTimer?.cycleDuration = Double(self.settingsManager.pulseLength.unsignedLongLongValue) / 1000.0
                    self.feedbackViewController.circleTimer?.progress = 1.0
                    self.feedbackViewController.circleTimer?.progressDirection = kProgressDirection.ProgressDirectionAntiClockwise.rawValue
                } else {
                    
                    // Animate the sutter button, even for short pulse lengths
                    self.startShutterButtonAnimation()
                    
                    prepareForSequence()
                    self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: settingsManager.pulseLength.doubleValue, unit: .Milliseconds))]),repeatSequence: false)
                }
            } 
        }
    }
    
    // MARK: - Overrides
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is SimpleCableReleaseViewController {
            
            feedbackViewController.startAnimations()
            
            prepareForSequence()
            
            self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: settingsManager.pulseLength.doubleValue, unit: .Milliseconds))]), repeatSequence: false)
        }
    }
}

extension SimpleCableReleaseViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchDown(UIButton())
    }
}
