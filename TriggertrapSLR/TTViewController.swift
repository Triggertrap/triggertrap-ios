//
//  TTViewController.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 08/10/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit
import CoreGraphics
import AVFoundation

/**
The `TTViewController`
*/
class TTViewController: SplitLayoutViewController, UIAlertViewDelegate, DispatchableLifecycle, SequenceLifecycle {
    
    @IBOutlet weak var shutterButton: ShutterButton!
    @IBOutlet weak var bulbButton: UIButton?
    
    /** Instance of the `SequenceManager`. */
    let sequenceManager = SequenceManager.sharedInstance
    
    /** Reference of the `AppDelegate`. */
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    /** Instance of the `SettingsManager`. */
    let settingsManager = SettingsManager.sharedInstance()
    
    /** Instance of the `FeedbackViewController`. */
    var feedbackViewController: FeedbackViewController!
    
    private var notification = MPGNotification(title: NSLocalizedString("Low Volume", comment: "Low Volume"),
        subtitle: nil,
        backgroundColor: UIColor.triggertrap_primaryColor(1.0),
        iconImage: nil)
    
    private var shownVolumeAlert = false
    
    // MARK: Properties
    
    private var feedbackView: UIView!
    
    var feedbackViewVisible: Bool {
        get {
            return feedbackViewIsVisible
        }
    }
    
