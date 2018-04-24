//
//  QuickReleaseViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 18/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class QuickReleaseViewController: CableReleaseViewController {
    fileprivate var shutterButtonHasBeenReleased = false
    fileprivate var isTriggering = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() { 
        super.viewDidLoad()  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchDown(_ sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                shutterButtonHasBeenReleased = false
                 
                showFeedbackView(ConstStoryboardIdentifierCableReleaseFeedbackView)
                feedbackViewController.circleTimer?.updateProgress(0.4)
                feedbackViewController.circleTimer?.indeterminate = 1
            }
        }
    }
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is QuickReleaseViewController {
            if feedbackViewVisible {
                trigger()
            } else {
                shutterButtonHasBeenReleased = true
            }
        }
    }
    
    @IBAction func shutterButtonTouchUpOutside(_ sender : UIButton) {
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is QuickReleaseViewController {
            if feedbackViewVisible {
                trigger()
            } else {
                shutterButtonHasBeenReleased = true
            }
        }
    }
    
    @IBAction func shutterButtonTouchDragOutside(_ sender : UIButton, event: UIEvent) {
        let touches = event.allTouches
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is QuickReleaseViewController {
            if let touches = touches {
                let point = touches.first!.location(in: sender)
                
                if sender.point(inside: point, with: event) == false {
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
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is QuickReleaseViewController {
             
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
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is QuickReleaseViewController {
            self.trigger()
        }
    }
    
    // MARK: - Private
    
    fileprivate func trigger() {
        self.shutterButton.isEnabled = false
        
        if isTriggering {
            return
        }
        
        isTriggering = true
        
        prepareForSequence()
        self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: (settingsManager?.pulseLength.doubleValue)!, unit: .milliseconds))]), repeatSequence: false)
    }
}
