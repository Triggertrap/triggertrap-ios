//
//  PressAndHoldViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class PressAndHoldViewController: CableReleaseViewController {
    
    fileprivate var notificationReceived = false
    fileprivate var shutterButtonHasBeenReleased = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
                notificationReceived = false
                
                showFeedbackView(ConstStoryboardIdentifierCableReleaseFeedbackView)
                feedbackViewController.counterLabel?.startValue = 0
            }
        }
    }
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is PressAndHoldViewController {
            if notificationReceived == true {
                 self.sequenceManager.cancel()
            } else {
                shutterButtonHasBeenReleased = true;
            }
        }
    }
    
    @IBAction func shutterButtonTouchUpOutside(_ sender : UIButton) {
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is PressAndHoldViewController {
            if notificationReceived == true {
                self.sequenceManager.cancel()
            } else {
                shutterButtonHasBeenReleased = true
            }
        }
    }
    
    @IBAction func shutterButtonTouchDragOutside(_ sender : UIButton, event: UIEvent) {
        let touches = event.allTouches
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is PressAndHoldViewController {
            if let touches = touches, let firstTouch = touches.first {
                let point = firstTouch.location(in: sender)
                
                if sender.point(inside: point, with: event) == false {
                    // The touch has dragged outside of the active area of the button
                    self.sequenceManager.cancel()
                }
            }
        }
    }
    
    // MARK: - Overrides
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is PressAndHoldViewController {
            
            if notificationReceived == false {
                notificationReceived = true
                prepareForSequence()
                
                // If the shutter button has been released before the notification has arrived
                if shutterButtonHasBeenReleased == true {
                    self.sequenceManager.cancel()
                } else {
                    feedbackViewController.circleTimer?.updateProgress(0.4)
                    
                    // 1 = true, 0 = false
                    feedbackViewController.circleTimer?.indeterminate = 1
                    
                    feedbackViewController.startAnimations()
                    self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: Double.infinity, unit: .hours))]), repeatSequence: false)
                }
            }
        }
    }
    
    override func activeViewControllerLostFocus() {
        super.activeViewControllerLostFocus()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is PressAndHoldViewController {
            self.sequenceManager.cancel()
        }
    }
}
