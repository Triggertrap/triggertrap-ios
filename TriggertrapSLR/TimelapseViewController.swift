//
//  TimelapseViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class TimelapseViewController: TTViewController, TTNumberInputDelegate {
    @IBOutlet weak var numberInputView: TTTimeInput!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    fileprivate var numberOfShotsTaken = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNumberPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check whether settings manager pulse length has been changed and it is less than the numberInputView value
        if self.numberInputView.savedValue(forKey: "timelapse-interval") < ((settingsManager?.pulseLength.uint64Value)! + CUnsignedLongLong(kMinimumGap))  {
            self.numberInputView.saveValue((settingsManager?.pulseLength.uint64Value)! + CUnsignedLongLong(kMinimumGap) , forKey: "timelapse-interval")
        }
        
        // Load the previous value
        self.numberInputView.value = self.numberInputView.savedValue(forKey: "timelapse-interval")
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    fileprivate func setupNumberPicker() {
        self.numberInputView.delegate = self
        self.numberInputView.maxValue = 359999990
        
        if ((settingsManager?.pulseLength.uint64Value)! + CUnsignedLongLong(kMinimumGap) < 1000) {
            //Default to use 1 second
            self.numberInputView.value = 1000
        } else {
            self.numberInputView.value = (settingsManager?.pulseLength.uint64Value)! + CUnsignedLongLong(kMinimumGap)
        }
        
        adjustMinVal()
        self.numberInputView.displayView.textAlignment = NSTextAlignment.center
    }
    
    fileprivate func adjustMinVal() {
        self.numberInputView.minValue = SettingsManager.sharedInstance().pulseLength.uint64Value
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                numberOfShotsTaken = 0 
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierElapsedFeedbackView)
                
                //Setup counter label and circle timer so that they are populated when red view animates
                feedbackViewController.counterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue;
                feedbackViewController.counterLabel?.startValue = self.numberInputView.value
                
                feedbackViewController.circleTimer?.cycleDuration = Double(self.numberInputView.value) / 1000.0
                feedbackViewController.circleTimer?.progress = 1.0
                feedbackViewController.circleTimer?.progressDirection = kProgressDirection.progressDirectionAntiClockwise.rawValue
            }
        } else {
            sequenceManager.cancel()
        }
    }
    
    @IBAction func openKeyboard(_ sender : TTTimeInput) {
        adjustMinVal()
        sender.openKeyboard(in: self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Public
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is TimelapseViewController {
            
            let pauseDuration = NSNumber(value: self.numberInputView.value - (settingsManager?.pulseLength.uint64Value)! as UInt64)
            
            let pulse = Pulse(time: Time(duration: settingsManager!.pulseLength.doubleValue, unit: .milliseconds))
            let delay = Delay(time: Time(duration: pauseDuration.doubleValue, unit: .milliseconds)) 
            
            prepareForSequence()
            self.sequenceManager.play(Sequence(modules: [pulse, delay]), repeatSequence: true)
            feedbackViewController.startAnimations()
        }
    }
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        descriptionLabel.textColor = UIColor.triggertrap_foregroundColor()
        applyThemeUpdateToTimeInput(numberInputView) 
    }
    
    // MARK: - TTNumberInputKeyboardDelegate
    
    func ttNumberInputKeyboardDidDismiss() {
        
        if (self.numberInputView.value < (settingsManager?.pulseLength.uint64Value)! + CUnsignedLongLong(kMinimumGap)) {
            self.numberInputView.value = (settingsManager?.pulseLength.uint64Value)! + CUnsignedLongLong(kMinimumGap)
        }
        
        self.numberInputView.saveValue(self.numberInputView.value, forKey: "timelapse-interval")
    }
    
    override func willDispatch(_ dispatchable: Dispatchable) {
        super.willDispatch(dispatchable)
         
        if let activeViewController = sequenceManager.activeViewController, activeViewController is TimelapseViewController && dispatchable is Pulse {
            
            feedbackViewController.counterLabel?.reset()
            feedbackViewController.counterLabel?.start()
            
            // Reset circle timer
            feedbackViewController.circleTimer?.stop()
            feedbackViewController.circleTimer?.start()
            
            numberOfShotsTaken += 1
            
            feedbackViewController.shotsTakenLabel?.text = "\(numberOfShotsTaken)"
        }
    }
}

extension TimelapseViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton()) 
    }
}
