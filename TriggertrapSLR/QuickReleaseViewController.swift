//
//  QuickReleaseViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 18/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class QuickReleaseViewController: CableReleaseViewController {
    private var shutterButtonHasBeenReleased = false
    private var isTriggering = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() { 
        super.viewDidLoad()  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchDown(sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                shutterButtonHasBeenReleased = false
                 
                showFeedbackView(ConstStoryboardIdentifierCableReleaseFeedbackView)
                feedbackViewController.circleTimer?.progress = 0.4 
                feedbackViewController.circleTimer?.indeterminate = 1
            }
        }
    }
    
    @IBAction func shutterButtonTouchUpInside(sender : UIButton) {
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is QuickReleaseViewController {
            if feedbackViewVisible {
                trigger()
            } else {
                shutterButtonHasBeenReleased = true
            }
        }
    }
    
    @IBAction func shutterButtonTouchUpOutside(sender : UIButton) {
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is QuickReleaseViewController {
            if feedbackViewVisible {
                trigger()
            } else {
                shutterButtonHasBeenReleased = true
            }
        }
    }
    
    @IBAction func shutterButtonTouchDragOutside(sender : UIButton, event: UIEvent) {
        let touches = event.allTouches()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is QuickReleaseViewController {
            if let touches = touches {
                let point = touches.first!.locationInView(sender)
                
                if sender.pointInside(point, withEvent: event) == false {
                    // The touch has dragged outside of the active area of the button
                    
                    if feedbackViewVisible {
                        trigger()
                    } else {
                        shutterButtonHasBeenReleased = true
                    }
                }
            }
        }
    }
    
    // MARK: - Overrides
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is QuickReleaseViewController {
             
            if shutterButtonHasBeenReleased {
                trigger()
            } else {
                feedbackViewController.startAnimations()
            }
        }
    }
    
    override func feedbackViewHideAnimationCompleted() {
        super.feedbackViewHideAnimationCompleted()
        isTriggering = false
    }
    
    override func activeViewControllerLostFocus() {
        super.activeViewControllerLostFocus()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is QuickReleaseViewController {
            self.trigger()
        }
    }
    
    // MARK: - Private
    
    private func trigger() {
        self.shutterButton.enabled = false
        
        if isTriggering {
            return
        }
        
        isTriggering = true
        
        prepareForSequence()
        self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: settingsManager.pulseLength.doubleValue, unit: .Milliseconds))]), repeatSequence: false)
    }
}
