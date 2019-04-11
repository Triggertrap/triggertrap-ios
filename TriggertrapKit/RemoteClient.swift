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
    @objc optional func remoteClientDidConnectToHost()
    @objc optional func remoteClientDidDisconnect(_ error: NSError?)
    @objc optional func remoteClientDidRefreshServers()
}

open class RemoteClient: NSObject {
    public static let sharedInstance = RemoteClient()
    
    open var delegate: RemoteClientDelegate?
    
    open var netServiceBrowser: NetServiceBrowser?
    open var servers: [String: NetService]?
    open var asyncSocket: GCDAsyncSocket?
    open var serverIndices: [String?]?
    open var currentServerName: String!
    open var connected: Bool!
    
    fileprivate var disconnecting: Bool!
    
    fileprivate override init() {
        super.init()
        disconnecting = false
        connected = false
    }
    
    open func startSearchingForServers() {
        print("Searching ...")
        
        let defaults = UserDefaults.standard
        
        self.currentServerName = defaults.string(forKey: kLastConnectMasterServer)
        self.netServiceBrowser = NetServiceBrowser()
        self.netServiceBrowser?.delegate = self
        self.netServiceBrowser?.searchForServices(ofType: "_triggertrap._tcp.", inDomain: "")
    }
    
    open func disconnectAndStop() {
        if connected == true && !disconnecting {
            print("Disconnecting ...")
            
            disconnecting = false
            
            self.asyncSocket?.write("BYE\r\n".data(using: String.Encoding.utf8)!, withTimeout: 0, tag: 0)
            
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
    
    open func refreshServerList() {
        if let servers = servers, serverIndices == nil {
            serverIndices = [String?](repeating: nil, count: servers.count)
        } else {
            serverIndices?.removeAll()
        }
        
        if let servers = servers {
            for key in servers.keys {
                let server = servers[key]
                
                if let server = server {
                    if (server.addresses?.count != nil) {
                        if let serviceName = RemoteOutputServer.sharedInstance().serviceName, serviceName == key {
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
    
    fileprivate func connectToService(_ service: NetService) {
        print("Connecting ...")
        
        var done = false
        
        if asyncSocket == nil {
            asyncSocket = GCDAsyncSocket(delegate: self as? GCDAsyncSocketDelegate, delegateQueue: DispatchQueue.main)
            asyncSocket?.isIPv4PreferredOverIPv6 = false
        }
        
        if let addresses = service.addresses {
            for addr in addresses {
                
                do {
                    try asyncSocket?.connect(toAddress: addr)
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
            UserDefaults.standard.set(currentServerName, forKey: kLastConnectMasterServer)
            connected = true
        }
    }
    
    open func connectToCurrentServer() {
        if (currentServerName != nil) {
            
            if let servers = servers, let service = servers[currentServerName] {
                connectToService(service)
            }
        }
    }
    
    // MARK: - Sockets
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        let CRLF = "\r\n".data(using: String.Encoding.utf8)
        
        print("Socket did connect to host: \(host) port: \(port)")
        
        let data = "\(UIDevice.current.name)\r\n".data(using: String.Encoding.utf8)
        
        sock.write(data!, withTimeout: 0, tag: 0)
        
        self.connected = true
        
        self.asyncSocket?.readData(to: CRLF!, withTimeout: -1, tag: 0)
        
        DispatchQueue.main.async { () -> Void in
            self.delegate?.remoteClientDidConnectToHost?()
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadData data: Data, withTag tag: Double) {
        print("Read data with tag: \(tag)")
        sock.write("ACK\r\n".data(using: String.Encoding.utf8)!, withTimeout: 0, tag: 0)
        
        if parseData(data) == "BEEP" {
            SequenceManager.sharedInstance.play(Sequence(modules: [Pulse(time: Time(duration: SettingsManager.sharedInstance().pulseLength.doubleValue, unit: .milliseconds))]),repeatSequence: false)
        }
//        let pulseDuration = (parseData(data) as NSString).doubleValue
//        
//        if  pulseDuration != 0.0 {
//            SequenceManager.sharedInstance.play(Sequence(modules: [Pulse(time: Time(duration: pulseDuration, unit: .Milliseconds))]))
//        }
        
        let CRLF = "\r\n".data(using: String.Encoding.utf8)
        
        self.asyncSocket?.readData(to: CRLF!, withTimeout: -1, tag: 0)
    }
    
    func parseData(_ data: Data) -> String {
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError error: NSError?) {
       print("Socket: \(sock)")
        
        connected = false
        disconnecting = false
        
        DispatchQueue.main.async { () -> Void in
            self.delegate?.remoteClientDidDisconnect?(error)
        }
    } 
}

// MARK: - NSNetServiceBrowserDelegate

extension RemoteClient: NetServiceDelegate, NetServiceBrowserDelegate {
    
    public func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("Net service browser will search")
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Did no search: \(errorDict)")
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        
        service.delegate = self
        service.resolve(withTimeout: 5.0)
        
        if servers == nil {
            servers = [String: NetService]()
        }
        
        servers?[service.name] = service
        
        refreshServerList()
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("Did remove service: \(service.name)")
        
        self.servers?.removeValue(forKey: service.name)
        service.delegate = nil
        
        self.refreshServerList()
    } 
    
    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Did stop serch")
    }
    
    public func netServiceDidResolveAddress(_ service: NetService) {
        self.refreshServerList()
    } 
}
