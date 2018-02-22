//
//  TimeWarpViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class TimeWarpViewController: TTViewController, TTNumberInputDelegate, TTKeyboardDelegate, TTControlPointDelegate {
    
    private let kMaxNumberOverlaps: Int =  300
    private let kShutterButtonAnimationDuration: Double = 0.25
    private let kClockAnimationDuration : Double = 2.5
    
    // White View
    @IBOutlet weak var photosNumberInputView: TTNumberInput!
    @IBOutlet weak var durationNumberInputView: TTTimeInput!
    
    @IBOutlet weak var exposuresTextLabel: UILabel!
    @IBOutlet weak var takeTextLabel: UILabel!
    
    private let interpolator = CubicBezierInterpolator()
    private var shotsTakenCount: Int = 0
    private var shotsToTakeCount: Int = 0
    
    @IBOutlet weak var bezierGraphView: BezierGraph!
    @IBOutlet weak var timeWarpView: UIView!
    @IBOutlet weak var visibleView: UIView!
    
    @IBOutlet weak var timeWarpInfoView: UIView!
    @IBOutlet weak var feedbackToWhiteViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var durationFeedbackLabel: TTCounterLabel!
    @IBOutlet weak var exposuresFeedbackLabel: UILabel!
    
    // For localization only
    @IBOutlet weak var exposuresLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    // Tick image
    @IBOutlet weak var tickImageView: UIImageView!
    
    private var isViewHidden: Bool!
    
    // Grey view
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var clockView: UIView!
    @IBOutlet weak var secondsView: UIView!
    
    @IBOutlet weak var clockImageView:UIImageView!
    @IBOutlet weak var clockCenterImageView: UIImageView!
    @IBOutlet weak var clockHandleImageView: UIImageView!
    
    private var clockIsAnimating: Bool = false
    private var pauseIndex: Int = 0
    
    private var sequence: Sequence!
    private var shutterButtonAnimatingDuringPreview = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        isViewHidden = true
        
        photosNumberInputView.ttKeyboardDelegate = self
        photosNumberInputView.delegate = self
        photosNumberInputView.minValue = 1
        photosNumberInputView.maxNumberLength = 5
        photosNumberInputView.maxValue = 99999
        photosNumberInputView.value = 10
        photosNumberInputView.displayView.textAlignment = NSTextAlignment.Center
        
        durationNumberInputView.ttKeyboardDelegate = self
        durationNumberInputView.delegate = self
        durationNumberInputView.maxValue = 359999990 // = 99 hours  99 mins ...
        durationNumberInputView.value = 90000 // default 1 min 30 secs
        durationNumberInputView.displayView.textAlignment = NSTextAlignment.Center
        durationNumberInputView.showFractions = false
        durationNumberInputView.minValue = 0
        
        durationFeedbackLabel.boldFont = UIFont.triggertrap_openSans_bold(17)
        durationFeedbackLabel.regularFont = UIFont.triggertrap_openSans_regular(17)
        durationFeedbackLabel.font = UIFont.triggertrap_openSans_regular(13)
        durationFeedbackLabel.displayMode = kDisplayMode.DisplayModeSeconds
        durationFeedbackLabel.textColor = UIColor.whiteColor()
        durationFeedbackLabel.textAlignment = NSTextAlignment.Left;
        durationFeedbackLabel.updateApperance()
        
        //TTShadeRedColour
        timeWarpInfoView.backgroundColor = UIColor.triggertrap_shadeRedColor(1.0)
        
        //TTTimeWarpDarkRedColor
        visibleView.backgroundColor = UIColor.triggertrap_timeWarpDarkRedColor(1.0)
        
        // CubicBezierInterpolator
        bezierGraphView.controlPointReleasedDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load the previous value
        photosNumberInputView.value = photosNumberInputView.savedValueForKey("timewarp-numberOfPhotos") != 100 ? photosNumberInputView.savedValueForKey("timewarp-numberOfPhotos") : 100
        
        durationNumberInputView.value = durationNumberInputView.savedValueForKey("timewarp-duration") != 100 ? durationNumberInputView.savedValueForKey("timewarp-duration") : 3600000
        
        // Get the value from the durationNumberInput and photosNumberInputViewshow and update feedback view
        exposuresFeedbackLabel.text = "\(photosNumberInputView.value)"
        durationFeedbackLabel.startValue = durationNumberInputView.value
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the feedback view height constraint if it is visible
        if isViewHidden == false {
            presentFeedbackView(false)
        }
        
        bezierGraphView.layoutIfNeeded()
        bezierGraphView.updateViewComponentsAfterRotation()
        controlPointReleased()
    }
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        timeWarpView.backgroundColor = UIColor.triggertrap_fillColor()
        timeWarpInfoView.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_primaryColor(), change: 0.1)
        visibleView.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_primaryColor(), change: 0.2)
        
        takeTextLabel.textColor = UIColor.triggertrap_foregroundColor()
        exposuresTextLabel.textColor = UIColor.triggertrap_foregroundColor()
        
        durationFeedbackLabel.textColor = UIColor.triggertrap_fillColor()
        durationFeedbackLabel.updateApperance()
        
        durationLabel.textColor = UIColor.triggertrap_fillColor()
        
        exposuresLabel.textColor = UIColor.triggertrap_fillColor()
        exposuresFeedbackLabel.textColor = UIColor.triggertrap_fillColor()
        
        applyThemeUpdateToNumberInput(photosNumberInputView) 
        applyThemeUpdateToTimeInput(durationNumberInputView)
        
        bezierGraphView.backgroundColor = UIColor.triggertrap_fillColor()
        bezierGraphView.setCurveColor(UIColor.triggertrap_primaryColor())
        bezierGraphView.setPointBorderColor(UIColor.triggertrap_foregroundColor())
        bezierGraphView.setPointFillColor(UIColor.triggertrap_naturalColor())
        bezierGraphView.setOverlappingExposuresColor(UIColor.triggertrap_primaryColor())
        
        tickImageView.image = ImageWithColor(UIImage(named: "tickDown")!, color: UIColor.triggertrap_fillColor())
        
        previewButton.setBackgroundImage(ImageWithColor(UIImage(named: "timeWarpPreviewButton")!, color: UIColor.triggertrap_primaryColor()), forState: .Normal)
        
        clockImageView.image = ImageWithColor(UIImage(named: "timeWarpClockCircle")!, color: UIColor.triggertrap_primaryColor())
        
        clockCenterImageView.image = ImageWithColor(UIImage(named: "timeWarpClockCenter")!, color: UIColor.triggertrap_primaryColor())
        
        clockHandleImageView.image = ImageWithColor(UIImage(named: "timeWarpClockHand")!, color: UIColor.triggertrap_primaryColor())
    }
    
    // MARK: - IBActions
    
    @IBAction func previewButtonPressed(sender: UIButton) {
        
        if clockIsAnimating == false {
            
            // Check if shutter button is animating
            if shutterButtonAnimatingDuringPreview == true {
                
                //Stop shutter button animation while preview is shown
                shutterButton.stopAnimating()
            }
            
            animateShutterButton()
            hidePreviewButtonAnimation()
        }
    }
    
    @IBAction func feedbackButtonPressed(sender: UIButton) {
        
        if isViewHidden == false {
            controlPointReleased()
        }
        
        isViewHidden = !isViewHidden
        
        (isViewHidden == true) ? dismissFeedbackView(true) : presentFeedbackView(true)
    }
    
    @IBAction func shutterButtonTouchUpInside(sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                shotsTakenCount = 0 
                
                shutterButtonAnimatingDuringPreview = true
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierElapsedFeedbackView)
                
                configureInterpolator()
                
                pauseIndex = 1
                
                //Create sequence from number of photos, interval, start and end exposures
                sequence = SequenceCalculator.sharedInstance.timeWarpSequenceForExposures(Int(photosNumberInputView.value), duration: Double(durationNumberInputView.value), pulseLength: settingsManager.pulseLength.doubleValue, minimumGap: 150.0, interpolator: interpolator)
                
                //Calculate the length of the sequence
                let interval = sequence.durationInMilliseconds()
                
                //Set counter label and circle timer duration and count direction
                feedbackViewController.counterLabel?.countDirection = kCountDirection.CountDirectionDown.rawValue
                feedbackViewController.counterLabel?.startValue = CUnsignedLongLong(interval)
                
                feedbackViewController.circleTimer?.cycleDuration = interval / 1000.0
                feedbackViewController.circleTimer?.progress = 1.0
                feedbackViewController.circleTimer?.progressDirection = kProgressDirection.ProgressDirectionAntiClockwise.rawValue
                
                feedbackViewController.elapsedLabel?.text = NSLocalizedString("Next:", comment: "Next:")
                feedbackViewController.elapsedCounterLabel?.countDirection = kCountDirection.CountDirectionDown.rawValue
                
                feedbackViewController.elapsedCounterLabel?.startValue = UInt64(sequence.modules[0].durationInMilliseconds())
                shotsToTakeCount = Int(photosNumberInputView.value)
                
                feedbackViewController.shotsTakenLabel?.text = "0/\(shotsToTakeCount)"
            }
            
        } else {
            sequenceManager.cancel()
        }
    }
    
    @IBAction func openKeyboard(sender : TTNumberInput) {
        sender.openKeyboardInView(self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Private
    
    func controlPointReleased() {
        configureInterpolator()
        
        let triggerLength = settingsManager.pulseLength.integerValue != 100 ? settingsManager.pulseLength.doubleValue : 100.0
        
        interpolator.pausesForExposures(CInt(photosNumberInputView.value), sequenceDuration: Int(durationNumberInputView.value), pulseLength: CLong(triggerLength), minimumGapBetweenPulses: 150)
        
        var sequenceLength: Double = 0
        
        for i in 0..<interpolator.adjustedPauses().count {
            sequenceLength = sequenceLength + Double(interpolator.adjustedPauses()[i] as! NSNumber) + triggerLength
        }
        
        durationFeedbackLabel.startValue = CUnsignedLongLong(sequenceLength)
        
        let overlapIndicies = interpolator.overlapIndicies()
        
        let overlaps = NSMutableArray()
        
        for i in 0..<overlapIndicies.count {
            
            if (i < kMaxNumberOverlaps / 3 || (i > (overlapIndicies.count / 2 - kMaxNumberOverlaps / 6) && i < (overlapIndicies.count / 2 + kMaxNumberOverlaps / 6)) ||
                i > overlapIndicies.count - kMaxNumberOverlaps / 3) {
                overlaps.addObject(overlapIndicies[i])
            }
        }
        
        let timeOverlapIndicies = NSMutableArray()
        let progressionOverlapIndicies = NSMutableArray()
        
        var timeOverlap: Float = 0.0
        
        for i in 0..<overlaps.count {
            // Calculate the time overlap by dividing the overlap indicie int value by the amount of exposures
            timeOverlap = Float(overlaps[i] as! NSNumber) / Float(photosNumberInputView.value)
            
            // Add the Time Overlap to the timeOverlapIndicies Array
            timeOverlapIndicies.addObject(NSNumber(float: timeOverlap))
            
            // Use the interpolation function from the CubicBezierCalculator to calculate progression from each time overlap
            progressionOverlapIndicies.addObject(NSNumber(float: interpolator.interpolation(timeOverlap)))
        }
        
        // Pass the overlapping points to the bezier graph view to display them
        bezierGraphView.overlappingPointsWithTime(timeOverlapIndicies, withProgression: progressionOverlapIndicies)
    }
    
    private func animateShutterButton() {
        
        if clockIsAnimating == false {
            
            UIView.transitionWithView(clockView, duration: kShutterButtonAnimationDuration, options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews], animations: { () -> Void in
                self.shutterButton.alpha = self.clockView.hidden ? 1 : 0
                }, completion: { (finished: Bool) -> Void in
                    self.clockView.hidden = !self.clockView.hidden
            })
            
            UIView.transitionWithView(shutterButton, duration: kShutterButtonAnimationDuration, options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews], animations: { () -> Void in
                self.shutterButton.alpha = self.clockView.hidden ? 0 : 1
                self.clockView.alpha = self.clockView.hidden ? 1 : 0
                }, completion: { (finished: Bool) -> Void in
                    self.shutterButton.hidden = !self.shutterButton.hidden
            })
        }
    }
    
    private func animateClock() {
        
        configureInterpolator()
        
        CATransaction.begin()
        CATransaction.setValue(NSNumber(double: kClockAnimationDuration), forKey: kCATransactionAnimationDuration)
        
        CATransaction.setCompletionBlock { () -> Void in
            self.showPreviewButtonAnimation()
        }
        
        let animation = AccelerationAnimation.animationWithKeyPath("transform.rotation", startValue: 0.0, endValue: degreesToRadians(360.0), evaluationObject: interpolator, interstitialSteps: UInt(photosNumberInputView.value)) as! AccelerationAnimation
        
        animation.delegate = self
        
        secondsView.layer.addAnimation(animation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    private func showPreviewButtonAnimation() {
        animateShutterButton()
        
        UIView.animateWithDuration(kShutterButtonAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.previewButton.transform = CGAffineTransformMakeScale(1, 1)
        }) { (finished: Bool) -> Void in
            
            if finished == true {
                
                self.clockIsAnimating = false
                
                //When preview button is hidden check whether shutter button is still supposed to be animating
                if self.shutterButtonAnimatingDuringPreview == true {
                    
                    //Start animation of the shutter button
                    self.shutterButton.startAnimating()
                }
            }
        }
    }
    
    private func hidePreviewButtonAnimation() {
        
        UIView.animateWithDuration(kShutterButtonAnimationDuration, animations: { () -> Void in
            self.previewButton.transform = CGAffineTransformMakeScale(1, 0)
            } , completion: {(finished: Bool) -> Void in
                
                if finished == true {
                    self.animateClock()
                }
        })
    }
    
    private func dismissFeedbackView(animated: Bool) {
        var duration = 0.0
        var delay = 0.0
        
        if animated {
            duration = 0.3
            delay = 0.1
        }
        
        let verticalFlip = CGAffineTransformMakeScale(1, 1)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            for i in 0..<self.timeWarpView.subviews.count {
                
                let subView = self.timeWarpView.subviews[i]
                
                if subView.isDescendantOfView(self.visibleView) == false {
                    subView.alpha = 0.0
                }
            }
            
            self.tickImageView.transform = verticalFlip
            
            UIView.animateWithDuration(duration - delay, delay: delay, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.feedbackToWhiteViewConstraint.constant = 0
                self.view.layoutIfNeeded()
                }, completion: { (finished: Bool) -> Void in
                    
                    for i in 0..<self.timeWarpView.subviews.count {
                        
                        let subView = self.timeWarpView.subviews[i] 
                        
                        if subView.isDescendantOfView(self.visibleView) == false {
                            subView.alpha = 0.0
                        }
                    }
            })
        })
    }
    
    private func presentFeedbackView(animated: Bool) {
        
        var duration = 0.0
        var delay = 0.0
        
        if animated {
            duration = 0.3
            delay = 0.1
        }
        
        let verticalFlip: CGAffineTransform = CGAffineTransformMakeScale(1, -1)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            self.tickImageView.transform = verticalFlip
            self.feedbackToWhiteViewConstraint.constant = self.topLeftView.frame.size.height - self.visibleView.frame.size.height
            
            UIView.animateWithDuration(duration - delay, delay: delay, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                
                for i in 0..<self.timeWarpView.subviews.count {
                    let subView: UIView = self.timeWarpView.subviews[i] 
                    subView.alpha = 1.0
                }
                }, completion: { (finished) -> Void in
                    
                    self.timeWarpView.alpha = 1.0
                    self.feedbackToWhiteViewConstraint.constant = self.topLeftView.frame.size.height - self.visibleView.frame.size.height
                    
                    for i in 0..<self.timeWarpView.subviews.count {
                        let subView: UIView = self.timeWarpView.subviews[i] 
                        subView.alpha = 1.0
                    }
            })
            
            self.view.layoutIfNeeded()
        })
    }
    
    private func configureInterpolator() {
        let controlPoint1: CGPoint = bezierGraphView.controlPoint1GraphLocation() as CGPoint
        let controlPoint2: CGPoint = bezierGraphView.controlPoint2GraphLocation() as CGPoint
        
        interpolator.setControlPoints_x1(Float(controlPoint1.x), y1: Float(controlPoint1.y), x2: Float(controlPoint2.x), y2: Float(controlPoint2.y))
    }
    
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees / 180.0 * M_PI
    }
    
    private func radiansToDegrees(radians: Double) -> Double {
        return radians  * (180.0 / M_PI)
    }
    
    override func didDispatch(dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is TimeWarpViewController && dispatchable is Pulse {
            shotsTakenCount += 1
            feedbackViewController.shotsTakenLabel?.text = "\(shotsTakenCount)/\(shotsToTakeCount)"
        }
    }
    
    override func willDispatch(dispatchable: Dispatchable) {
        super.willDispatch(dispatchable) 
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is TimeWarpViewController {
            
            feedbackViewController.elapsedCounterLabel?.stop()
            feedbackViewController.elapsedCounterLabel?.startValue = UInt64(dispatchable.durationInMilliseconds())
            feedbackViewController.elapsedCounterLabel?.start()
        }
    } 
    
    // MARK: - Public
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is TimeWarpViewController {
            
            prepareForSequence()
            
            sequenceManager.play(sequence, repeatSequence: false)
            
            //Start counter label and circle timer
            feedbackViewController.startAnimations()
        }
    }
    
    override func feedbackViewHideAnimationCompleted() {
        super.feedbackViewHideAnimationCompleted()
        
        shutterButtonAnimatingDuringPreview = false
    }
    
    // MARK: - TTNumberInput Delegate
    
    func TTNumberInputKeyboardDidDismiss() {
        photosNumberInputView.saveValue(photosNumberInputView.value, forKey: "timewarp-numberOfPhotos")
        durationNumberInputView.saveValue(durationNumberInputView.value, forKey: "timewarp-duration")
    }
    
    // MARK: - TTKeyboard Delegate
    
    func editingChanged() {
        exposuresFeedbackLabel.text = "\(photosNumberInputView.displayValue)"
        durationFeedbackLabel.startValue = durationNumberInputView.displayValue
    }
}


extension TimeWarpViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}
