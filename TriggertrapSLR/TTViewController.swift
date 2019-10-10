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
import MPGNotification
import pop

/**
 The `TTViewController`
 */
class TTViewController: SplitLayoutViewController, DispatchableLifecycle, SequenceLifecycle {
    
    @IBOutlet weak var shutterButton: ShutterButton!
    @IBOutlet weak var bulbButton: UIButton?
    
    /** Instance of the `SequenceManager`. */
    let sequenceManager = SequenceManager.sharedInstance
    
    /** Reference of the `AppDelegate`. */
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /** Instance of the `SettingsManager`. */
    let settingsManager = SettingsManager.sharedInstance()
    
    /** Instance of the `FeedbackViewController`. */
    var feedbackViewController: FeedbackViewController!
    
    fileprivate var notification = MPGNotification(title: NSLocalizedString("Low Volume", comment: "Low Volume"),
                                               subtitle: nil,
                                               backgroundColor: UIColor.triggertrap_primaryColor(1.0),
                                               iconImage: nil)
    
    fileprivate var notificationIsVisible = false
    
    fileprivate var shownVolumeAlert = false
    
    // MARK: Properties
    
    fileprivate var feedbackView: UIView!
    
    var feedbackViewVisible: Bool {
        get {
            return feedbackViewIsVisible
        }
    }
    
