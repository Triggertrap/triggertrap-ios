 //
 //  LeHdrViewController.swift
 //  TriggertrapSLR
 //
 //  Created by Ross Gibson on 19/08/2014.
 //  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
 //
 
 import UIKit
 import TTCounterLabel
 
 class LeHdrViewController: TTViewController, HorizontalPickerDelegate {
    
    @IBOutlet weak var middleExposureHorizontalPicker: HorizontalPicker!
    @IBOutlet weak var middleExposureLabel: UILabel!
    
    @IBOutlet weak var numberOfExposuresHorizontalPicker: HorizontalPicker!
    @IBOutlet weak var exposuresLabel: UILabel!
    
    @IBOutlet weak var evHorizontalPicker: HorizontalPicker!
    @IBOutlet weak var evLabel: UILabel!
    
    fileprivate var numberOfShotsTaken = 0
    fileprivate var ev: double_t = 0
    fileprivate var num = 0
    fileprivate var sequence: Sequence!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHorizontalPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: Selector(("didTrigger:")), name: NSNotification.Name(rawValue: "kTTDongleDidTriggerNotification"), object: nil)
        
        middleExposureHorizontalPicker.currentIndex = IndexPath(row: middleExposureHorizontalPicker.savedIndex(forKey: "lehdr-middleExposure"), section: 0)
        numberOfExposuresHorizontalPicker.currentIndex = IndexPath(row: numberOfExposuresHorizontalPicker.savedIndex(forKey: "lehdr-exposures"), section: 0)
        evHorizontalPicker.currentIndex = IndexPath(row: evHorizontalPicker.savedIndex(forKey: "lehdr-ev"), section: 0)
        
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
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
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
                feedbackViewController.counterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                feedbackViewController.counterLabel?.startValue = CUnsignedLongLong(interval * 1000)
                
                feedbackViewController.circleTimer?.cycleDuration = interval
                feedbackViewController.circleTimer?.updateProgress(1.0)
                feedbackViewController.circleTimer?.progressDirection = .AntiClockwise
                
                feedbackViewController.pauseCounterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                feedbackViewController.exposureCounterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
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
    
    fileprivate func setHorizontalPickers() {
        
        // Middle Horizontal Picker
        let middleExposureValues = Bundle.main.path(forResource: "middleExposures", ofType: "plist")!
        middleExposureHorizontalPicker.delegate = self
        middleExposureHorizontalPicker.dataSource = NSArray(contentsOfFile: middleExposureValues) as! Array
        middleExposureHorizontalPicker.minimumValue = NSNumber(value: 63 as Int)
        middleExposureHorizontalPicker.maximumValue = NSNumber(value: 6800000 as Int)
        middleExposureHorizontalPicker.defaultIndex = 15
        middleExposureHorizontalPicker.tag = 0
        
        // EV Horizontal Picker
        let evValues = Bundle.main.path(forResource: "evValues", ofType: "plist")!
        evHorizontalPicker.delegate = self
        evHorizontalPicker.dataSource = NSArray(contentsOfFile:evValues) as! Array
        evHorizontalPicker.minimumValue = NSNumber(value: 0 as Int)
        evHorizontalPicker.maximumValue = NSNumber(value: 3 as Int)
        evHorizontalPicker.defaultIndex = 1
        evHorizontalPicker.tag = 1
        
        // Exposures Horizontal Picker
        let exposuresValues = Bundle.main.path(forResource: "numberOfExposures", ofType: "plist")!
        numberOfExposuresHorizontalPicker.delegate = self
        numberOfExposuresHorizontalPicker.dataSource = NSArray(contentsOfFile: exposuresValues) as! Array
        numberOfExposuresHorizontalPicker.minimumValue = NSNumber(value: 0 as Int)
        numberOfExposuresHorizontalPicker.maximumValue = NSNumber(value: 19 as Int)
        numberOfExposuresHorizontalPicker.defaultIndex = 0
        numberOfExposuresHorizontalPicker.tag = 2
    }
    
    fileprivate func updateBracketLimits() {
        setEV()
        
        var count = SequenceCalculator.sharedInstance.maximumNumberOfExposuresForMinumumExposure(30.0, midExposure: Double(middleExposureHorizontalPicker.value), evStep: ev)
        
        count = count < 3 ? 3 : count
        
        numberOfExposuresHorizontalPicker.maximumValue = NSNumber(value: count as Int)
        numberOfExposuresHorizontalPicker.refreshCurrentIndex()
        
        if count == 3 {
            num = 3
            numberOfExposuresHorizontalPicker.isHidden = true
            exposuresLabel.text = NSLocalizedString("Number of exposures: 3", comment: "Number of exposures: 3")
        } else {
            numberOfExposuresHorizontalPicker.isHidden = false
            exposuresLabel.text = NSLocalizedString("Number of exposures", comment: "Number of exposures")
        }
    }
    
    fileprivate func setEV() {
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
    
    fileprivate func updateNumberOfExposures() {
        num = Int(roundf(numberOfExposuresHorizontalPicker.value))
        num -= (1 - num % 2)
    }
    
    // MARK: - Dispatchable Lifecycle Delegate
    
    override func willDispatch(_ dispatchable: Dispatchable) {
        super.willDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is LeHdrViewController && dispatchable is Pulse {
            numberOfShotsTaken += 1
            
            feedbackViewController.shotsTakenLabel?.text = "\(numberOfShotsTaken)/\(num)"
            feedbackViewController.exposureCounterLabel?.startValue = UInt64(dispatchable.durationInMilliseconds())
            feedbackViewController.exposureCounterLabel?.start()
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = 0
        }
    }
    
    override func didDispatch(_ dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is LeHdrViewController && dispatchable is Pulse {
            
            feedbackViewController.pauseCounterLabel?.stop()
            feedbackViewController.pauseCounterLabel?.startValue = 1000
            feedbackViewController.pauseCounterLabel?.start()
            
            feedbackViewController.exposureCounterLabel?.stop()
        }
    }
    
    // MARK: - Feedback View
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is LeHdrViewController {
            
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
    
    func horizontalPicker(_ horizontalPicker: Any!, didSelectObjectFromDataSourceAt index: Int) {
        let picker = horizontalPicker as! HorizontalPicker
        
        switch picker.tag {
        // Middle Exposure Horizontal Picker
        case 0:
            middleExposureHorizontalPicker.save(index, forKey: "lehdr-middleExposure")
            break
            
        // EV Horizontal Picker
        case 1:
            evHorizontalPicker.save(index, forKey: "lehdr-ev")
            break
            
        // Number of exposures Horizontal Picker
        case 2:
            numberOfExposuresHorizontalPicker.save(index, forKey: "lehdr-exposures")
            break
            
        default:
            print("Default", terminator: "")
            break
        }
    }
    
    
    func horizontalPicker(_ horizontalPicker: Any!, didSelectValue value: NSNumber!) {
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
