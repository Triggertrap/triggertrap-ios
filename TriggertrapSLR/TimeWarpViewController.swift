//
//  TimeWarpViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit
import TTCounterLabel

class TimeWarpViewController: TTViewController, TTNumberInputDelegate, TTKeyboardDelegate, TTControlPointDelegate {
    
    fileprivate let kMaxNumberOverlaps: Int =  300
    fileprivate let kShutterButtonAnimationDuration: Double = 0.25
    fileprivate let kClockAnimationDuration : Double = 2.5
    
    // White View
    @IBOutlet weak var photosNumberInputView: TTNumberInput!
    @IBOutlet weak var durationNumberInputView: TTTimeInput!
    
    @IBOutlet weak var exposuresTextLabel: UILabel!
    @IBOutlet weak var takeTextLabel: UILabel!
    
    fileprivate let interpolator = CubicBezierInterpolator()
    fileprivate var shotsTakenCount: Int = 0
    fileprivate var shotsToTakeCount: Int = 0
    
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
    
    fileprivate var isViewHidden: Bool!
    
    // Grey view
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var clockView: UIView!
    @IBOutlet weak var secondsView: UIView!
    
    @IBOutlet weak var clockImageView:UIImageView!
    @IBOutlet weak var clockCenterImageView: UIImageView!
    @IBOutlet weak var clockHandleImageView: UIImageView!
    
    fileprivate var clockIsAnimating: Bool = false
    fileprivate var pauseIndex: Int = 0
    
    fileprivate var sequence: Sequence!
    fileprivate var shutterButtonAnimatingDuringPreview = false
    
    private let _onceToken = NSUUID().uuidString
    
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
        photosNumberInputView.displayView.textAlignment = NSTextAlignment.center
        
        durationNumberInputView.ttKeyboardDelegate = self
        durationNumberInputView.delegate = self
        durationNumberInputView.maxValue = 359999990 // = 99 hours  99 mins ...
        durationNumberInputView.value = 90000 // default 1 min 30 secs
        durationNumberInputView.displayView.textAlignment = NSTextAlignment.center
        durationNumberInputView.showFractions = false
        durationNumberInputView.minValue = 0
        
        durationFeedbackLabel.boldFont = UIFont.triggertrap_openSans_bold(17)
        durationFeedbackLabel.regularFont = UIFont.triggertrap_openSans_regular(17)
        durationFeedbackLabel.font = UIFont.triggertrap_openSans_regular(13)
        durationFeedbackLabel.displayMode = kDisplayMode.displayModeSeconds
        durationFeedbackLabel.textColor = UIColor.white
        durationFeedbackLabel.textAlignment = NSTextAlignment.left;
        durationFeedbackLabel.updateApperance()
        
        //TTShadeRedColour
        timeWarpInfoView.backgroundColor = UIColor.triggertrap_shadeRedColor(1.0)
        
        //TTTimeWarpDarkRedColor
        visibleView.backgroundColor = UIColor.triggertrap_timeWarpDarkRedColor(1.0)
        
        // CubicBezierInterpolator
        bezierGraphView.controlPointReleasedDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load the previous value
        photosNumberInputView.value = photosNumberInputView.savedValue(forKey: "timewarp-numberOfPhotos") != 100 ? photosNumberInputView.savedValue(forKey: "timewarp-numberOfPhotos") : 100
        
        durationNumberInputView.value = durationNumberInputView.savedValue(forKey: "timewarp-duration") != 100 ? durationNumberInputView.savedValue(forKey: "timewarp-duration") : 3600000
        
        // Get the value from the durationNumberInput and photosNumberInputViewshow and update feedback view
        exposuresFeedbackLabel.text = "\(photosNumberInputView.value)"
        durationFeedbackLabel.startValue = durationNumberInputView.value
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
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
        bezierGraphView.setCurve(UIColor.triggertrap_primaryColor())
        bezierGraphView.setPointBorderColor(UIColor.triggertrap_foregroundColor())
        bezierGraphView.setPointFill(UIColor.triggertrap_naturalColor())
        bezierGraphView.setOverlappingExposuresColor(UIColor.triggertrap_primaryColor())
        
        tickImageView.image = ImageWithColor(UIImage(named: "tickDown")!, color: UIColor.triggertrap_fillColor())
        
        previewButton.setBackgroundImage(ImageWithColor(UIImage(named: "timeWarpPreviewButton")!, color: UIColor.triggertrap_primaryColor()), for: UIControlState())
        
        clockImageView.image = ImageWithColor(UIImage(named: "timeWarpClockCircle")!, color: UIColor.triggertrap_primaryColor())
        
        clockCenterImageView.image = ImageWithColor(UIImage(named: "timeWarpClockCenter")!, color: UIColor.triggertrap_primaryColor())
        
