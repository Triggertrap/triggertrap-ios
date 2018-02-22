//
//  StarTrailViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class StarTrailViewController: TTViewController, TTNumberInputDelegate {
    
    @IBOutlet weak var exposureNumberInputView: TTNumberInput!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationNumberInputView: TTTimeInput!
    @IBOutlet weak var gapLabel: UILabel!
    @IBOutlet weak var gapNumberInputView: TTTimeInput!
    
    fileprivate var shotsTakenCount = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNumberPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load the previous value
        exposureNumberInputView.value = exposureNumberInputView.savedValue(forKey: "starTrail-exposures")
        durationNumberInputView.value = durationNumberInputView.savedValue(forKey: "starTrail-duration")
        gapNumberInputView.value = gapNumberInputView.savedValue(forKey: "starTrail-gap")
        
        NotificationCenter.default.addObserver(self, selector: Selector(("didTrigger:")), name: NSNotification.Name(rawValue: "kTTDongleDidTriggerNotification"), object: nil)
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    // MARK: - IBAction
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                shotsTakenCount = 0
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierExposureAndPauseFeedbackView)
                
                feedbackViewController.shotsTakenLabel?.text = "0/\(exposureNumberInputView.value)"
                
                //Number of exposures multiplied by duration of the exposure + gap minus the last gap
                let interval: Double = Double((exposureNumberInputView.value * (durationNumberInputView.value + gapNumberInputView.value) - gapNumberInputView.value) / CUnsignedLongLong(1000.0))
                
                //Setup counter label and circle timer so that they are populated when red view animates
                feedbackViewController.counterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                feedbackViewController.counterLabel?.startValue = CUnsignedLongLong(interval * 1000.0)
                
                feedbackViewController.circleTimer?.cycleDuration = interval
                feedbackViewController.circleTimer?.progress = 1.0
                feedbackViewController.circleTimer?.progressDirection = kProgressDirection.progressDirectionAntiClockwise.rawValue
                
                feedbackViewController.pauseCounterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                feedbackViewController.exposureCounterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
            }
            
        } else {
            sequenceManager.cancel()
        }
    }
    
    @IBAction func openKeyboard(_ sender : TTTimeInput) {
        sender.openKeyboard(in: self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Private
    
    fileprivate func setupNumberPickers() {
        exposureNumberInputView.delegate = self
        exposureNumberInputView.minValue = 1
        exposureNumberInputView.maxNumberLength = 5
        exposureNumberInputView.maxValue = 99999
        exposureNumberInputView.value = 10
        exposureNumberInputView.displayView.textAlignment = NSTextAlignment.center
        
        durationNumberInputView.delegate = self
        durationNumberInputView.maxValue = 359999990 // = 99 hours  99 mins ...
        durationNumberInputView.value = 90000 // default 1 min 30 secs
        durationNumberInputView.displayView.textAlignment = NSTextAlignment.center
        durationNumberInputView.minValue = 0
        
        gapNumberInputView.delegate = self
        gapNumberInputView.maxValue = 359999990 // = 99 hours  99 mins ...
        gapNumberInputView.value = 5000 // default 5 secs
        gapNumberInputView.displayView.textAlignment = NSTextAlignment.center;
        gapNumberInputView.minValue = 0
    }
    
    override func willDispatch(_ dispatchable: Dispatchable) {
        super.willDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is StarTrailViewController && dispatchable is Pulse {
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = 0
            
            feedbackViewController.exposureCounterLabel?.startValue = durationNumberInputView.value
            feedbackViewController.exposureCounterLabel?.start()
        }
        if let activeViewController = sequenceManager.activeViewController, activeViewController is StarTrailViewController && dispatchable is Delay {
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = gapNumberInputView.value
            feedbackViewController.pauseCounterLabel?.start()
            
            feedbackViewController.exposureCounterLabel?.stop()
            feedbackViewController.exposureCounterLabel?.startValue = 0
        }
    }
    
    // MARK: - Public
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is StarTrailViewController {
            
            //Start counter label and circle timer
            feedbackViewController.startAnimations()
            
            let pulse = Pulse(time: Time(duration: Double(durationNumberInputView.value), unit: .milliseconds))
            let delay = Delay(time: Time(duration: Double(gapNumberInputView.value), unit: .milliseconds))
            
            let sequence = SequenceCalculator.sharedInstance.starTrailSequenceForExposures(Int(exposureNumberInputView.value), pulse: pulse, delay: delay)
            
            prepareForSequence()
            
            //Start sequence
            sequenceManager.play(sequence, repeatSequence: false)
        }
    }
    
    override func didDispatch(_ dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is StarTrailViewController && dispatchable is Pulse {
            shotsTakenCount += 1
            feedbackViewController.shotsTakenLabel?.text = "\(shotsTakenCount)/\(exposureNumberInputView.value)"
        }
    }
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        applyThemeUpdateToNumberInput(exposureNumberInputView)
        applyThemeUpdateToTimeInput(durationNumberInputView)
        applyThemeUpdateToTimeInput(gapNumberInputView) 
        
        durationLabel.textColor = UIColor.triggertrap_foregroundColor()
        gapLabel.textColor = UIColor.triggertrap_foregroundColor()
        
    }
    
    // MARK: - TTNumberInput Delegate
    
    func ttNumberInputKeyboardDidDismiss() {
        exposureNumberInputView.saveValue(exposureNumberInputView.value, forKey: "starTrail-exposures")
        durationNumberInputView.saveValue(durationNumberInputView.value, forKey: "starTrail-duration")
        gapNumberInputView.saveValue(gapNumberInputView.value, forKey: "starTrail-gap")
    }
}

extension StarTrailViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}
