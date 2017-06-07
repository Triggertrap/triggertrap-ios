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
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .Authorized:
            return true
            
        case .Denied:
            showCameraPermissionDeniedNotification()
            return false
            
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
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
            
        case .Restricted:
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
    
    private func triggerWithSensorDelay() {
        if !waitingForSensorResetDelay {
            waitingForSensorResetDelay = true
            
            PreciseTimer.scheduleBlock({ () -> Void in
                self.triggerWithSensorResetDelay()
                }, inTimeInterval: settingsManager.sensorDelay.doubleValue / MillisecondsPerSecond)
        }
    }
    
    private func triggerWithSensorResetDelay() {
        
        onMain {
            self.sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: self.settingsManager.pulseLength.doubleValue, unit: .Milliseconds))]), repeatSequence: false)
        }
        
        PreciseTimer.scheduleBlock({ () -> Void in
            self.waitingForSensorResetDelay = false
            }, inTimeInterval: settingsManager.sensorResetDelay.doubleValue / MillisecondsPerSecond)
    } 
    
    override func didFinishSequence() {
        // Override default behaviour - red view won't get dismissed
    }
}