        clockHandleImageView.image = ImageWithColor(UIImage(named: "timeWarpClockHand")!, color: UIColor.triggertrap_primaryColor())
    }
    
    // MARK: - IBActions
    
    @IBAction func previewButtonPressed(_ sender: UIButton) {
        
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
    
    @IBAction func feedbackButtonPressed(_ sender: UIButton) {
        
        if isViewHidden == false {
            controlPointReleased()
        }
        
        isViewHidden = !isViewHidden
        
        (isViewHidden == true) ? dismissFeedbackView(true) : presentFeedbackView(true)
    }
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
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
                sequence = SequenceCalculator.sharedInstance.timeWarpSequenceForExposures(Int(photosNumberInputView.value), duration: Double(durationNumberInputView.value), pulseLength: (settingsManager?.pulseLength.doubleValue)!, minimumGap: 150.0, interpolator: interpolator!)
                
                //Calculate the length of the sequence
                let interval = sequence.durationInMilliseconds()
                
                //Set counter label and circle timer duration and count direction
                feedbackViewController.counterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                feedbackViewController.counterLabel?.startValue = CUnsignedLongLong(interval)
                
                feedbackViewController.circleTimer?.cycleDuration = interval / 1000.0
                feedbackViewController.circleTimer?.updateProgress(1.0)
                feedbackViewController.circleTimer?.progressDirection = .AntiClockwise
                
                feedbackViewController.elapsedLabel?.text = NSLocalizedString("Next:", comment: "Next:")
                feedbackViewController.elapsedCounterLabel?.countDirection = kCountDirection.countDirectionDown.rawValue
                
                feedbackViewController.elapsedCounterLabel?.startValue = UInt64(sequence.modules[0].durationInMilliseconds())
                shotsToTakeCount = Int(photosNumberInputView.value)
                
                feedbackViewController.shotsTakenLabel?.text = "0/\(shotsToTakeCount)"
            }
            
        } else {
            sequenceManager.cancel()
        }
    }
    
    @IBAction func openKeyboard(_ sender : TTNumberInput) {
        sender.openKeyboard(in: self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Private
    
    func controlPointReleased() {
        
        configureInterpolator()
        
        let triggerLength = settingsManager?.pulseLength.intValue != 100 ? settingsManager?.pulseLength.doubleValue : 100.0
        
        _ = interpolator?.pauses(forExposures: CInt(photosNumberInputView.value), sequenceDuration: Int(durationNumberInputView.value), pulseLength: CLong(triggerLength!), minimumGapBetweenPulses: 150)
        
        var sequenceLength: Double = 0
        
        for i in 0..<interpolator!.adjustedPauses().count {
            sequenceLength = sequenceLength + Double(truncating: interpolator?.adjustedPauses()[i] as! NSNumber) + triggerLength!
        }
        
        
        DispatchQueue.once(token: _onceToken) {
            durationFeedbackLabel.startValue = CUnsignedLongLong(sequenceLength)
        }
        //
        
        let overlapIndicies = interpolator?.overlapIndicies()
        
        let overlaps = NSMutableArray()
        
        for i in 0..<overlapIndicies!.count {
            
            if (i < kMaxNumberOverlaps / 3 || (i > ((overlapIndicies?.count)! / 2 - kMaxNumberOverlaps / 6) && i < ((overlapIndicies?.count)! / 2 + kMaxNumberOverlaps / 6)) ||
                i > (overlapIndicies?.count)! - kMaxNumberOverlaps / 3) {
                overlaps.add(overlapIndicies![i])
            }
        }
        
        let timeOverlapIndicies = NSMutableArray()
        let progressionOverlapIndicies = NSMutableArray()
        
        var timeOverlap: Float = 0.0
        
        for i in 0..<overlaps.count {
            // Calculate the time overlap by dividing the overlap indicie int value by the amount of exposures
            timeOverlap = Float(truncating: overlaps[i] as! NSNumber) / Float(photosNumberInputView.value)
            
            // Add the Time Overlap to the timeOverlapIndicies Array
            timeOverlapIndicies.add(NSNumber(value: timeOverlap as Float))
            
            // Use the interpolation function from the CubicBezierCalculator to calculate progression from each time overlap
            progressionOverlapIndicies.add(NSNumber(value: interpolator!.interpolation(timeOverlap) ))
        }
        
        // Pass the overlapping points to the bezier graph view to display them
        bezierGraphView.overlappingPoints(withTime: timeOverlapIndicies, withProgression: progressionOverlapIndicies)
    }
    
    fileprivate func animateShutterButton() {
        
        if clockIsAnimating == false {
            
            UIView.transition(with: clockView, duration: kShutterButtonAnimationDuration, options: [UIViewAnimationOptions.transitionFlipFromRight, UIViewAnimationOptions.showHideTransitionViews], animations: { () -> Void in
                self.shutterButton.alpha = self.clockView.isHidden ? 1 : 0
                }, completion: { (finished: Bool) -> Void in
                    self.clockView.isHidden = !self.clockView.isHidden
            })
            
            UIView.transition(with: shutterButton, duration: kShutterButtonAnimationDuration, options: [UIViewAnimationOptions.transitionFlipFromRight, UIViewAnimationOptions.showHideTransitionViews], animations: { () -> Void in
                self.shutterButton.alpha = self.clockView.isHidden ? 0 : 1
                self.clockView.alpha = self.clockView.isHidden ? 1 : 0
                }, completion: { (finished: Bool) -> Void in
                    self.shutterButton.isHidden = !self.shutterButton.isHidden
            })
        }
    }
    
    fileprivate func animateClock() {
        
        configureInterpolator()
        
        CATransaction.begin()
        CATransaction.setValue(NSNumber(value: kClockAnimationDuration as Double), forKey: kCATransactionAnimationDuration)
        
        CATransaction.setCompletionBlock { () -> Void in
            self.showPreviewButtonAnimation()
        }
        
        let animation = AccelerationAnimation.animation(withKeyPath: "transform.rotation", startValue: 0.0, endValue: degreesToRadians(360.0), evaluationObject: interpolator, interstitialSteps: UInt(photosNumberInputView.value)) as! AccelerationAnimation
        
        animation.delegate = self as? CAAnimationDelegate
        
        secondsView.layer.add(animation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    fileprivate func showPreviewButtonAnimation() {
        animateShutterButton()
        
        UIView.animate(withDuration: kShutterButtonAnimationDuration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.previewButton.transform = CGAffineTransform(scaleX: 1, y: 1)
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
    
    fileprivate func hidePreviewButtonAnimation() {
        
        UIView.animate(withDuration: kShutterButtonAnimationDuration, animations: { () -> Void in
            self.previewButton.transform = CGAffineTransform(scaleX: 1, y: 0)
            } , completion: {(finished: Bool) -> Void in
                
                if finished == true {
                    self.animateClock()
                }
        })
    }
    
    fileprivate func dismissFeedbackView(_ animated: Bool) {
        var duration = 0.0
        var delay = 0.0
        
        if animated {
            duration = 0.3
            delay = 0.1
        }
        
        let verticalFlip = CGAffineTransform(scaleX: 1, y: 1)
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            
            for i in 0..<self.timeWarpView.subviews.count {
                
                let subView = self.timeWarpView.subviews[i]
                
                if subView.isDescendant(of: self.visibleView) == false {
                    subView.alpha = 0.0
                }
            }
            
            self.tickImageView.transform = verticalFlip
            
            UIView.animate(withDuration: duration - delay, delay: delay, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                self.feedbackToWhiteViewConstraint.constant = 0
                self.view.layoutIfNeeded()
                }, completion: { (finished: Bool) -> Void in
                    
                    for i in 0..<self.timeWarpView.subviews.count {
                        
                        let subView = self.timeWarpView.subviews[i] 
                        
                        if subView.isDescendant(of: self.visibleView) == false {
                            subView.alpha = 0.0
                        }
                    }
            })
        })
    }
    
    fileprivate func presentFeedbackView(_ animated: Bool) {
        
        var duration = 0.0
        var delay = 0.0
        
        if animated {
            duration = 0.3
            delay = 0.1
        }
        
        let verticalFlip: CGAffineTransform = CGAffineTransform(scaleX: 1, y: -1)
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            
            self.tickImageView.transform = verticalFlip
            self.feedbackToWhiteViewConstraint.constant = self.topLeftView.frame.size.height - self.visibleView.frame.size.height
            
            UIView.animate(withDuration: duration - delay, delay: delay, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                
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
    
    fileprivate func configureInterpolator() {
        let controlPoint1: CGPoint = bezierGraphView.controlPoint1GraphLocation() as CGPoint
        let controlPoint2: CGPoint = bezierGraphView.controlPoint2GraphLocation() as CGPoint
        
        interpolator?.setControlPoints_x1(Float(controlPoint1.x), y1: Float(controlPoint1.y), x2: Float(controlPoint2.x), y2: Float(controlPoint2.y))
    }
    
    fileprivate func degreesToRadians(_ degrees: Double) -> Double {
        return degrees / 180.0 * Double.pi
    }
    
    fileprivate func radiansToDegrees(_ radians: Double) -> Double {
        return radians  * (180.0 / Double.pi)
    }
    
    override func didDispatch(_ dispatchable: Dispatchable) {
        super.didDispatch(dispatchable)
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is TimeWarpViewController && dispatchable is Pulse {
            shotsTakenCount += 1
            feedbackViewController.shotsTakenLabel?.text = "\(shotsTakenCount)/\(shotsToTakeCount)"
        }
    }
    
    override func willDispatch(_ dispatchable: Dispatchable) {
        super.willDispatch(dispatchable) 
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is TimeWarpViewController {
            
            feedbackViewController.elapsedCounterLabel?.stop()
            feedbackViewController.elapsedCounterLabel?.startValue = UInt64(dispatchable.durationInMilliseconds())
            feedbackViewController.elapsedCounterLabel?.start()
        }
    } 
    
    // MARK: - Public
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is TimeWarpViewController {
            
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
    
    func ttNumberInputKeyboardDidDismiss() {
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

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
