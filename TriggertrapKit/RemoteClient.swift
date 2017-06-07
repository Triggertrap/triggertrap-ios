//
//  RemoteClient.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 30/07/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol RemoteClientDelegate {
    optional func remoteClientDidConnectToHost()
    optional func remoteClientDidDisconnect(error: NSError?)
    optional func remoteClientDidRefreshServers()
}

public class RemoteClient: NSObject {
    public static let sharedInstance = RemoteClient()
    
    public var delegate: RemoteClientDelegate?
    
    public var netServiceBrowser: NSNetServiceBrowser?
    public var servers: [String: NSNetService]?
    public var asyncSocket: GCDAsyncSocket?
    public var serverIndices: [String?]?
    public var currentServerName: String!
    public var connected: Bool!
    
    private var disconnecting: Bool!
    
    private override init() {
        super.init()
        disconnecting = false
        connected = false
    }
    
    public func startSearchingForServers() {
        print("Searching ...")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.currentServerName = defaults.stringForKey(kLastConnectMasterServer)
        self.netServiceBrowser = NSNetServiceBrowser()
        self.netServiceBrowser?.delegate = self
        self.netServiceBrowser?.searchForServicesOfType("_triggertrap._tcp.", inDomain: "")
    }
    
    public func disconnectAndStop() {
        if connected == true && !disconnecting {
            print("Disconnecting ...")
            
            disconnecting = false
            
            self.asyncSocket?.writeData("BYE\r\n".dataUsingEncoding(NSUTF8StringEncoding), withTimeout: 0, tag: 0)
            
            self.asyncSocket?.disconnectAfterWriting()
        }
        
        self.netServiceBrowser?.delegate = nil
        self.netServiceBrowser?.stop()
        self.netServiceBrowser = nil
        
        if let servers = servers {
            
            for key in servers.keys {
                servers[key]?.delegate = nil
            }
        }
        
        self.servers?.removeAll()
    }
    
    public func refreshServerList() {
        if let servers = servers where serverIndices == nil {
            serverIndices = [String?](count: servers.count, repeatedValue: nil)
        } else {
            serverIndices?.removeAll()
        }
        
        if let servers = servers {
            for key in servers.keys {
                let server = servers[key]
                
                if let server = server {
                    if (server.addresses?.count != nil) {
                        if let serviceName = RemoteOutputServer.sharedInstance().serviceName where serviceName == key {
                            print("Not adding ourself")
                            continue
                        }
                        serverIndices?.append(key)
                    }
                }
            }
        }
        
        onMain {
            self.delegate?.remoteClientDidRefreshServers?()
        }
    }
    
    private func connectToService(service: NSNetService) {
        print("Connecting ...")
        
        var done = false
        
        if asyncSocket == nil {
            asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            asyncSocket?.IPv4PreferredOverIPv6 = false
        }
        
        if let addresses = service.addresses {
            for addr in addresses {
                
                do {
                    try asyncSocket?.connectToAddress(addr)
                    done = true
                    break
                } catch {let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                } 
            }
        }
        
        if !done {
            connected = false
        } else {
            currentServerName = service.name
            NSUserDefaults.standardUserDefaults().setObject(currentServerName, forKey: kLastConnectMasterServer)
            connected = true
        }
    }
    
    public func connectToCurrentServer() {
        if (currentServerName != nil) {
            
            if let servers = servers, service = servers[currentServerName] {
                connectToService(service)
            }
        }
    }
    
    // MARK: - Sockets
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        let CRLF = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        
        print("Socket did connect to host: \(host) port: \(port)")
        
        let data = "\(UIDevice.currentDevice().name)\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        
        sock.writeData(data, withTimeout: 0, tag: 0)
        
        self.connected = true
        
        self.asyncSocket?.readDataToData(CRLF, withTimeout: -1, tag: 0)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.delegate?.remoteClientDidConnectToHost?()
        }
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Double) {
        print("Read data with tag: \(tag)")
        sock.writeData("ACK\r\n".dataUsingEncoding(NSUTF8StringEncoding), withTimeout: 0, tag: 0)
        
        if parseData(data) == "BEEP" {
            SequenceManager.sharedInstance.play(Sequence(modules: [Pulse(time: Time(duration: SettingsManager.sharedInstance().pulseLength.doubleValue, unit: .Milliseconds))]),repeatSequence: false)
        }
//        let pulseDuration = (parseData(data) as NSString).doubleValue
//        
//        if  pulseDuration != 0.0 {
//            SequenceManager.sharedInstance.play(Sequence(modules: [Pulse(time: Time(duration: pulseDuration, unit: .Milliseconds))]))
//        }
        
        let CRLF = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        
        self.asyncSocket?.readDataToData(CRLF, withTimeout: -1, tag: 0)
    }
    
    func parseData(data: NSData) -> String {
        return NSString(data: data, encoding: NSUTF8StringEncoding)?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError error: NSError?) {
       print("Socket: \(sock)")
        
        connected = false
        disconnecting = false
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.delegate?.remoteClientDidDisconnect?(error)
        }
    } 
}

// MARK: - NSNetServiceBrowserDelegate

extension RemoteClient: NSNetServiceDelegate, NSNetServiceBrowserDelegate {
    
    public func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        print("Net service browser will search")
    }
    
    public func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Did no search: \(errorDict)")
    }
    
    public func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        
        service.delegate = self
        service.resolveWithTimeout(5.0)
        
        if servers == nil {
            servers = [String: NSNetService]()
        }
        
        servers?[service.name] = service
        
        refreshServerList()
    }
    
    public func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        print("Did remove service: \(service.name)")
        
        self.servers?.removeValueForKey(service.name)
        service.delegate = nil
        
        self.refreshServerList()
    } 
    
    public func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        print("Did stop serch")
    }
    
    public func netServiceDidResolveAddress(service: NSNetService) {
        self.refreshServerList()
    } 
}