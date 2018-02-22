//
//  WifiDispatcher.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
// 

open class WifiDispatcher: NSObject, Dispatcher {
    
    fileprivate var dispatchable: Dispatchable!
    fileprivate var reachability: Reachability!
    fileprivate var name: String!
    
    var remoteOutputServer: RemoteOutputServer!
    var wifiIsAvailable = false
    
    open static let sharedInstance = WifiDispatcher()
    
    fileprivate override init() {
        super.init()
        
        self.name = "Wifi"
        
        NotificationCenter.default.addObserver(self, selector: #selector(WifiDispatcher.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WifiDispatcher.remoteOutputServerStatusChanged), name: NSNotification.Name.remoteOutputServerStatusChanged, object: nil)
        
        self.reachability = Reachability.forLocalWiFi()
        self.remoteOutputServer = RemoteOutputServer.sharedInstance()
        
        self.reachability.startNotifier()
        self.refreshWifiState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.reachabilityChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.remoteOutputServerStatusChanged, object: nil)
    }
    
    // MARK: - Public
    
    open func dispatch(_ dispatchable: Dispatchable) {
        self.dispatchable = dispatchable
        
        if dispatchable is Pulse {
            self.remoteOutputServer.triggerNow()
        }
    }
    
    @objc open func reachabilityChanged() {
        self.refreshWifiState()
    }
    
    @objc open func remoteOutputServerStatusChanged() {
        
    }
    
    // MARK: - Private
    
    fileprivate func refreshWifiState() {
        if self.reachability.isReachableViaWiFi() {
            print("Wifi is reachable")
            self.wifiConnected(true)
        } else {
            print("Wifi is unreachable")
            self.wifiConnected(false)
        }
    }
    
    fileprivate func wifiConnected(_ connected: Bool) {
        wifiIsAvailable = connected
        
        if self.remoteOutputServer.running && !connected {
            print("Lost wifi connection")
            self.remoteOutputServer.stopService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "WifiDisconnected"), object: nil)
        }
        
        if connected {
            print("Starting service")
            self.remoteOutputServer.startService()
        }
    }
}
