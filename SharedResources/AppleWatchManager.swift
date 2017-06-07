//
//  AppleWatchManager.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 07/08/2015.
//  Copyright © 2015 Triggertrap Ltd. All rights reserved.
//

import WatchConnectivity

@available(iOS 9.0, *)
class AppleWatchManager: NSObject {
    static let sharedInstance = AppleWatchManager()
    private var session: WCSession?
    
    func startSession() {
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.delegate = self
            session?.activateSession()
        }
    }
    
    func stopSession() {
        self.session?.delegate = nil
        self.session = nil
    }
    
    func updateWatchKitApplicationWithContext(title: String, running: Bool, completeExposures: Int, totalExposures: Int, timeRemaining: String) {
        
        if let session = session where session.watchAppInstalled {
            do {
                try session.updateApplicationContext(["Title" : title, "Running" : running, "CompleteExposures" : completeExposures, "TotalExposures" : totalExposures, "TimeRemaining" : timeRemaining])
            } catch let error as NSError {
                errorHandler(error)
            }
        }
    }
    
    private func errorHandler (error: NSError) -> Void {
        
        if let errorMessage = returnWatchError(error.code) {
            print("Error: \(errorMessage)")
        }
    }
    
    private func returnWatchError (errorCode: Int) -> String? {
        
        var errorString: String?
        
        if let errorDescription = WCErrorCode(rawValue: errorCode) {
            
            switch errorDescription {
            case .GenericError:
                errorString = "GenericError"
            case .SessionNotSupported:
                errorString = "SessionNotSupported"
            case .SessionMissingDelegate:
                errorString = "SessionMissingDelegate"
            case .SessionNotActivated:
                errorString = "SessionNotActivated"
            case .DeviceNotPaired:
                errorString = "DeviceNotPaired"
            case .WatchAppNotInstalled:
                errorString = "WatchAppNotInstalled"
            case .NotReachable:
                errorString = "NotReachable"
            case .InvalidParameter:
                errorString = "InvalidParameter"
            case .PayloadTooLarge:
                errorString = "PayloadTooLarge"
            case .PayloadUnsupportedTypes:
                errorString = "PayloadUnsupportedTypes"
            case .MessageReplyFailed:
                errorString = "MessageReplyFailed"
            case .MessageReplyTimedOut:
                errorString = "MessageReplyTimedOut"
            case .FileAccessDenied:
                errorString = "FileAccessDenied"
            default:
                break
            }
        }
        
        return errorString
    }
}

@available(iOS 9.0, *)
extension AppleWatchManager: WCSessionDelegate {
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if (message["trigger"] as? Bool) == true {
            NSNotificationCenter.defaultCenter().postNotificationName(constWatchDidTrigger, object: nil)
        }
    }
}