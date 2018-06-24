//
//  BrampingViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit
import TTCounterLabel

class BrampingViewController: TTViewController, HorizontalPickerDelegate, TTNumberInputDelegate {
    
    @IBOutlet weak var photosNumberInputView: TTNumberInput!
    @IBOutlet weak var exposuresLabel: UILabel!
    
    @IBOutlet weak var intervalNumberInputView: TTTimeInput!
    @IBOutlet weak var intervalLabel: UILabel!
    
    @IBOutlet weak var durationDisplayLabel: TTCounterLabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var startExposurePicker: HorizontalPicker!
    @IBOutlet weak var startExposureLabel: UILabel!
    
    @IBOutlet weak var endExposurePicker: HorizontalPicker!
    @IBOutlet weak var endExposureLabel: UILabel!
    
    fileprivate var maxValue = 0.0
    fileprivate var shotsTakenCount = 0
    fileprivate var currentPulseLength = 0
    
    fileprivate let kStartExposurePickerTag = 111
    fileprivate let kEndExposurePickerTag = 222
    
    fileprivate var sequence: Sequence!
    
    fileprivate var currentPulse = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHorizontalPickers()
        setupNumberPickers()
        
        durationDisplayLabel.boldFont = UIFont.triggertrap_openSans_bold(17.0)
        durationDisplayLabel.regularFont = UIFont.triggertrap_openSans_regular(17.0)
        durationDisplayLabel.font = UIFont.triggertrap_openSans_regular(13.0)
        durationDisplayLabel.textColor = UIColor.triggertrap_accentColor(1.0)
        
        durationDisplayLabel.updateApperance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        photosNumberInputView.value = photosNumberInputView.savedValue(forKey: "bramping-numberOfPhotos")
        
        intervalNumberInputView.value = intervalNumberInputView.savedValue(forKey: "bramping-duration")
        
        startExposurePicker.currentIndex = IndexPath(row:startExposurePicker.savedIndex(forKey: "bramping-startExposure"), section: 0)
        
        endExposurePicker.currentIndex = IndexPath(row:endExposurePicker.savedIndex(forKey: "bramping-endExposure") , section: 0)
        
