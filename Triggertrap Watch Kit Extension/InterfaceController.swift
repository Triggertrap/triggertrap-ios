//
//  InterfaceController.swift
//  Timelapse Pro WatchKit Extension
//
//  Created by Valentin Kalchev on 18/05/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import WatchKit
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var animationGroup: WKInterfaceGroup!
    @IBOutlet weak var triggerButton: WKInterfaceButton!
    @IBOutlet weak var slider: WKInterfaceSlider!
    @IBOutlet weak var timer: WKInterfaceTimer!
    
    private var session: WCSession?
    private var delay: Double = 0.0
    private var isTriggering = false
    private var delayTimer: NSTimer?
    
    // MARK: - Lifecycle
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    }
    
    override func willActivate() {
        
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        isTriggering = false
        
        // Enable the slider
        slider.setEnabled(true)
        timer.stop()
        
        delay == 0 ? timer.setDate(NSDate(timeIntervalSinceNow: 0)) : timer.setDate(NSDate(timeIntervalSinceNow: Double(delay + 1)))
        
        // Stop the animation and set its default image
        animationGroup.stopAnimating()
        animationGroup.setBackgroundImageNamed("WatchShutterButton0")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        // Stop the timer
        timer.stop()
        delayTimer?.invalidate()
    }
    
    // MARK: - Actions
    
    @IBAction func triggerButtonTapped(button: WKInterfaceButton) {
        
        // Start or stop the countdown
        !isTriggering ? startCountdown() : stopCountdown(false)
        isTriggering = !isTriggering
    }
    
    @IBAction func sliderValueChanged(value: Float) {
        delay = Double(value)
        delay == 0 ? timer.setHidden(true) : timer.setHidden(false)
        
        // Apple watch has a delay of 1 sec before it updates the timer
        timer.setDate(NSDate(timeIntervalSinceNow: Double(value + 1.0)))
    }
    
    // MARK: - Private
    
    private func startCountdown() {
        
        // Disable the slider
        slider.setEnabled(false)
        
        // Set timer value and start it
        timer.setDate(NSDate(timeIntervalSinceNow: delay))
        timer.start()
        
        animationGroup.setBackgroundImageNamed("WatchShutterButton")
        
        if delay == 0 {
            // Animate the watch shutter button once for 1 sec
            animationGroup.startAnimatingWithImagesInRange(NSMakeRange(4, 29), duration: 1.0, repeatCount: 1)
            
            // 1 sec animation and then trigger
            delayStopCountdown(1.0, triggerInstantly: true)
        } else {
            
            // Animate the watch shutter button until it gets stoped from the stopCountdown()
            animationGroup.startAnimatingWithImagesInRange(NSMakeRange(4, 29), duration: 1.0, repeatCount: 0)
            
            delayStopCountdown(delay, triggerInstantly: false)
        }
    }
    
    private func delayStopCountdown(seconds: Double, triggerInstantly: Bool) {
        
        // Send signal to the main app before the countdown
        if triggerInstantly {
            session?.sendMessage(["trigger": true], replyHandler: nil, errorHandler: { (error) -> Void in
                print("Error:\(error)")
            })
        }
        
        delayTimer = NSTimer(timeInterval: seconds, target: self, selector: #selector(InterfaceController.delayTimer(_:)), userInfo: ["triggerInstantly": triggerInstantly], repeats: false)
        NSRunLoop.mainRunLoop().addTimer(delayTimer!, forMode: NSDefaultRunLoopMode)
    }
    
    func delayTimer(timer: NSTimer) {
        
        let userInfo: Dictionary<String, Bool!> = timer.userInfo as! Dictionary<String, Bool!>
        
        if let triggerInstantly = userInfo["triggerInstantly"] {
            self.stopCountdown(!triggerInstantly)
            self.isTriggering = false
        }
    }
    
    private func stopCountdown(trigger: Bool) {
        
        // Send signal to the main app
        if trigger {
            session?.sendMessage(["trigger": true], replyHandler: nil, errorHandler: { (error) -> Void in
                print("Error:\(error)")
            })
        }
        
        delayTimer?.invalidate()
        
        // Enable the slider
        self.slider.setEnabled(true)
        
        // Stop the animation and set its default image
        animationGroup.stopAnimating()
        animationGroup.setBackgroundImageNamed("WatchShutterButton0")
        
        // Stop the timer and set its value
        self.timer.stop()
        self.timer.setDate(NSDate(timeIntervalSinceNow: delay + 1.0))
    }
}

extension InterfaceController: WCSessionDelegate {
    func sessionReachabilityDidChange(session: WCSession) {
        
    }
}
