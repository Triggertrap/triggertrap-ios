//
//  MotionSensorViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class MotionSensorViewController: SensorViewController, MotionDelegate {
    
    // MARK: - Properties
    
    private var motionDetectionViewController: MotionDetectionViewController!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        motionDetectionViewController = self.childViewControllers.last as! MotionDetectionViewController
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        WearablesManager.sharedInstance.delegate = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        motionDetectionViewController.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func shutterButtonTouchUpInside(sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            if cameraPermissionAuthorized() {
                startCameraSensorMode()
            }
            
        } else {
            sequenceManager.cancel() 
        }
    }
    
    override func startCameraSensorMode() {
        if sufficientVolumeToTrigger() {
            self.prepareForSequence()
            waitingForSensorResetDelay = false
            motionDetectionViewController.delegate = self
            sequenceManager.activeViewController = self
            startShutterButtonAnimation()
        }
    }
    
    // MARK: - Motion Delegate
    
    func motionDetected(detected: Bool) {
        if detected {
            // Start the sequence with the stored pulse length from the settings manager
            triggerNow()
        }
    }
     
    // MARK: - Activity Manager Delegates 
    
    override func didCancelSequence() {
        super.didCancelSequence()
        motionDetectionViewController.delegate = nil
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        motionDetectionViewController.rotationButton?.setImage(ImageWithColor(UIImage(named: "Camera-Rotate")!, color: UIColor.triggertrap_fillColor()), forState: .Normal)
        motionDetectionViewController.slider?.thumbTintColor = UIColor.triggertrap_fillColor()
        motionDetectionViewController.slider?.maximumTrackTintColor = UIColor.triggertrap_naturalColor()
        motionDetectionViewController.slider?.minimumTrackTintColor = UIColor.triggertrap_primaryColor()
    }
}

extension MotionSensorViewController: WearableManagerDelegate {
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}
