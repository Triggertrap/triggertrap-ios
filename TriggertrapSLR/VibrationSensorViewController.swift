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
    
    fileprivate var sensitivityValue: Float = 0.0
    fileprivate let motionManager = CMMotionManager()
    fileprivate let filter = HighpassFilter(sampleRate: 30.0, cutoffFrequency: 5.0)
    fileprivate var isTriggering = false
    fileprivate var shouldPopNameLabel = false
    
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
        circularVibrationLevel.isUserInteractionEnabled = false
        
        sensitivityValue = -2.5
        
        motionManager.accelerometerUpdateInterval = 1.0 / 10.0
        filter?.isAdaptive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: Selector(("didTrigger:")), name: NSNotification.Name(rawValue: "kTTDongleDidTriggerNotification"), object: nil)
        
        let previousVibrationThreshold  = UserDefaults.standard.float(forKey: "lastUsedVibrationThreshold")
        
        if previousVibrationThreshold != 0.0 {
            sensitivityValue = UserDefaults.standard.float(forKey: "lastUsedVibrationThreshold")
            circularSlider.value = sensitivityValue
        } else {
            sensitivityValue = -4.825
            circularSlider.value = sensitivityValue
        } 

        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {
                accelerometerData, error in
                let acceleration: CMAcceleration = accelerometerData!.acceleration
                self.filter?.add(acceleration)
                
                let magnitude: Float = sqrt(Float(self.filter!.x * self.filter!.x + self.filter!.y * self.filter!.y + self.filter!.z * self.filter!.z) / 3.0)
                
                DispatchQueue.main.async(execute: {
                    self.circularVibrationLevel.value = logf(magnitude)
                })
                
                if logf(magnitude) > self.sensitivityValue && (self.isTriggering == true) {
                    
                    if let activeViewController = self.sequenceManager.activeViewController, activeViewController is VibrationSensorViewController {
                        self.prepareForSequence()
                        self.triggerNow()
                    }
                }
            })
        }
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        motionManager.stopAccelerometerUpdates()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
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
    
    override func willDispatch(_ dispatchable: Dispatchable) {
        super.willDispatch(dispatchable)
        popNameLabelText(true)
    }
    
    override func didDispatch(_ dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        popNameLabelText(false)
    }
    
    fileprivate func popNameLabelText(_ popLabel: Bool) {
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
        case .normal:
            circularSlider.thumbImage = "slider-thumb"
            break
        case .night:
            circularSlider.thumbImage = "slider-thumb_night"
            break
        }
        
        circularVibrationLevel.minimumTrackTintColor = UIColor.triggertrap_primaryColor()
        circularVibrationLevel.maximumTrackTintColor = UIColor.triggertrap_naturalColor()
        
        nameLabel.textColor = UIColor.triggertrap_foregroundColor()
    }
    
    // MARK: - CicularSliderDelegate
    
    func circularSliderValueChanged(_ newValue: NSNumber!) {
        sensitivityValue = newValue.floatValue
        
        UserDefaults.standard.set(sensitivityValue, forKey: "lastUsedVibrationThreshold")
        UserDefaults.standard.synchronize()
    }
}

extension VibrationSensorViewController: WearableManagerDelegate {
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}