    fileprivate var feedbackViewIsVisible = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) 
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(TTViewController.enableShutterButton), name: NSNotification.Name(rawValue: FeedbackViewHideAnimationCompleted), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TTViewController.activeViewControllerLostFocus), name: NSNotification.Name(rawValue: "ActiveViewControllerLostFocus"), object: nil)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if sequenceManager.activeViewController == nil && shutterButton != nil  {
            pop(shutterButton, fromScale: 0.5, toScale: 1.0)
        }
        
        if UserDefaults.standard.object(forKey: ConstFirstAppLaunch) == nil {
            
            // Show the tutorial after half a second
            
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                self.appDelegate.presentTutorial(self)
            }
            
            UserDefaults.standard.set(true, forKey: ConstFirstAppLaunch)
            UserDefaults.standard.synchronize()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.shutterButton?.refreshView()
        
        if let _ = self.notification {
            self.notification?.frame = CGRect(origin: (self.notification?.frame.origin)!, size: CGSize(width: self.view.frame.width, height: (self.notification?.frame.height)!))
            
            self.notification?.contentSize = CGSize(width: (self.notification?.frame.width)!, height: 2 * (self.notification?.frame.height)!); 
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        self.shutterButton.performThemeUpdate()
        
        if let _ = feedbackViewController {
            self.feedbackViewController.performThemeUpdate()
        }
        
        self.leftButton?.setBackgroundImage(#imageLiteral(resourceName: "MenuIcon"), for: .normal)
        self.leftButton?.tintColor = UIColor.triggertrap_fillColor(1)
        
        self.rightButton?.setBackgroundImage(#imageLiteral(resourceName: "OptionsIcon"), for: .normal)
        self.rightButton?.tintColor = UIColor.triggertrap_fillColor(1)
        
        self.bulbButton?.setImage(ImageWithColor(UIImage(named: "BulbIcon")!, color: UIColor.triggertrap_primaryColor()), for: UIControl.State())
        self.bulbButton?.imageView?.contentMode = .scaleAspectFit
    }
    
    // MARK: - Notifications
    
    // Enable shutter button when another mode finishes
    @objc func enableShutterButton() {
        shutterButtonEnabled(true)
    }
    
    // When Menu or Options is shown the active view controller gets notified that it has lost focus. Quick Release and Press and Hold use this method to stop the mode in case user is holding the button and trying to open the menu/options.
    @objc func activeViewControllerLostFocus() {}
    
    fileprivate func showVolumeAlert() {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: NSLocalizedString("Low Volume", comment: "Low Volume"),
                message: NSLocalizedString("Please set the volume to maximum to use Triggertrap mobile", comment: "Please set the volume to maximum to use Triggertrap mobile"),
                preferredStyle: UIAlertController.Style.alert)
            
            // The order in which we add the buttons matters.
            // Add the Cancel button first to match the iOS 7 default style,
            // where the cancel button is at index 0.
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                style: UIAlertAction.Style.default,
                handler: { (action: UIAlertAction!) in
                    self.handelCancel()
            }))
            
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    fileprivate func showVolumeNotification() {
        guard !self.notificationIsVisible else {
            return
        }
        
        //run on the main thread to avoid race conditions
        DispatchQueue.main.async {
            self.notificationIsVisible = true
        }
        
        let delay = 0.3
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            //called when the notification is dismissed
            self.notification?.dismissHandler = {(_ notification: MPGNotification?) -> Void in
                //run on the main thread to avoid race conditions
                DispatchQueue.main.async {
                    self.notificationIsVisible = false
                }
            }
            
            self.notification?.backgroundColor = UIColor.triggertrap_primaryColor()
            self.notification?.titleColor = UIColor.triggertrap_fillColor()
            self.notification?.duration = 2.0
            self.notification?.restyleNotification();
            self.notification?.show()
            //this needs to be reinstantiated each time to avoid glitchy behavior (sadly)
            self.notification = MPGNotification(title: NSLocalizedString("Low Volume", comment: "Low Volume"),
                                                subtitle: nil,
                                                backgroundColor: UIColor.triggertrap_primaryColor(1.0),
                                                iconImage: nil)
        })
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *){
            performThemeUpdate()
        }
    }
    
    // MARK: - Actions
    
    /**
     Shows an alert to the user, indicating that the camera needs to be set to Bulb.
     
     - Parameters:
     - sender: The `UIButton` that recieves the action.
     */
    @IBAction func bulbButtonTapped(_ sender: UIButton) {
        
        ShowAlertInViewController(self, title: NSLocalizedString("Bulb Required!", comment: "Bulb Required!"), message: NSLocalizedString("Please make sure your camera is set to Bulb to use this mode correctly.", comment: "Please make sure your camera is set to Bulb to use this mode correctly."), cancelButton: NSLocalizedString("OK", comment: "OK"))
    }
    
    // MARK: - Public 
    
    func shutterButtonEnabled(_ enabled: Bool) {
        shutterButton?.alpha = enabled ? 1.0 : 0.3 
        shutterButton?.isEnabled = enabled ? true : false
    }
    
    func bulbButtonEnabled(_ enabled: Bool) {
        bulbButton?.alpha = enabled ? 1.0 : 0.3
        bulbButton?.isEnabled = enabled ? true : false
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
    
    func pop(_ viewToAnimate: UIView, fromScale: CGFloat, toScale: CGFloat) {
        onMain {
            let springAnimation = POPSpringAnimation()
            springAnimation.property = POPAnimatableProperty.property(withName: kPOPViewScaleXY) as? POPAnimatableProperty
            springAnimation.springBounciness = 8.0
            springAnimation.springSpeed = 10.0
            springAnimation.fromValue = NSValue(cgSize: CGSize(width: fromScale, height: fromScale))
            springAnimation.toValue = NSValue(cgSize: CGSize(width: toScale, height: toScale))
            viewToAnimate.pop_add(springAnimation, forKey: "size")
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
        if UserDefaults.standard.bool(forKey: constUserActivated) == false && DongleObserver.sharedInstance.dongleConnected {
            
            UserDefaults.standard.set(true, forKey: constUserActivated)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func handelCancel() {
        shownVolumeAlert = true
    }
    
    func showFeedbackView(_ storyboardIdentifier: String) {
        
        // Executed regardless of the guard
        defer {
            if !feedbackViewIsVisible {
                
                // Disable the bulb icon when feedback view is visible
                bulbButtonEnabled(false)
                
                shutterButton.isEnabled = false
                startShutterButtonAnimation()
                
                self.feedbackView.alpha = 0.0
                self.feedbackView.isHidden = false
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                    self.feedbackView.alpha = 1.0
                    }, completion: { (finished) -> Void in
                        self.feedbackViewShowAnimationCompleted()
                })
            }
        }
        
        guard let _ = self.feedbackViewController else {
            let storyboard = UIStoryboard(name: ConstStoryboardIdentifierFeedback, bundle: nil);
            
            self.feedbackViewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? FeedbackViewController
            
            self.addChild(self.feedbackViewController!)
            
            self.feedbackViewController.didMove(toParent: self)
            self.feedbackViewController.view.frame = topLeftView.frame
            self.feedbackView = self.feedbackViewController.view
            
            self.feedbackView.autoresizesSubviews = true
            self.feedbackView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            
            topLeftView.addSubview(self.feedbackView)
            return
        }
    }
    
    func hideFeedbackView() {
        // If feedback view is visible - hide it
        if feedbackViewIsVisible {
            shutterButton.isEnabled = false
            
            if let feedbackViewController = self.feedbackViewController {
                feedbackViewController.stopAnimations()
            }
            
            if let _ = self.feedbackView {
                self.feedbackView.alpha = 1.0
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                    self.feedbackView.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        self.feedbackViewHideAnimationCompleted()
                })
            }
        }
    }
    
    func feedbackViewShowAnimationCompleted() {
        feedbackViewIsVisible = true
        shutterButton.isEnabled = true
    }
    
    func feedbackViewHideAnimationCompleted() { 
        self.shutterButton?.stopAnimating()
        
        // Enable the bulb icon when feedback view gets dismissed
        bulbButtonEnabled(true)
        
        self.topLeftView.setNeedsDisplay()
        self.feedbackViewIsVisible = false
        
        if let _ = self.feedbackView {
            self.feedbackView.isHidden = true
        }
        
        shutterButton.isEnabled = true
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: FeedbackViewHideAnimationCompleted), object: nil)
    }
    
    // MARK: - Dispatchable Lifecycle
    
    func willDispatch(_ dispatchable: Dispatchable) {}
    
    func didDispatch(_ dispatchable: Dispatchable) {
        
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DidRemoveActiveViewController"), object:self)
        
        stopShutterButtonAnimation()
        
        sequenceManager.activeViewController = nil
        sequenceManager.dispatchableDelegate = nil
        sequenceManager.sequenceDelegate = nil
        
        //Check if feedback view exist and disable shutter button if it does, else enable shutter button
        
        feedbackViewIsVisible ? hideFeedbackView() : shutterButtonEnabled(true) 
    }
}
