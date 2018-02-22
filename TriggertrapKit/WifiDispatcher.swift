//
//  WifiDispatcher.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
// 

public class WifiDispatcher: NSObject, Dispatcher {
    
    private var dispatchable: Dispatchable!
    private var reachability: Reachability!
    private var name: String!
    
    var remoteOutputServer: RemoteOutputServer!
    var wifiIsAvailable = false
    
    public static let sharedInstance = WifiDispatcher()
    
    private override init() {
        super.init()
        
        self.name = "Wifi"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WifiDispatcher.reachabilityChanged), name: kReachabilityChangedNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WifiDispatcher.remoteOutputServerStatusChanged), name: kRemoteOutputServerStatusChangedNotification, object: nil)
        
        self.reachability = Reachability.reachabilityForLocalWiFi()
        self.remoteOutputServer = RemoteOutputServer.sharedInstance()
        
        self.reachability.startNotifier()
        self.refreshWifiState()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kReachabilityChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:kRemoteOutputServerStatusChangedNotification, object: nil)
    }
    
    // MARK: - Public
    
    public func dispatch(dispatchable: Dispatchable) {
        self.dispatchable = dispatchable
        
        if dispatchable is Pulse {
            self.remoteOutputServer.triggerNow()
        }
    }
    
    public func reachabilityChanged() {
        self.refreshWifiState()
    }
    
    public func remoteOutputServerStatusChanged() {
        
    }
    
    // MARK: - Private
    
    private func refreshWifiState() {
        if self.reachability.isReachableViaWiFi() {
            print("Wifi is reachable")
            self.wifiConnected(true)
        } else {
            print("Wifi is unreachable")
            self.wifiConnected(false)
        }
    }
    
    private func wifiConnected(connected: Bool) {
        wifiIsAvailable = connected
        
        if self.remoteOutputServer.running && !connected {
            print("Lost wifi connection")
            self.remoteOutputServer.stopService()
            NSNotificationCenter.defaultCenter().postNotificationName("WifiDisconnected", object: nil)
        }
        
        if connected {
            print("Starting service")
            self.remoteOutputServer.startService()
        }
    }
}