//
//  PebbleManager.swift
//  Timelapse Pro
//
//  Created by Valentin Kalchev on 28/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class PebbleManager: NSObject {

    private var pebbleWatch: PBWatch?
    private let pebbleCentral = PBPebbleCentral.defaultCentral()
    private var pebbleConnected = false
    
    static let sharedInstance = PebbleManager()

    func setupPebbleWatch() {

        let pebbleAppId = NSBundle.mainBundle().objectForInfoDictionaryKey(constPebbleAppId) as! String
        let myAppUUID = NSUUID(UUIDString:pebbleAppId)!
        
        pebbleCentral.appUUID = myAppUUID
        pebbleCentral.run()
        pebbleCentral.delegate = self
        pebbleCentral.dataLoggingServiceForAppUUID(myAppUUID)?.delegate = self
        
        pebbleWatch = pebbleCentral.lastConnectedWatch()
        
        // Determine whether a watch is connected when the app first starts
        pebbleConnected = pebbleCentral.connectedWatches.count > 0 ? true : false
        
        pebbleWatch?.appMessagesAddReceiveUpdateHandler({ (watch, update) -> Bool in
            print("Trigger")
            NSNotificationCenter.defaultCenter().postNotificationName(constWatchDidTrigger, object: nil)
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
    func pebbleCentral(central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        pebbleWatch = watch
        
        // In case we need to change the UI
         NSNotificationCenter.defaultCenter().postNotificationName(constPebbleWatchStatusChanged, object: nil, userInfo: ["connected": true])
        pebbleConnected = true
        
        pebbleWatch?.appMessagesAddReceiveUpdateHandler({ (watch, update) -> Bool in
            print("Trigger")
            NSNotificationCenter.defaultCenter().postNotificationName(constWatchDidTrigger, object: nil)
            return true
        })
    }
    
    func pebbleCentral(central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        
        if pebbleWatch == watch || watch.isEqual(pebbleWatch) {
            pebbleWatch = nil
        }
        
        // In case we need to change the UI
        pebbleConnected = false
         NSNotificationCenter.defaultCenter().postNotificationName(constPebbleWatchStatusChanged, object: nil, userInfo: ["connected": false])
    }
}

extension PebbleManager: PBDataLoggingServiceDelegate {
    
    func dataLoggingService(service: PBDataLoggingService, hasByteArrays bytes: UnsafePointer<UInt8>, numberOfItems: UInt16, forDataLoggingSession session: PBDataLoggingSessionMetadata) -> Bool {
        return true
    }
}