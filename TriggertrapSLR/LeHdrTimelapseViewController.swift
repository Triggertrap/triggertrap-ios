//
//  LeHdrTimelapseViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class LeHdrTimelapseViewController: TTViewController, TTNumberInputDelegate, TTNumberPadViewDelegate {
    
    @IBOutlet weak var middleExposureHorizontalPicker: HorizontalPicker!
    @IBOutlet weak var middleExposureLabel: UILabel!
    
    @IBOutlet weak var numberInputView: TTTimeInput!
    @IBOutlet weak var timelapseIntervalLabel: UILabel!
    
    @IBOutlet weak var evHorizontalPicker: HorizontalPicker!
    @IBOutlet weak var evLabel: UILabel!
    
    private var count: Int = 0
    private var numberOfShotsTaken: Int = 0
    private var ev: double_t = 0
    private var sequence: Sequence!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHorizontalPickers()
        setNumberPicker()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didTrigger:"), name: "kTTDongleDidTriggerNotification", object: nil)
        
        middleExposureHorizontalPicker.currentIndex = NSIndexPath(forRow: middleExposureHorizontalPicker.savedIndexForKey("lehdrTimelapse-middleExposure"), inSection: 0)
        evHorizontalPicker.currentIndex = NSIndexPath(forRow: evHorizontalPicker.savedIndexForKey("lehdrTimelapse-ev"), inSection: 0)
        
        // Load the previous value
        numberInputView.value = numberInputView.savedValueForKey("lehdrTimelapse-interval")
        numberInputView.updateValueDisplay()
        
        updateBracketLimits()
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                
                count = 0
                numberOfShotsTaken = 0 
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierExposureAndPauseFeedbackView)
                
                setEV()
                sequence = SequenceCalculator.sharedInstance.hdrSequenceForExposures(3, midExpDuration: Double(middleExposureHorizontalPicker.value), evStep: ev, interval: Double(numberInputView.value))
                
                let interval = sequence.durationInMilliseconds() / 1000.0
                
                //Setup counter label and circle timer so that they are populated when red view animates
                feedbackViewController.counterLabel?.countDirection = kCountDirection.CountDirectionUp.rawValue
                feedbackViewController.counterLabel?.startValue = 0
                
                feedbackViewController.circleTimer?.cycleDuration = interval
                feedbackViewController.circleTimer?.progress = 1.0
                feedbackViewController.circleTimer?.progressDirection = kProgressDirection.ProgressDirectionAntiClockwise.rawValue
                
                feedbackViewController.pauseCounterLabel?.countDirection = kCountDirection.CountDirectionDown.rawValue
                feedbackViewController.exposureCounterLabel?.countDirection = kCountDirection.CountDirectionDown.rawValue
            }
            
        } else {
            sequenceManager.cancel()
        }
    }
    
    @IBAction func openKeyboard(sender : TTTimeInput) {
        adjustMinValue()
        //Adjust min value
        sender.openKeyboardInView(self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Private
    
    private func adjustMinValue() {
        var calcSequence = [Double](count: 6, repeatedValue: 0.0)
        
        var j = 0
        let step = (3 - 1) / 2
        
        var i = -step
        
        while i <= step {
            let exposure: Double = pow(Double(pow(2.0, ev)), Double(i)) * Double(middleExposureHorizontalPicker.value)
            calcSequence[j] = exposure
            calcSequence[j + 1] = 1000.0
            j += 2
            i += 1
        }
        
        let seqLength = SequenceCalculator.sharedInstance.timeForSequence(calcSequence)
        
        numberInputView.minValue = CUnsignedLongLong(seqLength)
        
        if numberInputView.value < numberInputView.minValue {
            numberInputView.value = numberInputView.minValue
            numberInputView.updateValueDisplay()
        }
    }
    
    private func setHorizontalPickers() {
        
        // Middle Horizontal Picker
        let middleExposureValues: String = NSBundle.mainBundle().pathForResource("middleExposures", ofType: "plist")!
        middleExposureHorizontalPicker.delegate = self
        
        middleExposureHorizontalPicker.dataSource = NSArray(contentsOfFile: middleExposureValues) as! Array
        middleExposureHorizontalPicker.minimumValue = NSNumber(integer: 63)
        middleExposureHorizontalPicker.maximumValue = NSNumber(integer: 6800000)
        middleExposureHorizontalPicker.defaultIndex = 15
        middleExposureHorizontalPicker.tag = 0
        
        // EV Horizontal Picker
        let evValues: String = NSBundle.mainBundle().pathForResource("evValues", ofType: "plist")!
        evHorizontalPicker.delegate = self
        evHorizontalPicker.dataSource = NSArray(contentsOfFile:evValues) as! Array
        evHorizontalPicker.minimumValue = NSNumber(integer: 0)
        evHorizontalPicker.maximumValue = NSNumber(integer: 3)
        evHorizontalPicker.defaultIndex = 1
        evHorizontalPicker.tag = 1
    }
    
    private func setNumberPicker() {
        
        numberInputView.delegate = self
        numberInputView.maxValue = 359999900
        numberInputView.value = 10000
        numberInputView.displayView.textAlignment = NSTextAlignment.Center
        adjustMinValue()
        
        //Adjust min value
        numberInputView.updateValueDisplay()
    }
    
    private func setEV() {
        ev = 1.0;
        
        switch Int(roundf(evHorizontalPicker.value)) {
            
        case 0:
            ev = 1.0 / 3.0
            break;
            
        case 1:
            ev = 0.5
            break;
            
        case 2:
            ev = 1.0
            break;
            
        case 3:
            ev = 2.0
            break;
            
        default:
            ev = 1.0
            break
        }
        
    }
    
    private func updateBracketLimits() {
        
        if ev < 2.0 {
            middleExposureHorizontalPicker.minimumValue = NSNumber(integer: 63)
        } else {
            middleExposureHorizontalPicker.minimumValue = NSNumber(integer: 125)
        }
        adjustMinValue()
    }
    
    // MARK: - Public
    
    override func willDispatch(dispatchable: Dispatchable) {
        super.willDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is LeHdrTimelapseViewController && dispatchable is Pulse {
            
            feedbackViewController.exposureCounterLabel?.startValue = UInt64(sequence.modules[count * 2].durationInMilliseconds())
            feedbackViewController.exposureCounterLabel?.start()
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = 0
        }
    }
    
    override func didDispatch(dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is LeHdrTimelapseViewController && dispatchable is Pulse {
            var pauseLength = sequence.modules[count * 2 + 1].durationInMilliseconds()
            
            count += 1
            
            if count == 3 {
                count = 0
                numberOfShotsTaken += 1
                
                if numberOfShotsTaken == 1 {
                    let set = String(format: NSLocalizedString("%d HDR set", comment: "%d HDR set"), numberOfShotsTaken)
                    feedbackViewController.shotsTakenLabel?.text = set
                } else {
                    let sets = String(format: NSLocalizedString("%d HDR sets", comment: "%d HDR sets"), numberOfShotsTaken)
                    feedbackViewController.shotsTakenLabel?.text = sets
                }
                
                sequence = SequenceCalculator.sharedInstance .hdrSequenceForExposures(3, midExpDuration: Double(middleExposureHorizontalPicker.value), evStep: ev, interval: Double(numberInputView.value))
                
                let interval = Double(numberInputView.value)
                let seqLength = sequence.durationInMilliseconds()
                
                let pauseLengthTotal = interval - seqLength + 1000.0
                pauseLength = pauseLengthTotal
            }
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = UInt64(pauseLength)
            feedbackViewController.pauseCounterLabel?.start()
            
            feedbackViewController.exposureCounterLabel?.stop()
        }
    }
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is LeHdrTimelapseViewController {
            
            //Start counter label and circle timer
            feedbackViewController.startAnimations()
            prepareForSequence()
            
            //Start sequence
            sequenceManager.play(Sequence(modules: sequence.modules), repeatSequence: true)
        }
    }
    
    override func feedbackViewHideAnimationCompleted() {
        super.feedbackViewHideAnimationCompleted()
    }
    
    override func didFinishSequence() {
        // Override default behaviour - this allows the triggering to continue
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        applyThemeUpdateToPicker(middleExposureHorizontalPicker)
        applyThemeUpdateToPicker(evHorizontalPicker)
        applyThemeUpdateToTimeInput(numberInputView)
        
        middleExposureLabel.textColor = UIColor.triggertrap_foregroundColor()
        timelapseIntervalLabel.textColor = UIColor.triggertrap_foregroundColor()
        evLabel.textColor = UIColor.triggertrap_foregroundColor()
    }
}

extension LeHdrTimelapseViewController: HorizontalPickerDelegate {
    
    // MARK - Horizontal Picker Delegate
    
    func horizontalPicker(horizontalPicker: AnyObject!, didSelectObjectFromDataSourceAtIndex index: Int) {
        
        let picker = horizontalPicker as! HorizontalPicker
        
        switch picker.tag {
        case 0:
            middleExposureHorizontalPicker.saveIndex(index, forKey: "lehdrTimelapse-middleExposure")
            break
        case 1:
            evHorizontalPicker.saveIndex(index, forKey: "lehdrTimelapse-ev")
            setEV()
            updateBracketLimits()
            middleExposureHorizontalPicker.refreshCurrentIndex()
            break
            
        default:
            print("Default")
            break
            
        }
    }
    
    func horizontalPicker(horizontalPicker: AnyObject!, didSelectValue value: NSNumber!) {
        
        let picker = horizontalPicker as! HorizontalPicker
        
        switch picker.tag {
        case 0:
            setEV()
            updateBracketLimits()
            break
            
        case 1:
            //
            break;
            
        default:
            //
            break;
        }
    }
}

extension LeHdrTimelapseViewController: WearableManagerDelegate {
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}