        NotificationCenter.default.addObserver(self, selector: Selector(("didTrigger:")), name: NSNotification.Name(rawValue: "kTTDongleDidTriggerNotification"), object: nil)
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    } 
    
    // MARK: - IBActions
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                
                let brampingInterval = Double(intervalNumberInputView.value)
                
                let maxSelectedValue = round(max(Double(startExposurePicker.value), Double(endExposurePicker.value)))
                
                let minSelectedValue = round(min(Double(startExposurePicker.value), Double(endExposurePicker.value)))
                
                if brampingInterval < minSelectedValue || maxSelectedValue > brampingInterval {
                    
                    ShowAlertInViewController(self, title: NSLocalizedString("That's not long enough.", comment: "That's not long enough."), message: NSLocalizedString("Exposures need to be shorter than the interval. Choose a longer duration or shorter shutter speed.", comment: "Exposures need to be shorter than the interval. Choose a longer duration or shorter shutter speed."), cancelButton: NSLocalizedString("OK", comment: "OK")) 
                    
                    return
                }
                
                sequenceManager.activeViewController = self
                
                //Reset shots to 0
                shotsTakenCount = 0
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierExposureAndPauseFeedbackView)
                //Create sequence from number of photos, interval, start and end exposures
                
                sequence = SequenceCalculator.sharedInstance.brampingSequenceForExposures(Int(photosNumberInputView.value), firstExposure: Double(startExposurePicker.value), lastExposure: Double(endExposurePicker.value), interval: Double(intervalNumberInputView.value))
                
                currentPulse = 0
                
                //Calculate the length of the sequence
                let interval = sequence.durationInMilliseconds()
                
                //Set counter label and circle timer duration and count direction
                feedbackViewController.counterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                feedbackViewController.counterLabel?.startValue = CUnsignedLongLong(interval)
                
                feedbackViewController.circleTimer?.cycleDuration = interval / 1000.0
                feedbackViewController.circleTimer?.updateProgress(1.0)
                feedbackViewController.circleTimer?.progressDirection = .AntiClockwise
                
                feedbackViewController.pauseCounterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                feedbackViewController.exposureCounterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                feedbackViewController.shotsTakenLabel?.text = "0/\(Int(photosNumberInputView.value))"
            }
            
        } else {
            shotsTakenCount = 0
            sequenceManager.cancel()
        }
    }
    
    @IBAction func openKeyboard(_ sender : TTNumberInput) {
        sender.openKeyboard(in: self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Public
    
    override func willDispatch(_ dispatchable: Dispatchable) {
        super.willDispatch(dispatchable)
        if let activeViewController = sequenceManager.activeViewController, activeViewController is BrampingViewController && dispatchable is Pulse {
             
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = 0
            
            feedbackViewController.exposureCounterLabel?.startValue = UInt64(dispatchable.durationInMilliseconds())
            feedbackViewController.exposureCounterLabel?.start() 
        }
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is BrampingViewController && dispatchable is Delay {
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = UInt64(dispatchable.durationInMilliseconds())
            feedbackViewController.pauseCounterLabel?.start()
            
            feedbackViewController.exposureCounterLabel?.stop()
            feedbackViewController.exposureCounterLabel?.startValue = 0
        }
    }
    
    override func didDispatch(_ dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is BrampingViewController && dispatchable is Pulse {
            
            shotsTakenCount += 1
            feedbackViewController.shotsTakenLabel?.text = "\(shotsTakenCount)/\(Int(photosNumberInputView.value))"
        }
    }
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is BrampingViewController {
            
            prepareForSequence()
            
            // Start counter label and circle timer
            feedbackViewController.startAnimations()
            
            // Start sequence
            sequenceManager.play(sequence, repeatSequence: false)
        }
    }
    
    // MARK: - Private
    
    fileprivate func setupHorizontalPickers() {
        
        let shutterSpeeedValues: String = Bundle.main.path(forResource: "middleExposures", ofType: "plist")!
        
        startExposurePicker.delegate = self
        startExposurePicker.dataSource = NSArray(contentsOfFile: shutterSpeeedValues) as! Array
        startExposurePicker.minimumValue = NSNumber(value: 63 as Int)
        startExposurePicker.maximumValue = NSNumber(value: 6800000 as Int)
        startExposurePicker.defaultIndex = 15
        startExposurePicker.tag = kStartExposurePickerTag
        
        endExposurePicker.delegate = self
        endExposurePicker.dataSource = NSArray(contentsOfFile: shutterSpeeedValues) as! Array
        endExposurePicker.minimumValue = NSNumber(value: 63 as Int)
        endExposurePicker.maximumValue = NSNumber(value: 6800000 as Int)
        endExposurePicker.defaultIndex = 21
        endExposurePicker.tag = kEndExposurePickerTag
    }
    
    fileprivate func setupNumberPickers() {
        
        photosNumberInputView.delegate = self
        photosNumberInputView.minValue = 1
        photosNumberInputView.maxNumberLength = 5
        photosNumberInputView.maxValue = 99999
        photosNumberInputView.value = 360
        photosNumberInputView.displayView.textAlignment = NSTextAlignment.center
        
        intervalNumberInputView.delegate = self
        intervalNumberInputView.minValue = 63
        intervalNumberInputView.maxValue = 359999990
        intervalNumberInputView.value = 10000
        intervalNumberInputView.showFractions = true
        intervalNumberInputView.displayView.textAlignment = NSTextAlignment.center
    }
    
    fileprivate func updateDisplayDuration() {
        durationDisplayLabel.startValue = photosNumberInputView.displayValue * intervalNumberInputView.displayValue 
    }
    
    fileprivate func updateDuration() {
        durationDisplayLabel.startValue = photosNumberInputView.value * intervalNumberInputView.value
    }
    
    fileprivate func updateExposureValues() {
        var startValue = Int(intervalNumberInputView.value)
        
        for i in 0..<startExposurePicker.dataSource.count {
            let dict: NSDictionary = startExposurePicker.dataSource[i] as! NSDictionary
            let num: NSNumber = dict.object(forKey: "value") as! NSNumber
            
            if startValue > num.intValue {
                continue
            } else {
                var j = 0
                
                if i != 0 {
                    j = i - 1
                }
                
                let newVal: NSDictionary = startExposurePicker.dataSource[j] as! NSDictionary
                let newNum: NSNumber = newVal.object(forKey: "value") as! NSNumber
                
                startValue = newNum.intValue
                
                break
            }
        }
        
        startExposurePicker.maximumValue = NSNumber(value: startValue as Int)
        
        var endValue = Int(intervalNumberInputView.value)
        
        for i: Int in ((0 + 1)...endExposurePicker.dataSource.count).reversed() {
            
            let dict = endExposurePicker.dataSource[i - 1] as! NSDictionary
            
            let num = dict.object(forKey: "value") as! NSNumber
            
            if endValue < num.intValue {
                continue
            } else {
                var j: Int = endExposurePicker.dataSource.count - 1
                
                if i != 0 {
                    j = i - 1
                }
                
                let newVal = endExposurePicker.dataSource[j] as! NSDictionary
                let newNum = newVal.object(forKey: "value") as! NSNumber
                endValue = newNum.intValue
                
                break
            }
        }
        
        endExposurePicker.maximumValue = NSNumber(value: endValue as Int)
    }
    
    fileprivate func setDurationMinimum() {
        
        
        var minimumDuration = Float(photosNumberInputView.value) * (settingsManager?.pulseLength.floatValue)!
        
        if minimumDuration < 60.0 {
            minimumDuration = 60.0
        }
        
        if Float(intervalNumberInputView.minValue) != minimumDuration {
            intervalNumberInputView.minValue = CUnsignedLongLong(minimumDuration)
        }
    }
    
    // MARK: - Horizontal Picker Delegate
    
    func horizontalPicker(_ horizontalPicker: Any!, didSelectObjectFromDataSourceAt index: Int) {
        let picker: HorizontalPicker = horizontalPicker as! HorizontalPicker
        
        switch picker.tag {
            
        case kStartExposurePickerTag:
            startExposurePicker.save(index, forKey: "bramping-startExposure")
            break
            
        case kEndExposurePickerTag:
            endExposurePicker.save(index, forKey: "bramping-endExposure")
            break
            
        case 5:
            setDurationMinimum()
            
            if Double(intervalNumberInputView.value) < maxValue {
                var newCount = ceil(Double(intervalNumberInputView.value) * 1000.0 / maxValue)
                
                if newCount < 10.0 {
                    intervalNumberInputView.value = CUnsignedLongLong(round(maxValue * 10.0 / 1000.0))
                    newCount = 10.0
                }
                photosNumberInputView.value = CUnsignedLongLong(round(newCount))
            }
            
        case 6:
            
            if Double(intervalNumberInputView.value) < maxValue {
                var newCount = ceil(Double(intervalNumberInputView.value) * 1000.0 / maxValue)
                
                if newCount < 10.0 {
                    intervalNumberInputView.value = CUnsignedLongLong(round(maxValue * 10.0 / 1000.0))
                    newCount = 10.0
                }
                
                photosNumberInputView.value = CUnsignedLongLong(round(newCount))
            }
            break
            
        default:
            print("Default")
            break
        }
    }
    
    func horizontalPicker(_ horizontalPicker: Any!, didSelect string: String!) {
        maxValue = round(max(Double(startExposurePicker.value), Double(endExposurePicker.value)))
        intervalNumberInputView.minValue = CUnsignedLongLong(maxValue * Double(photosNumberInputView.value) / 1000.0)
    }
    
    // MARK: - TTNumberInput Delegate
    
    func ttNumberInputKeyboardDidDismiss() {
        photosNumberInputView.saveValue(photosNumberInputView.value, forKey: "bramping-numberOfPhotos")
        intervalNumberInputView.saveValue(intervalNumberInputView.value, forKey: "bramping-duration")
        
        updateDuration()
        updateExposureValues()
    }
    
    func numberInputDisplayValueChanged() {
        updateDisplayDuration()
        updateExposureValues()
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        applyThemeUpdateToNumberInput(photosNumberInputView)
        applyThemeUpdateToTimeInput(intervalNumberInputView)
        
        exposuresLabel.textColor = UIColor.triggertrap_foregroundColor()
        intervalLabel.textColor = UIColor.triggertrap_foregroundColor()
        
        durationLabel.textColor = UIColor.triggertrap_foregroundColor()
        
        durationDisplayLabel.textColor = UIColor.triggertrap_accentColor()
        durationDisplayLabel.updateApperance() 
        
        applyThemeUpdateToPicker(startExposurePicker)
        applyThemeUpdateToPicker(endExposurePicker)
        
        startExposureLabel.textColor = UIColor.triggertrap_foregroundColor()
        endExposureLabel.textColor = UIColor.triggertrap_foregroundColor()
    }
}

extension BrampingViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}
