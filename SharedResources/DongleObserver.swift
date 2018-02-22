//
//  DongleManager.swift
//  Timelapse Pro
//
//  Created by Valentin Kalchev on 15/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class DongleObserver {
    
    var dongleConnected = false
    
    fileprivate var audioJackObserver: AnyObject!
    
    static let sharedInstance = DongleObserver()
    
    func dongleConnectedToPhone() {
        let session = AVAudioSession.sharedInstance()
        if session.currentRoute.outputs.count != 0 {
            let output: AVAudioSessionPortDescription = session.currentRoute.outputs[0]
            self.dongleConnected = (output.portType == AVAudioSessionPortHeadphones) ? true : false
        
            print("Dongle Connected: \(self.dongleConnected)")
        }
    }
    
    func startSession() {
        audioJackObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVAudioSessionRouteChange, object: nil, queue: OperationQueue.main, using: {
                (note:Notification!) in
                
                // Determine whether dongle is connected to the phone
                self.dongleConnectedToPhone() 
        })
    }
    
    func endSession() {
        NotificationCenter.default.removeObserver(self.audioJackObserver)
    }
}
