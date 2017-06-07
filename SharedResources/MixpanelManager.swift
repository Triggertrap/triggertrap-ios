//
//  MixpanelManager.swift
//  Timelapse Pro
//
//  Created by Valentin Kalchev on 14/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class MixpanelManager: NSObject { 
    static let sharedInstance = MixpanelManager()
    
    var enteringBackground: Bool!
    var mixpanel: Mixpanel!
    var startTime: NSDate!
    var photoTaken = false
    
    var timelapseCreated = false
    
    // MARK: Public
    
    func startSession() {
        enteringBackground = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: nil)
        
        timelapseCreated = false
        photoTaken = false
        
    #if DEBUG
        if NSBundle.mainBundle().objectForInfoDictionaryKey(constMixpanelDevelopmentToken) != nil {
            Mixpanel.sharedInstanceWithToken(NSBundle.mainBundle().objectForInfoDictionaryKey(constMixpanelDevelopmentToken) as! String)
//            print(NSBundle.mainBundle().objectForInfoDictionaryKey(constMixpanelDevelopmentToken) as! String)
            print("Mixpanel session started: Development")
        
            mixpanel = Mixpanel.sharedInstance()
            mixpanel.flushInterval = 10
        }
    #else
        if NSBundle.mainBundle().objectForInfoDictionaryKey(constMixpanelProductionToken) != nil {
            Mixpanel.sharedInstanceWithToken(NSBundle.mainBundle().objectForInfoDictionaryKey(constMixpanelProductionToken) as! String)
//            print(NSBundle.mainBundle().objectForInfoDictionaryKey(constMixpanelProductionToken) as! String)
            print("Mixpanel session started: Production")

            mixpanel = Mixpanel.sharedInstance()
        }
    #endif
        
        startTime = NSDate()
    }
    
    func endSession() {
        let seconds = NSDate().timeIntervalSinceDate(startTime)
        let nearestSeconds = NSNumber(double: round(seconds))
        let language = NSLocale.preferredLanguages().first!
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            self.mixpanel.track(constAnalyticsEventSessionCompleted, properties: [constAnalyticsPropertySessionDuration: nearestSeconds, constAnalyticsPropertyLanguage: language, constPhotoTaken: self.photoTaken])
        })
        
        startTime = nil
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
        
        print("Mixpanel session ended")
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        enteringBackground = false
    }
    
    func applicationWillResignActive() {
        enteringBackground = true
    }
    
    func trackEvent(eventName: String) {
        
        if !enteringBackground {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.mixpanel.track(eventName)
            })
            
            print("Tracked event: \(eventName)")
        }
    }
    
    func trackEvent(eventName: String, withProperties properties: NSDictionary) {
        if !self.enteringBackground {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.mixpanel.track(eventName, properties:properties as [NSObject : AnyObject])
            })
            
            print("Tracked event: \(eventName)")
        }
    }
}
