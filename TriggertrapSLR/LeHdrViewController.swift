 //
 //  LeHdrViewController.swift
 //  TriggertrapSLR
 //
 //  Created by Ross Gibson on 19/08/2014.
 //  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
 //
 
 import UIKit
 
 class LeHdrViewController: TTViewController, HorizontalPickerDelegate {
    
    @IBOutlet weak var middleExposureHorizontalPicker: HorizontalPicker!
    @IBOutlet weak var middleExposureLabel: UILabel!
    
    @IBOutlet weak var numberOfExposuresHorizontalPicker: HorizontalPicker!
    @IBOutlet weak var exposuresLabel: UILabel!
    
    @IBOutlet weak var evHorizontalPicker: HorizontalPicker!
    @IBOutlet weak var evLabel: UILabel!
    
    private var numberOfShotsTaken = 0
    private var ev: double_t = 0
    private var num = 0
    private var sequence: Sequence!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHorizontalPickers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didTrigger:"), name: "kTTDongleDidTriggerNotification", object: nil)
        
        middleExposureHorizontalPicker.currentIndex = NSIndexPath(forRow: middleExposureHorizontalPicker.savedIndexForKey("lehdr-middleExposure"), inSection: 0)
        numberOfExposuresHorizontalPicker.currentIndex = NSIndexPath(forRow: numberOfExposuresHorizontalPicker.savedIndexForKey("lehdr-exposures"), inSection: 0)
        evHorizontalPicker.currentIndex = NSIndexPath(forRow: evHorizontalPicker.savedIndexForKey("lehdr-ev"), inSection: 0)
        
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
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierExposureAndPauseFeedbackView)
                
                feedbackViewController.shotsTakenLabel?.text = "0/\(num)"
                
                sequence = SequenceCalculator.sharedInstance.hdrSequenceForExposures(num, midExpDuration: Double(middleExposureHorizontalPicker.value), evStep: ev, interval: 0)
                sequence.modules.removeLast()
                
                let interval = sequence.durationInMilliseconds() / 1000.0
                
                //Setup counter label and circle timer so that they are populated when red view animates
                feedbackViewController.counterLabel?.countDirection = kCountDirection.CountDirectionDown.rawValue
                feedbackViewController.counterLabel?.startValue = CUnsignedLongLong(interval * 1000)
                
                feedbackViewController.circleTimer?.cycleDuration = interval
                feedbackViewController.circleTimer?.progress = 1.0
                feedbackViewController.circleTimer?.progressDirection = kProgressDirection.ProgressDirectionAntiClockwise.rawValue
                
                feedbackViewController.pauseCounterLabel?.countDirection = kCountDirection.CountDirectionDown.rawValue
                feedbackViewController.exposureCounterLabel?.countDirection = kCountDirection.CountDirectionDown.rawValue
            }
            
        } else {
            numberOfShotsTaken = 0
            sequenceManager.cancel()
        }
    }
    
    // MARK: - Theme
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        applyThemeUpdateToPicker(middleExposureHorizontalPicker)
        applyThemeUpdateToPicker(numberOfExposuresHorizontalPicker)
        applyThemeUpdateToPicker(evHorizontalPicker)
        
        applyThemeUpdateToDescriptionLabel(middleExposureLabel)
        applyThemeUpdateToDescriptionLabel(exposuresLabel) 
        applyThemeUpdateToDescriptionLabel(evLabel)
    }
    
    // MARK: - Private
    
    private func setHorizontalPickers() {
        
        // Middle Horizontal Picker
        let middleExposureValues = NSBundle.mainBundle().pathForResource("middleExposures", ofType: "plist")!
        middleExposureHorizontalPicker.delegate = self
        middleExposureHorizontalPicker.dataSource = NSArray(contentsOfFile: middleExposureValues) as! Array
        middleExposureHorizontalPicker.minimumValue = NSNumber(integer: 63)
        middleExposureHorizontalPicker.maximumValue = NSNumber(integer: 6800000)
        middleExposureHorizontalPicker.defaultIndex = 15
        middleExposureHorizontalPicker.tag = 0
        
        // EV Horizontal Picker
        let evValues = NSBundle.mainBundle().pathForResource("evValues", ofType: "plist")!
        evHorizontalPicker.delegate = self
        evHorizontalPicker.dataSource = NSArray(contentsOfFile:evValues) as! Array
        evHorizontalPicker.minimumValue = NSNumber(integer: 0)
        evHorizontalPicker.maximumValue = NSNumber(integer: 3)
        evHorizontalPicker.defaultIndex = 1
        evHorizontalPicker.tag = 1
        
        // Exposures Horizontal Picker
        let exposuresValues = NSBundle.mainBundle().pathForResource("numberOfExposures", ofType: "plist")!
        numberOfExposuresHorizontalPicker.delegate = self
        numberOfExposuresHorizontalPicker.dataSource = NSArray(contentsOfFile: exposuresValues) as! Array
        numberOfExposuresHorizontalPicker.minimumValue = NSNumber(integer: 0)
        numberOfExposuresHorizontalPicker.maximumValue = NSNumber(integer: 19)
        numberOfExposuresHorizontalPicker.defaultIndex = 0
        numberOfExposuresHorizontalPicker.tag = 2
    }
    
    private func updateBracketLimits() {
        setEV()
        
        var count = SequenceCalculator.sharedInstance.maximumNumberOfExposuresForMinumumExposure(30.0, midExposure: Double(middleExposureHorizontalPicker.value), evStep: ev)
        
        count = count < 3 ? 3 : count
        
        numberOfExposuresHorizontalPicker.maximumValue = NSNumber(integer: count)
        numberOfExposuresHorizontalPicker.refreshCurrentIndex()
        
        if count == 3 {
            num = 3
            numberOfExposuresHorizontalPicker.hidden = true
            exposuresLabel.text = NSLocalizedString("Number of exposures: 3", comment: "Number of exposures: 3")
        } else {
            numberOfExposuresHorizontalPicker.hidden = false
            exposuresLabel.text = NSLocalizedString("Number of exposures", comment: "Number of exposures")
        }
    }
    
    private func setEV() {
        ev = 1.0
        
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
    
    private func updateNumberOfExposures() {
        num = Int(roundf(numberOfExposuresHorizontalPicker.value))
        num -= (1 - num % 2)
    }
    
    // MARK: - Dispatchable Lifecycle Delegate
    
    override func willDispatch(dispatchable: Dispatchable) {
        super.willDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is LeHdrViewController && dispatchable is Pulse {
            numberOfShotsTaken += 1
            
            feedbackViewController.shotsTakenLabel?.text = "\(numberOfShotsTaken)/\(num)"
            feedbackViewController.exposureCounterLabel?.startValue = UInt64(dispatchable.durationInMilliseconds())
            feedbackViewController.exposureCounterLabel?.start()
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = 0
        }
    }
    
    override func didDispatch(dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is LeHdrViewController && dispatchable is Pulse {
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = 1000
            feedbackViewController.pauseCounterLabel?.start()
            
            feedbackViewController.exposureCounterLabel?.stop()
        }
    }
    
    // MARK: - Feedback View
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is LeHdrViewController {
            
            //Start counter label and circle timer
            feedbackViewController.startAnimations()
            prepareForSequence()
            
            //Start sequence
            sequenceManager.play(sequence, repeatSequence: false)
        }
    }
    
    override func feedbackViewHideAnimationCompleted() {
        super.feedbackViewHideAnimationCompleted()
        numberOfShotsTaken = 0
    }
    
    // MARK - Horizontal Picker Delegate
    
    func horizontalPicker(horizontalPicker: AnyObject!, didSelectObjectFromDataSourceAtIndex index: Int) {
        
        let picker = horizontalPicker as! HorizontalPicker
        
        switch picker.tag {
            // Middle Exposure Horizontal Picker
        case 0:
            middleExposureHorizontalPicker.saveIndex(index, forKey: "lehdr-middleExposure")
            break
            
            // EV Horizontal Picker
        case 1:
            evHorizontalPicker.saveIndex(index, forKey: "lehdr-ev")
            break
            
            // Number of exposures Horizontal Picker
        case 2:
            numberOfExposuresHorizontalPicker.saveIndex(index, forKey: "lehdr-exposures")
            break
            
        default:
            print("Default", terminator: "")
            break
        }
    }
    
    func horizontalPicker(horizontalPicker: AnyObject!, didSelectValue value: NSNumber!) {
        let picker = horizontalPicker as! HorizontalPicker
        
        switch picker.tag {
            // Middle Exposure Horizontal Picker
        case 0:
            updateBracketLimits()
            break
            
            // EV Horizontal Picker
        case 1:
            updateBracketLimits()
            break;
            
            // Number of exposures Horizontal Picker
        case 2:
            updateNumberOfExposures()
            break
            
        default:
            //
            break;
        }
    }
 }
 
 extension LeHdrViewController: WearableManagerDelegate {
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
 }
