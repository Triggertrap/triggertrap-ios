//
//  WearablesManager.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 07/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

protocol WearableManagerDelegate {
    func watchDidTrigger()
}

class WearablesManager: NSObject {
    fileprivate var isRunning: Bool = false
    static let sharedInstance = WearablesManager()
    var delegate: WearableManagerDelegate?
    
    func startSession() {
        isRunning = true
        
        AppleWatchManager.sharedInstance.startSession()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WearablesManager.watchDidTrigger), name: NSNotification.Name(rawValue: constWatchDidTrigger), object: nil)
    }
    
    func endSession() {
        isRunning = false
        
        AppleWatchManager.sharedInstance.stopSession()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constWatchDidTrigger), object: nil)
    }
    
    func isWearablesModeRunning() -> Bool {
        return self.isRunning
    }
    
    @objc func watchDidTrigger() {
        onMain {
            self.delegate?.watchDidTrigger()
        }
    }
}
