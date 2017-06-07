//
//  WearablesViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 07/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class WearablesViewController: TTViewController {
    
    // MARK: References
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var infoText: UILabel!
    
    // Connected wearable device.
    private enum WearableDevice {
        case Pebble, AppleWatch
    }
    
    private var selectedDevice: WearableDevice = .Pebble {
        didSet {
            switch selectedDevice {
            case .Pebble:
                infoText.text = NSLocalizedString("Tap on the red button to start listening for your Pebble. Once Wearables mode is active just open any mode that supports wearable triggering, setup the mode just how you like it, and press the trigger button on your Pebble.", comment: "Tap on the red button to start listening for your Pebble. Once Wearables mode is active just open any mode that supports wearable triggering, setup the mode just how you like it, and press the trigger button on your Pebble.")
                
                shutterButtonEnabled(PebbleManager.sharedInstance.isPebbleConnected)
                
                break
                
            case .AppleWatch:
                infoText.text = NSLocalizedString("Tap on the red button to start listening for your Apple Watch. Once Wearables mode is active just open any mode that supports wearable triggering, setup the mode just how you like it, and press the trigger button on your Apple Watch.", comment: "Tap on the red button to start listening for your Apple Watch. Once Wearables mode is active just open any mode that supports wearable triggering, setup the mode just how you like it, and press the trigger button on your Apple Watch.")
                
                shutterButtonEnabled(true)
                
                break
            }
        }
    }
    
    private var pebbleIsSelected: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(constPebbleIsSelected)
        } set (newValue) {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: constPebbleIsSelected)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.triggertrap_metric_light(20.0)]
            , forState: .Normal)
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.triggertrap_metric_light(20.0)]
            , forState: .Selected)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If an activity is already running, don't allow the user to start or stop wearables.
        // They must stop the running activity first, either from the watch, or the running mode.
        
        if sequenceManager.activeViewController == nil {
            shutterButtonEnabled(true)
        } else {
            shutterButtonEnabled(false)
        }
        
        dispatch_async(dispatch_get_main_queue(),{
            // Check if wearables is running, and show the feedback view, if it is.
            if WearablesManager.sharedInstance.isWearablesModeRunning() {
                if self.selectedDevice == .Pebble {
                    // If the selected mode is Pebble, but no device is connected
                    // stop the service.
                    if !PebbleManager.sharedInstance.isPebbleConnected {
                        self.stopWearableMode()
                    }
                }
                
                self.showFeedbackView(ConstStoryboardIdentifierInfoFeedbackView)
            } else {
                self.hideFeedbackView()
            }
            
        })
        
        // Register to receieve notification.
        addNotificationObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(),{
            // Select the correct segment from the segmented control.
            self.segmentedControl.selectedSegmentIndex = self.pebbleIsSelected ? 0 : 1
            self.selectedDevice = self.pebbleIsSelected ? WearableDevice.Pebble : WearableDevice.AppleWatch
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove notification observers.
        removeNotificationObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // Remove notification observers.
        removeNotificationObservers()
    }
    
    // MARK: Actions
    
    @IBAction func segmentedControllerPressed(segmentedController: UISegmentedControl) {
        // Check for the selected segment, Pebble or Apple Watch.
        pebbleIsSelected = segmentedController.selectedSegmentIndex == 0 ? true : false
        selectedDevice = pebbleIsSelected ? WearableDevice.Pebble : WearableDevice.AppleWatch
    }
    
    @IBAction func shutterButtonTouchUpInside(sender: UIButton) {
        
        // Open the Triggertrap app on the connected Pebble device, if there is one.
        if !WearablesManager.sharedInstance.isWearablesModeRunning() && PebbleManager.sharedInstance.isPebbleConnected {
            dispatch_async(dispatch_get_main_queue(),{
                 PebbleManager.sharedInstance.openPebbleApp()
            })
        }
        
        WearablesManager.sharedInstance.isWearablesModeRunning() ? stopWearableMode() : startWearableMode()
    }
    
    // MARK: - Notifications
    
    func pebbleWatchStatusChanged(notification: NSNotification) {
        
        if selectedDevice == .Pebble {
            let userInfo: Dictionary<String, Bool> = notification.userInfo as! Dictionary<String, Bool>
            // TODO: Is "connected" a key word? If so it should be a constant.
            let connected = userInfo["connected"]
            
            if let connected = connected {
                
                if WearablesManager.sharedInstance.isWearablesModeRunning() && !connected {
                    stopWearableMode()
                }
                
                // TODO: Is this really needed? It should be set once
                // in start/stopWearableMode.
                shutterButtonEnabled(connected)
            }
        }
    }
    
    override func feedbackViewHideAnimationCompleted() {
        super.feedbackViewHideAnimationCompleted()
        
        switch selectedDevice {
        case .Pebble:
            shutterButtonEnabled(PebbleManager.sharedInstance.isPebbleConnected)
            break
            
        case .AppleWatch:
            shutterButtonEnabled(true)
            break
        }
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        segmentedControl.tintColor = UIColor.triggertrap_primaryColor()
        infoText.textColor = UIColor.triggertrap_foregroundColor()
    }
    
    // MARK: Private
    
    private func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WearablesViewController.pebbleWatchStatusChanged(_:)), name: constPebbleWatchStatusChanged, object: nil)
    }
    
    private func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: constPebbleWatchStatusChanged, object: nil)
    }
    
    private func startWearableMode() {
        dispatch_async(dispatch_get_main_queue(),{
            self.showFeedbackView(ConstStoryboardIdentifierInfoFeedbackView)
            WearablesManager.sharedInstance.startSession()
            self.startShutterButtonAnimation()
            
            switch self.selectedDevice {
            case .Pebble:
                self.feedbackViewController.infoLabel?.text = String(format: NSLocalizedString("Listening for your wearable. Navigate to a Wearables compatible mode, and you’re ready to use your Wearable to trigger your camera.", comment: "Listening for your wearable. Navigate to a Wearables compatible mode, and you’re ready to use your Wearable to trigger your camera."))
                break
                
            case .AppleWatch:
                self.feedbackViewController.infoLabel?.text = String(format: NSLocalizedString("Listening for your wearable. Navigate to a Wearables compatible mode, and you’re ready to use your Wearable to trigger your camera.", comment: "Listening for your wearable. Navigate to a Wearables compatible mode, and you’re ready to use your Wearable to trigger your camera."))
                break
            }
        })
    }
    
    private func stopWearableMode() {
        dispatch_async(dispatch_get_main_queue(),{
            self.hideFeedbackView()
            WearablesManager.sharedInstance.endSession()
            self.stopShutterButtonAnimation()
        })
    }
}
