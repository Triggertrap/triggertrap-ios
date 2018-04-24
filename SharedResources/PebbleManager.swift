//
//  PebbleManager.swift
//  Timelapse Pro
//
//  Created by Valentin Kalchev on 28/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class PebbleManager: NSObject {

    fileprivate var pebbleWatch: PBWatch?
    fileprivate let pebbleCentral = PBPebbleCentral.default()
    fileprivate var pebbleConnected = false
    
    static let sharedInstance = PebbleManager()

    func setupPebbleWatch() {

        let pebbleAppId = Bundle.main.object(forInfoDictionaryKey: constPebbleAppId) as! String
        let myAppUUID = UUID()
        
        pebbleCentral.appUUID = myAppUUID
        pebbleCentral.run()
        pebbleCentral.delegate = self
        pebbleCentral.dataLoggingService(forAppUUID: myAppUUID)?.delegate = self
        
        pebbleWatch = pebbleCentral.lastConnectedWatch()
        
        // Determine whether a watch is connected when the app first starts
        pebbleConnected = pebbleCentral.connectedWatches.count > 0 ? true : false
        
        pebbleWatch?.appMessagesAddReceiveUpdateHandler({ (watch, update) -> Bool in
            print("Trigger")
            NotificationCenter.default.post(name: Notification.Name(rawValue: constWatchDidTrigger), object: nil)
            return true
        })
    }
    
    var isPebbleConnected: Bool {
        get {
            return pebbleConnected
        }
    }
    
    func openPebbleApp() {
        pebbleWatch?.appMessagesLaunch({ (watch, error) -> Void in
            print("Open Triggertrap App on Pebble")
        })
    }
}

extension PebbleManager: PBPebbleCentralDelegate {
    func pebbleCentral(_ central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        pebbleWatch = watch
        
        // In case we need to change the UI
         NotificationCenter.default.post(name: Notification.Name(rawValue: constPebbleWatchStatusChanged), object: nil, userInfo: ["connected": true])
        pebbleConnected = true
        
        pebbleWatch?.appMessagesAddReceiveUpdateHandler({ (watch, update) -> Bool in
            print("Trigger")
            NotificationCenter.default.post(name: Notification.Name(rawValue: constWatchDidTrigger), object: nil)
            return true
        })
    }
    
    func pebbleCentral(_ central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        
        if pebbleWatch == watch || watch.isEqual(pebbleWatch) {
            pebbleWatch = nil
        }
        
        // In case we need to change the UI
        pebbleConnected = false
         NotificationCenter.default.post(name: Notification.Name(rawValue: constPebbleWatchStatusChanged), object: nil, userInfo: ["connected": false])
    }
}

extension PebbleManager: PBDataLoggingServiceDelegate {
    
    func dataLoggingService(_ service: PBDataLoggingService, hasByteArrays bytes: UnsafePointer<UInt8>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        return true
    }
}
