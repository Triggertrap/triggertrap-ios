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
    fileprivate var session: WCSession?
    
    func startSession() {
        
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
    }
    
    func stopSession() {
        self.session?.delegate = nil
        self.session = nil
    }
    
    func updateWatchKitApplicationWithContext(_ title: String, running: Bool, completeExposures: Int, totalExposures: Int, timeRemaining: String) {
        
        if let session = session, session.isWatchAppInstalled {
            do {
                try session.updateApplicationContext(["Title" : title, "Running" : running, "CompleteExposures" : completeExposures, "TotalExposures" : totalExposures, "TimeRemaining" : timeRemaining])
            } catch let error as NSError {
                errorHandler(error)
            }
        }
    }
    
    fileprivate func errorHandler (_ error: NSError) -> Void {
        
        if let errorMessage = returnWatchError(error.code) {
            print("Error: \(errorMessage)")
        }
    }
    
    fileprivate func returnWatchError (_ errorCode: Int) -> String? {
        
        var errorString: String?
        
        
        /*if let errorDescription = WCError(_nsError: NSError(domain: "test", code: errorCode, userInfo: nil)) {
            
            switch errorDescription {
            case .genericError:
                errorString = "GenericError"
            case .sessionNotSupported:
                errorString = "SessionNotSupported"
            case .sessionMissingDelegate:
                errorString = "SessionMissingDelegate"
            case .sessionNotActivated:
                errorString = "SessionNotActivated"
            case .deviceNotPaired:
                errorString = "DeviceNotPaired"
            case .watchAppNotInstalled:
                errorString = "WatchAppNotInstalled"
            case .notReachable:
                errorString = "NotReachable"
            case .invalidParameter:
                errorString = "InvalidParameter"
            case .payloadTooLarge:
                errorString = "PayloadTooLarge"
            case .payloadUnsupportedTypes:
                errorString = "PayloadUnsupportedTypes"
            case .messageReplyFailed:
                errorString = "MessageReplyFailed"
            case .messageReplyTimedOut:
                errorString = "MessageReplyTimedOut"
            case .fileAccessDenied:
                errorString = "FileAccessDenied"
            default:
                break
            }
        }*/
        return errorString
    }
}

@available(iOS 9.0, *)
extension AppleWatchManager: WCSessionDelegate {
    @available(iOS 9.3, *)
    func sessionDidDeactivate(_ session: WCSession) {
        
    }

    @available(iOS 9.3, *)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if (message["trigger"] as? Bool) == true {
            NotificationCenter.default.post(name: Notification.Name(rawValue: constWatchDidTrigger), object: nil)
        }
    }
}