    private var feedbackViewIsVisible = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) 
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableShutterButton", name: FeedbackViewHideAnimationCompleted, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "activeViewControllerLostFocus", name: "ActiveViewControllerLostFocus", object: nil)
        
        guard let activeViewController = sequenceManager.activeViewController else {
            // There is no active view controller, check that wifi and wearables are also not present and dismiss the red view if visible
            if WifiDispatcher.sharedInstance.remoteOutputServer.delegate == nil && !WearablesManager.sharedInstance.isWearablesModeRunning() {
                feedbackViewHideAnimationCompleted()
            }
            return
        }
        
        if activeViewController as! TTViewController == self {
            // Enable shutter button and resume the feedback view animation if active view controller is self
            shutterButtonEnabled(true)
            feedbackViewController?.resumeAnimations()
        } else {
            // Disable shutter button
            shutterButtonEnabled(false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if sequenceManager.activeViewController == nil && shutterButton != nil  {
            pop(shutterButton, fromScale: 0.5, toScale: 1.0)
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey(ConstFirstAppLaunch) == nil {
            
            // Show the tutorial after half a second
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(0.5 * Double(NSEC_PER_SEC)))
            
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                
                self.appDelegate.presentTutorial(self)
            }
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: ConstFirstAppLaunch)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.shutterButton?.refreshView()
        
        if let _ = self.notification {
            self.notification.frame = CGRect(origin: self.notification.frame.origin, size: CGSize(width: self.view.frame.width, height: self.notification.frame.height))
            
            self.notification.contentSize = CGSizeMake(CGRectGetWidth(self.notification.frame), 2 * CGRectGetHeight(self.notification.frame)); 
        }
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        self.shutterButton.performThemeUpdate()
        
        if let _ = feedbackViewController {
            self.feedbackViewController.performThemeUpdate()
        }
        
        self.leftButton?.setBackgroundImage(ImageWithColor(UIImage(named: "MenuIcon")!, color: UIColor.triggertrap_fillColor()) , forState: .Normal)
        
        self.rightButton?.setBackgroundImage(ImageWithColor(UIImage(named: "OptionsIcon")!, color: UIColor.triggertrap_fillColor()) , forState: .Normal)
        
        self.bulbButton?.setImage(ImageWithColor(UIImage(named: "BulbIcon")!, color: UIColor.triggertrap_primaryColor()), forState: .Normal)
        self.bulbButton?.imageView?.contentMode = .ScaleAspectFit
    }
    
    // MARK: - Notifications
    
    // Enable shutter button when another mode finishes
    func enableShutterButton() {
        shutterButtonEnabled(true)
    }
    
    // When Menu or Options is shown the active view controller gets notified that it has lost focus. Quick Release and Press and Hold use this method to stop the mode in case user is holding the button and trying to open the menu/options.
    func activeViewControllerLostFocus() {}
    
    private func showVolumeAlert() {
        dispatch_async(dispatch_get_main_queue(), {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: NSLocalizedString("Low Volume", comment: "Low Volume"),
                    message: NSLocalizedString("Please set the volume to maximum to use Triggertrap mobile", comment: "Please set the volume to maximum to use Triggertrap mobile"),
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                // The order in which we add the buttons matters.
                // Add the Cancel button first to match the iOS 7 default style,
                // where the cancel button is at index 0.
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                    style: UIAlertActionStyle.Default,
                    handler: { (action: UIAlertAction!) in
                        self.handelCancel()
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertView(title: NSLocalizedString("Low Volume", comment: "Low Volume"), message: NSLocalizedString("Please set the volume to maximum to use Triggertrap mobile", comment: "Please set the volume to maximum to use Triggertrap mobile"), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
                alert.show()
            }
        })
    }
    
    private func showVolumeNotification() {
        let delay = 0.3
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            
            // Only show the notification again if it is not currently presented
            if !self.notification.isAnimating {
                self.notification.backgroundColor = UIColor.triggertrap_primaryColor()
                self.notification.titleColor = UIColor.triggertrap_fillColor()
                self.notification.show()
                self.notification.duration = 2.0
            }
        })
    }
    
    // MARK: - Actions
    
    /**
    Shows an alert to the user, indicating that the camera needs to be set to Bulb.
    
    - Parameters:
    - sender: The `UIButton` that recieves the action.
    */
    @IBAction func bulbButtonTapped(sender: UIButton) {
        
        ShowAlertInViewController(self, title: NSLocalizedString("Bulb Required!", comment: "Bulb Required!"), message: NSLocalizedString("Please make sure your camera is set to Bulb to use this mode correctly.", comment: "Please make sure your camera is set to Bulb to use this mode correctly."), cancelButton: NSLocalizedString("OK", comment: "OK"))
    }
    
    // MARK: - Public 
    
    func shutterButtonEnabled(enabled: Bool) {
        shutterButton?.alpha = enabled ? 1.0 : 0.3 
        shutterButton?.enabled = enabled ? true : false
    }
    
    func bulbButtonEnabled(enabled: Bool) {
        bulbButton?.alpha = enabled ? 1.0 : 0.3
        bulbButton?.enabled = enabled ? true : false
    }
    
    func startShutterButtonAnimation() {
        onMain {
            self.pop(self.shutterButton, fromScale: 1.0, toScale: 0.9)
            self.shutterButton.startAnimating()
        }
    }
    
    func stopShutterButtonAnimation() {
        onMain {
            self.shutterButton.stopAnimating()
            self.pop(self.shutterButton, fromScale: 0.9, toScale: 1.0)
        }
    }
    
    func pop(viewToAnimate: UIView, fromScale: CGFloat, toScale: CGFloat) {
        onMain {
            let springAnimation = POPSpringAnimation()
            springAnimation.property = POPAnimatableProperty.propertyWithName(kPOPViewScaleXY) as! POPAnimatableProperty
            springAnimation.springBounciness = 8.0
            springAnimation.springSpeed = 10.0
            springAnimation.fromValue = NSValue(CGSize: CGSizeMake(fromScale, fromScale))
            springAnimation.toValue = NSValue(CGSize: CGSizeMake(toScale, toScale))
            viewToAnimate.pop_addAnimation(springAnimation, forKey: "size")
        }
    }
    
    func sufficientVolumeToTrigger() -> Bool {
        
        if AVAudioSession.sharedInstance().outputVolume >= 1.0 {
            return true
        } else {
            if shownVolumeAlert {
                showVolumeNotification()
                
                // We've warned them one before
                // If they want to ignore us them let them go ahead
                // (The camera won't trigger if the volume is too low)
                return true
            } else {
                showVolumeAlert()
                return false
            }
        }
    }
    
    /*!
    * prepareForSequence should be called before sending a sequence to the output manager.
    * This sets the revelant delegates on the view controller.
    */
    
    func prepareForSequence() {
        sequenceManager.sequenceDelegate = self
        sequenceManager.dispatchableDelegate = self
        
        OutputDispatcher.sharedInstance.activeDispatchers = [HeadphoneDispatcher.sharedInstance, WifiDispatcher.sharedInstance]
        
        // If dongle is connected and user has not been activated, send an event to Mixpanel that the user has been activated
        if NSUserDefaults.standardUserDefaults().boolForKey(constUserActivated) == false && DongleObserver.sharedInstance.dongleConnected {
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: constUserActivated)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            handelCancel()
        }
    }
    
    func handelCancel() {
        shownVolumeAlert = true
    }
    
    func showFeedbackView(storyboardIdentifier: String) {
        
        // Executed regardless of the guard
        defer {
            if !feedbackViewIsVisible {
                
                // Disable the bulb icon when feedback view is visible
                bulbButtonEnabled(false)
                
                shutterButton.enabled = false
                startShutterButtonAnimation()
                
                self.feedbackView.alpha = 0.0
                self.feedbackView.hidden = false
                
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                    self.feedbackView.alpha = 1.0
                    }, completion: { (finished) -> Void in
                        self.feedbackViewShowAnimationCompleted()
                })
            }
        }
        
        guard let _ = self.feedbackViewController else {
            let storyboard = UIStoryboard(name: ConstStoryboardIdentifierFeedback, bundle: nil);
            
            self.feedbackViewController = storyboard.instantiateViewControllerWithIdentifier(storyboardIdentifier) as! FeedbackViewController
            
            self.addChildViewController(self.feedbackViewController!)
            
            self.feedbackViewController.didMoveToParentViewController(self)
            self.feedbackViewController.view.frame = topLeftView.frame
            self.feedbackView = self.feedbackViewController.view
            
            self.feedbackView.autoresizesSubviews = true
            self.feedbackView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            
            topLeftView.addSubview(self.feedbackView)
            return
        }
    }
    
    func hideFeedbackView() {
        // If feedback view is visible - hide it
        if feedbackViewIsVisible {
            shutterButton.enabled = false
            
            if let feedbackViewController = self.feedbackViewController {
                feedbackViewController.stopAnimations()
            }
            
            if let _ = self.feedbackView {
                self.feedbackView.alpha = 1.0
                
                UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                    self.feedbackView.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        self.feedbackViewHideAnimationCompleted()
                })
            }
        }
    }
    
    func feedbackViewShowAnimationCompleted() {
        feedbackViewIsVisible = true
        shutterButton.enabled = true
    }
    
    func feedbackViewHideAnimationCompleted() { 
        self.shutterButton?.stopAnimating()
        
        // Enable the bulb icon when feedback view gets dismissed
        bulbButtonEnabled(true)
        
        self.topLeftView.setNeedsDisplay()
        self.feedbackViewIsVisible = false
        
        if let _ = self.feedbackView {
            self.feedbackView.hidden = true
        }
        
        shutterButton.enabled = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(FeedbackViewHideAnimationCompleted, object: nil)
    }
    
    // MARK: - Dispatchable Lifecycle
    
    func willDispatch(dispatchable: Dispatchable) {}
    
    func didDispatch(dispatchable: Dispatchable) {
        
    } 
    
    // MARK: - Sequence Lifecycle
    
    func didCancelSequence() {
        onMain {
            self.didRemoveActiveViewController()
        }
    }
    
    func didFinishSequence() { 
        onMain {
            self.didRemoveActiveViewController()
        }
    }
    
    // MARK: - Delegates
    
    func didRemoveActiveViewController() {
        
        // Update LeftPanelTableViewController spinners
        NSNotificationCenter.defaultCenter().postNotificationName("DidRemoveActiveViewController", object:self)
        
        stopShutterButtonAnimation()
        
        sequenceManager.activeViewController = nil
        sequenceManager.dispatchableDelegate = nil
        sequenceManager.sequenceDelegate = nil
        
        //Check if feedback view exist and disable shutter button if it does, else enable shutter button
        
        feedbackViewIsVisible ? hideFeedbackView() : shutterButtonEnabled(true) 
    }
}