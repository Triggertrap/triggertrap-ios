//
//  PressAndHoldViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class PressAndHoldViewController: CableReleaseViewController {
    
    private var notificationReceived = false
    private var shutterButtonHasBeenReleased = false
    
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
    
    @IBAction func shutterButtonTouchDown(sender : UIButton) {
        
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
    
    @IBAction func shutterButtonTouchUpInside(sender : UIButton) {
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is PressAndHoldViewController {
            if notificationReceived == true {
                 self.sequenceManager.cancel()
            } else {
                shutterButtonHasBeenReleased = true;
            }
        }
    }
    
    @IBAction func shutterButtonTouchUpOutside(sender : UIButton) {
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is PressAndHoldViewController {
            if notificationReceived == true {
                self.sequenceManager.cancel()
            } else {
                shutterButtonHasBeenReleased = true
            }
        }
    }
    
    @IBAction func shutterButtonTouchDragOutside(sender : UIButton, event: UIEvent) {
        let touches = event.allTouches()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is PressAndHoldViewController {
            if let touches = touches, firstTouch = touches.first {
                let point = firstTouch.locationInView(sender)
                
                if sender.pointInside(point, withEvent: event) == false {
                    // The touch has dragged outside of the active area of the button
                    self.sequenceManager.cancel()
                }
            }
        }
    }
    
    // MARK: - Overrides
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is PressAndHoldViewController {
            
            if notificationReceived == false {
                notificationReceived = true
                prepareForSequence()
                
                // If the shutter button has been released before the notification has arrived
                if shutterButtonHasBeenReleased == true {
                    self.sequenceManager.cancel()
                } else {
                    feedbackViewController.circleTimer?.progress = 0.4
                    
                    // 1 = true, 0 = false
                    feedbackViewController.circleTimer?.indeterminate = 1
                    
                    feedbackViewController.startAnimations()
                    self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: Double.infinity, unit: .Hours))]), repeatSequence: false)
                }
            }
        }
    }
    
    override func activeViewControllerLostFocus() {
        super.activeViewControllerLostFocus()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is PressAndHoldViewController {
            self.sequenceManager.cancel()
        }
    }
}
