//
//  VibrationSensorViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class VibrationSensorViewController: SensorViewController, CicularSliderDelegate {
    
    // MARK: - Overrides

    @IBOutlet var circularSlider: TTCircularSlider!
    @IBOutlet var circularVibrationLevel: TTCircularSlider!
    @IBOutlet var nameLabel: UILabel!
    
    // MARK: - Properties
    
    private var sensitivityValue: Float = 0.0
    private let motionManager = CMMotionManager()
    private let filter = HighpassFilter(sampleRate: 30.0, cutoffFrequency: 5.0)
    private var isTriggering = false
    private var shouldPopNameLabel = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circularSlider.delegate = self
        circularSlider.minimumValue = -6.2
        circularSlider.maximumValue = -3.91
        
        circularVibrationLevel.minimumValue = -6.2
        circularVibrationLevel.maximumValue = -3.91
        circularVibrationLevel.lineWidth = 12.0
        circularVibrationLevel.thumbImage = nil
        circularVibrationLevel.userInteractionEnabled = false
        
        sensitivityValue = -2.5
        
        motionManager.accelerometerUpdateInterval = 1.0 / 10.0
        filter.adaptive = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didTrigger:"), name: "kTTDongleDidTriggerNotification", object: nil)
        
        let previousVibrationThreshold  = NSUserDefaults.standardUserDefaults().floatForKey("lastUsedVibrationThreshold")
        
        if previousVibrationThreshold != 0.0 {
            sensitivityValue = NSUserDefaults.standardUserDefaults().floatForKey("lastUsedVibrationThreshold")
            circularSlider.value = sensitivityValue
        } else {
            sensitivityValue = -4.825
            circularSlider.value = sensitivityValue
        } 

        if motionManager.accelerometerAvailable {
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: {
                accelerometerData, error in
                let acceleration: CMAcceleration = accelerometerData!.acceleration
                self.filter.addAcceleration(acceleration)
                
                let magnitude: Float = sqrt(Float(self.filter.x * self.filter.x + self.filter.y * self.filter.y + self.filter.z * self.filter.z) / 3.0)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.circularVibrationLevel.value = logf(magnitude)
                })
                
                if logf(magnitude) > self.sensitivityValue && (self.isTriggering == true) {
                    
                    if let activeViewController = self.sequenceManager.activeViewController where activeViewController is VibrationSensorViewController {
                        self.prepareForSequence()
                        self.triggerNow()
                    }
                }
            })
        }
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        circularSlider.setNeedsDisplay()
        circularVibrationLevel.setNeedsDisplay()
    } 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        motionManager.stopAccelerometerUpdates()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            if sufficientVolumeToTrigger() {
                waitingForSensorResetDelay = false
                sequenceManager.activeViewController = self
                isTriggering = true
                startShutterButtonAnimation()
            }
            
        } else {
            isTriggering = false
            stopShutterButtonAnimation()
            sequenceManager.cancel() 
            popNameLabelText(false)
        }
    }
    
    // MARK: - Overrides
    
    override func willDispatch(dispatchable: Dispatchable) {
        super.willDispatch(dispatchable)
        popNameLabelText(true)
    }
    
    override func didDispatch(dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        popNameLabelText(false)
    }
    
    private func popNameLabelText(popLabel: Bool) {
        if popLabel {
            shouldPopNameLabel = true
            pop(nameLabel, fromScale: 1.0, toScale: 2.6)
            nameLabel.textColor = UIColor.triggertrap_primaryColor(1.0)
        } else {
            if shouldPopNameLabel == true {
                shouldPopNameLabel = false
                pop(nameLabel, fromScale: 2.6, toScale: 1.0)
                nameLabel.textColor = UIColor.triggertrap_foregroundColor(1.0)
            }
        }
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        circularSlider.minimumTrackTintColor = UIColor.triggertrap_primaryColor()
        circularSlider.maximumTrackTintColor = UIColor.triggertrap_naturalColor()
        
        switch AppTheme() {
        case .Normal:
            circularSlider.thumbImage = "slider-thumb"
            break
        case .Night:
            circularSlider.thumbImage = "slider-thumb_night"
            break
        }
        
        circularVibrationLevel.minimumTrackTintColor = UIColor.triggertrap_primaryColor()
        circularVibrationLevel.maximumTrackTintColor = UIColor.triggertrap_naturalColor()
        
        nameLabel.textColor = UIColor.triggertrap_foregroundColor()
    }
    
    // MARK: - CicularSliderDelegate
    
    func circularSliderValueChanged(newValue: NSNumber!) {
        sensitivityValue = newValue.floatValue
        
        NSUserDefaults.standardUserDefaults().setFloat(sensitivityValue, forKey: "lastUsedVibrationThreshold")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

extension VibrationSensorViewController: WearableManagerDelegate {
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}
