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
    fileprivate enum WearableDevice {
        case appleWatch
    }
    
    fileprivate var selectedDevice: WearableDevice = .appleWatch {
        didSet {
            switch selectedDevice {
            case .appleWatch:
                infoText.text = NSLocalizedString("Tap on the red button to start listening for your Apple Watch. Once Wearables mode is active just open any mode that supports wearable triggering, setup the mode just how you like it, and press the trigger button on your Apple Watch.", comment: "Tap on the red button to start listening for your Apple Watch. Once Wearables mode is active just open any mode that supports wearable triggering, setup the mode just how you like it, and press the trigger button on your Apple Watch.")
                
                shutterButtonEnabled(true)
                
                break
            }
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.triggertrap_metric_light(20.0)]
            , for: UIControl.State())
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.triggertrap_metric_light(20.0)]
            , for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If an activity is already running, don't allow the user to start or stop wearables.
        // They must stop the running activity first, either from the watch, or the running mode.
        
        if sequenceManager.activeViewController == nil {
            shutterButtonEnabled(true)
        } else {
            shutterButtonEnabled(false)
        }
        
        DispatchQueue.main.async(execute: {
            // Check if wearables is running, and show the feedback view, if it is.
            if WearablesManager.sharedInstance.isWearablesModeRunning() {
                self.showFeedbackView(ConstStoryboardIdentifierInfoFeedbackView)
            } else {
                self.hideFeedbackView()
            }
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async(execute: {
            // Select the correct segment from the segmented control.
            self.segmentedControl.selectedSegmentIndex = 1
            self.selectedDevice = WearableDevice.appleWatch
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func segmentedControllerPressed(_ segmentedController: UISegmentedControl) {
        // Check for the selected segment Apple Watch.
        selectedDevice = WearableDevice.appleWatch
    }
    
    @IBAction func shutterButtonTouchUpInside(_ sender: UIButton) {
        WearablesManager.sharedInstance.isWearablesModeRunning() ? stopWearableMode() : startWearableMode()
    }
    
    // MARK: - Notifications
    
    override func feedbackViewHideAnimationCompleted() {
        super.feedbackViewHideAnimationCompleted()
        
        switch selectedDevice {
        case .appleWatch:
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
    
    fileprivate func startWearableMode() {
        DispatchQueue.main.async(execute: {
            self.showFeedbackView(ConstStoryboardIdentifierInfoFeedbackView)
            WearablesManager.sharedInstance.startSession()
            self.startShutterButtonAnimation()
            
            switch self.selectedDevice {
            case .appleWatch:
                self.feedbackViewController.infoLabel?.text = String(format: NSLocalizedString("Listening for your wearable. Navigate to a Wearables compatible mode, and you’re ready to use your Wearable to trigger your camera.", comment: "Listening for your wearable. Navigate to a Wearables compatible mode, and you’re ready to use your Wearable to trigger your camera."))
                break
            }
        })
    }
    
    fileprivate func stopWearableMode() {
        DispatchQueue.main.async(execute: {
            self.hideFeedbackView()
            WearablesManager.sharedInstance.endSession()
            self.stopShutterButtonAnimation()
        })
    }
}
