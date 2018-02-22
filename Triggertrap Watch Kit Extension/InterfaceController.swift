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
    
    fileprivate var session: WCSession?
    fileprivate var delay: Double = 0.0
    fileprivate var isTriggering = false
    fileprivate var delayTimer: Timer?
    
    // MARK: - Lifecycle
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    override func willActivate() {
        
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        isTriggering = false
        
        // Enable the slider
        slider.setEnabled(true)
        timer.stop()
        
        delay == 0 ? timer.setDate(Date(timeIntervalSinceNow: 0)) : timer.setDate(Date(timeIntervalSinceNow: Double(delay + 1)))
        
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
    
    @IBAction func triggerButtonTapped(_ button: WKInterfaceButton) {
        
        // Start or stop the countdown
        !isTriggering ? startCountdown() : stopCountdown(false)
        isTriggering = !isTriggering
    }
    
    @IBAction func sliderValueChanged(_ value: Float) {
        delay = Double(value)
        delay == 0 ? timer.setHidden(true) : timer.setHidden(false)
        
        // Apple watch has a delay of 1 sec before it updates the timer
        timer.setDate(Date(timeIntervalSinceNow: Double(value + 1.0)))
    }
    
    // MARK: - Private
    
    fileprivate func startCountdown() {
        
        // Disable the slider
        slider.setEnabled(false)
        
        // Set timer value and start it
        timer.setDate(Date(timeIntervalSinceNow: delay))
        timer.start()
        
        animationGroup.setBackgroundImageNamed("WatchShutterButton")
        
        if delay == 0 {
            // Animate the watch shutter button once for 1 sec
            animationGroup.startAnimatingWithImages(in: NSMakeRange(4, 29), duration: 1.0, repeatCount: 1)
            
            // 1 sec animation and then trigger
            delayStopCountdown(1.0, triggerInstantly: true)
        } else {
            
            // Animate the watch shutter button until it gets stoped from the stopCountdown()
            animationGroup.startAnimatingWithImages(in: NSMakeRange(4, 29), duration: 1.0, repeatCount: 0)
            
            delayStopCountdown(delay, triggerInstantly: false)
        }
    }
    
    fileprivate func delayStopCountdown(_ seconds: Double, triggerInstantly: Bool) {
        
        // Send signal to the main app before the countdown
        if triggerInstantly {
            session?.sendMessage(["trigger": true], replyHandler: nil, errorHandler: { (error) -> Void in
                print("Error:\(error)")
            })
        }
        
        delayTimer = Timer(timeInterval: seconds, target: self, selector: #selector(InterfaceController.delayTimer(_:)), userInfo: ["triggerInstantly": triggerInstantly], repeats: false)
        RunLoop.main.add(delayTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    @objc func delayTimer(_ timer: Timer) {
        
        let userInfo: Dictionary<String, Bool?> = timer.userInfo as! Dictionary<String, Bool?>
        
        if let triggerInstantly = userInfo["triggerInstantly"] {
            self.stopCountdown(!triggerInstantly!)
            self.isTriggering = false
        }
    }
    
    fileprivate func stopCountdown(_ trigger: Bool) {
        
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
        self.timer.setDate(Date(timeIntervalSinceNow: delay + 1.0))
    }
}

extension InterfaceController: WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        
    }
}
