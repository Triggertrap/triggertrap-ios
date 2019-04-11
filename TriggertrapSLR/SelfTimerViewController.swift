//
//  SelfTimerViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit
import TTCounterLabel

class SelfTimerViewController: CableReleaseViewController, TTNumberInputDelegate {
    
    @IBOutlet weak var numberInputView: TTTimeInput!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNumberPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check whether settings manager pulse length has been changed and it is less than the numberInputView value
        if self.numberInputView.savedValue(forKey: "selfTimerCableRelease-duration") < (settingsManager?.pulseLength.uint64Value)!  {
            self.numberInputView.saveValue((settingsManager?.pulseLength.uint64Value)! , forKey: "selfTimerCableRelease-duration")
        }
        
        // Load the previous value
        self.numberInputView.value = self.numberInputView.savedValue(forKey: "selfTimerCableRelease-duration")
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        WearablesManager.sharedInstance.delegate = nil
    }

    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierCableReleaseFeedbackView)
                
                //Setup counter label and circle timer so that they are populated when red view animates
                feedbackViewController.counterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue;
                feedbackViewController.counterLabel?.startValue = self.numberInputView.value
                
                feedbackViewController.circleTimer?.cycleDuration = Double(self.numberInputView.value) / 1000.0
                feedbackViewController.circleTimer?.continuous = false
                feedbackViewController.circleTimer?.updateProgress(1.0)
                feedbackViewController.circleTimer?.progressDirection = .AntiClockwise
            }
            
        } else {
            sequenceManager.cancel()
        }
    }
    
    @IBAction func openKeyboard(_ sender : TTTimeInput) {
        adjustMinVal()
        sender.openKeyboard(in: self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Overrides
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is SelfTimerViewController {
        
            prepareForSequence()
            
            //Start sequence
            let pulse = Pulse(time: Time(duration: settingsManager!.pulseLength.doubleValue, unit: .milliseconds))
            let delay = Delay(time: Time(duration: Double(self.numberInputView.value), unit: .milliseconds))
            self.sequenceManager.play(Sequence(modules: [delay, pulse]), repeatSequence: false)
            
            feedbackViewController.startAnimations()
        }
    }
    
    // MARK: - Private
    
    func setupNumberPicker() {
        self.numberInputView.delegate = self;
        self.numberInputView.maxValue = 359999990;
        self.numberInputView.value = 30000;
        adjustMinVal()
        self.numberInputView.displayView.textAlignment = NSTextAlignment.center
    }
    
    func adjustMinVal() {
        self.numberInputView.minValue = SettingsManager.sharedInstance().pulseLength.uint64Value
    }
    
    // MARK: - Theme change
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        applyThemeUpdateToTimeInput(numberInputView) 
    }
    
    // MARK: - TTNumberInputKeyboardDelegate
    
    func ttNumberInputKeyboardDidDismiss() {
        self.numberInputView.saveValue(self.numberInputView.value, forKey: "selfTimerCableRelease-duration")
    }

}

extension SelfTimerViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton()) 
    }
}
