//
//  SensorViewController.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 12/10/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

import UIKit

class SensorViewController: TTViewController {
    var waitingForSensorResetDelay = false
    
    // MARK: - Public
    
    func triggerNow() {
        triggerWithSensorDelay()
    }
    
    func cameraPermissionAuthorized() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            return true
            
        case .denied:
            showCameraPermissionDeniedNotification()
            return false
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) -> Void in
                if granted {
                    onMain {
                        self.startCameraSensorMode()
                    }
                } else {
                    onMain {
                        self.showCameraPermissionDeniedNotification()
                    }
                }
            })
            return false
            
        case .restricted:
            showCameraPermissionDeniedNotification()
            return false
        @unknown default:
            showCameraPermissionDeniedNotification()
            return false
        }
    }
    
    func showCameraPermissionDeniedNotification() {
        ShowAlertInViewController(self, title: NSLocalizedString("Where have you gone?", comment: "Where have you gone?"), message: NSLocalizedString("I can't see you... is Camera permission denied, perhaps?", comment: "I can't see you... is Camera permission denied, perhaps?"), cancelButton: NSLocalizedString("OK", comment: "OK"))
    }
    
    // Override this function to start the sensor mode once the permission has been granted
    func startCameraSensorMode() {
    
    }
    
    // MARK: - Private 
    
    fileprivate func triggerWithSensorDelay() {
        if !waitingForSensorResetDelay {
            waitingForSensorResetDelay = true
            
            PreciseTimer.scheduleBlock({ () -> Void in
                self.triggerWithSensorResetDelay()
                }, inTimeInterval: (settingsManager?.sensorDelay.doubleValue)! / MillisecondsPerSecond)
        }
    }
    
    fileprivate func triggerWithSensorResetDelay() {
        
        onMain {
            self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: (self.settingsManager?.pulseLength.doubleValue)!, unit: .milliseconds))]), repeatSequence: false)
        }
        
        PreciseTimer.scheduleBlock({ () -> Void in
            self.waitingForSensorResetDelay = false
            }, inTimeInterval: (settingsManager?.sensorResetDelay.doubleValue)! / MillisecondsPerSecond)
    } 
    
    override func didFinishSequence() {
        // Override default behaviour - red view won't get dismissed
    }
}
