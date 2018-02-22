//
//  WiFiViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class WiFiViewController: TTViewController {

    @IBOutlet var wifiSegmentedControl: UISegmentedControl!
    @IBOutlet var wifiInfoText: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    // True - master, false - slave
    
    private var masterIsSelected = true
    private let remoteClient = RemoteClient.sharedInstance
    private var server = ""
    private var hotspotCanBeEnabled = false
    
    // Type of broadcasting service
    
    private enum Type: Int {
        case Master = 0,
        Slave = 1
    }
    
    private var broadcastingType: Type = Type.Master
    private var masterName: String = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerNib(UINib(nibName: "WifiCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "WifiCell")
        
        remoteClient.delegate = self
        
        // Necessary to fix gap between collection view top item and navigation bar
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Add notification observer which calls wifiDidDisconnect when device goes into airplain mode/wifi is disabled
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WiFiViewController.wifiDidDisconnect), name: ConstWifiMasterIsSelected, object: nil)
        
        wifiSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.triggertrap_metric_light(20.0)]
            , forState: .Normal)
        wifiSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.triggertrap_metric_light(20.0)]
            , forState: .Selected)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) 

        masterIsSelected = NSUserDefaults.standardUserDefaults().boolForKey(ConstWifiMasterIsSelected) == false ? NSUserDefaults.standardUserDefaults().boolForKey(ConstWifiMasterIsSelected) : true
        
        masterIsSelected ? broadcastAs(Type.Master) : broadcastAs(Type.Slave)
        
        if (masterIsSelected) {
            wifiSegmentedControl.selectedSegmentIndex = 0;
        } else {
            wifiSegmentedControl.selectedSegmentIndex = 1;
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Invalidates cell layout while rotating and re-creates layout with new frame
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ConstWifiDisconnected, object: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func segmentedControllerPressed(segmentedController: UISegmentedControl) {
        
        // Check if Master or Slave is selected
        segmentedController.selectedSegmentIndex == 0 ? broadcastAs(Type.Master) : broadcastAs(Type.Slave)
    }
    
    @IBAction func shutterButtonTouchUpInside(sender: UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if !WifiDispatcher.sharedInstance.wifiIsAvailable && !hotspotCanBeEnabled {
                ShowAlertInViewController(self, title: NSLocalizedString("No Wifi Detected", comment: "No Wifi Detected"), message: NSLocalizedString("Connect to WiFi before continuing", comment: "Connect to WiFi before continuing"), cancelButton: NSLocalizedString("OK", comment: "OK")) 
            } else {
                
                switch broadcastingType {
                    
                case Type.Master:
                    
                    // Check if remote output server has delegate (running)
                    if WifiDispatcher.sharedInstance.remoteOutputServer?.delegate != nil {
                        
                        // Stop wifi master by setting its delegate to nil and stoping the service
                        WifiDispatcher.sharedInstance.remoteOutputServer?.delegate = nil
                        WifiDispatcher.sharedInstance.remoteOutputServer?.stopService()
                        
                        // Hide red view and stop shutter button animation
                        hideFeedbackView()
                        stopShutterButtonAnimation()
                        
                    } else {
                        // Start Wifi Master
                        prepareForSequence()
                        
                        startShutterButtonAnimation()
                        showFeedbackView(ConstStoryboardIdentifierInfoFeedbackView)
                        
                        feedbackViewController.infoLabel?.text = String(format: NSLocalizedString("Broadcasting as:\n\n%@\n\nWait for slave devices to connect to this device!", comment: "Broadcasting as:\n\n%@\n\nWait for slave devices to connect to this device!"), masterName)
                        
                        WifiDispatcher.sharedInstance.remoteOutputServer?.delegate = self
                        WifiDispatcher.sharedInstance.remoteOutputServer?.startService()
                    }
                    
                    break
                    
                case Type.Slave:
                    if sufficientVolumeToTrigger() {
                        print("Slave called with NO active view controller")
                        prepareForSequence()
                        startShutterButtonAnimation()
                        showFeedbackView(ConstStoryboardIdentifierInfoFeedbackView)
                        sequenceManager.activeViewController = self
                        
                        feedbackViewController.infoLabel?.text = String(format: NSLocalizedString("You are connected to:\n\n%@\n\nWait for the master device to trigger this device!", comment: "You are connected to:\n\n%@\n\nWait for the master device to trigger this device!"), server)
                        
                        remoteClient.connected = false;
                        
                        if remoteClient.asyncSocket != nil {
                            remoteClient.asyncSocket!.disconnect()
                        }
                    
                        // Update name here
                        remoteClient.currentServerName = server
                        remoteClient.connectToCurrentServer()
                    }
                    break
                }
            }
        } else {
            
            switch broadcastingType {
            case Type.Master:
                // Master never sets the active view controller therefore this should never be called
                print("Master called with active view controller")
                break
                
            case Type.Slave:
                print("Slave called with active view controller")
                if remoteClient.asyncSocket != nil {
                    remoteClient.asyncSocket!.disconnect()
                }
                
                break
            }
        }
    }
    
    // MARK: - Private
    
    private func broadcastAs(type: Type) {
        
        // Get last selected type
        broadcastingType = type
        
        switch type {
            
        case .Master:
            
            // Reset the possibility of the hotspot to be on
            hotspotCanBeEnabled = false
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: ConstWifiMasterIsSelected)
            
            wifiInfoText.text = NSLocalizedString("Tap the big red button to start broadcasting as a Wi-Fi Master, then go to any mode that supports Wi-Fi triggering and use it like normal. When your Master device triggers, your connected Wi-Fi slaves will trigger too! The number of connected Slave devices will appear here when active.", comment: "Tap the big red button to start broadcasting as a Wi-Fi Master, then go to any mode that supports Wi-Fi triggering and use it like normal. When your Master device triggers, your connected Wi-Fi slaves will trigger too! The number of connected Slave devices will appear here when active.")
            
            // Make Wifi info text visible if there were masters on the Wifi Slaves and the label got hidden
            wifiInfoText.hidden = false
            
            // Stop Slave
            collectionView.delegate = nil
            collectionView.dataSource = nil
            remoteClient.disconnectAndStop()
            
            // Enable shutter button when in WiFi mode
            shutterButtonEnabled(true)
            break
            
        case .Slave:
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: ConstWifiMasterIsSelected)
            
            wifiInfoText.text = NSLocalizedString("Tap on an available Wi-Fi master to select it, then press the big red button to start listening! Whenever the Wi-Fi Master device triggers, your Slave device will trigger too. Tap the red button again to stop listening to the Wi-Fi Master.", comment: "Tap on an available Wi-Fi master to select it, then press the big red button to start listening! Whenever the Wi-Fi Master device triggers, your Slave device will trigger too. Tap the red button again to stop listening to the Wi-Fi Master.")
            
            // Reset the server
            server = ""
            
            // Disable shutter button
            shutterButtonEnabled(false)
            
            // Disconnect the remoteClient in case it is still connected
            remoteClient.disconnectAndStop()
            
            // Start searching for servers
            remoteClient.startSearchingForServers()
            
            // Enable collection view delegate and data source
            collectionView.dataSource = self
            collectionView.delegate = self
            break
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // Handle user disconnecting Wifi or turning airplain mode on
    func wifiDidDisconnect() {
        
        switch broadcastingType {
            
        case Type.Master:
            
            // Check if remote output server has delegate (running)
            if WifiDispatcher.sharedInstance.remoteOutputServer.delegate != nil {
                
                // Stop wifi master by setting its delegate to nil and stoping the service
                WifiDispatcher.sharedInstance.remoteOutputServer.delegate = nil
                WifiDispatcher.sharedInstance.remoteOutputServer.stopService()
                
                // Hide red view and stop shutter button animation
                hideFeedbackView()
                stopShutterButtonAnimation()
            }
            break
            
        case Type.Slave:
            print("Slave called with active view controller")
            if remoteClient.asyncSocket != nil {
                remoteClient.asyncSocket!.disconnect()
            }
            break
        }
    }
    
    private func updateLabel() {
        if WifiDispatcher.sharedInstance.remoteOutputServer.connectedSockets() == nil || WifiDispatcher.sharedInstance.remoteOutputServer.connectedSockets().count == 0 {
            feedbackViewController?.infoLabel?.text = String(format: NSLocalizedString("Broadcasting as:\n\n%@\n\nNo slave devices connected.", comment: "Broadcasting as:\n\n%@\n\nNo slave devices connected."), masterName)
        } else {
            feedbackViewController?.infoLabel?.text = String(format: NSLocalizedString("Broadcasting as:\n\n%@\n\n%d devices connected.", comment: "Broadcasting as:\n\n%@\n\n%d devices connected."), masterName, WifiDispatcher.sharedInstance.remoteOutputServer.connectedSockets().count)
        }
    }
    
    func netServiceDidPublish(name: String!) {
        // Set broadcasting as device label here
        masterName = name
        feedbackViewController.infoLabel?.text = String(format: NSLocalizedString("Broadcasting as:\n\n%@\n\nWait for slave devices to connect to this device!", comment: "Broadcasting as:\n\n%@\n\nWait for slave devices to connect to this device!"), name)
    }
    
    override func didFinishSequence() {
        // Override default behaviour
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        wifiSegmentedControl.tintColor = UIColor.triggertrap_primaryColor()
        wifiInfoText.textColor = UIColor.triggertrap_foregroundColor()
    }
}

extension WiFiViewController: UICollectionViewDataSource {
    
    // MARK: - Collection View
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: WifiCell = collectionView.dequeueReusableCellWithReuseIdentifier("WifiCell", forIndexPath: indexPath) as! WifiCell
        
        // Get and assign server name from index to collection view cell text
        if let serverIndices = remoteClient.serverIndices, deviceName = serverIndices[indexPath.row] {
            cell.deviceName.text = deviceName
        }
        
        // If current server is connected
        if (server == cell.deviceName.text) {
            
            // Set the possibility of the hotspot to be on
            hotspotCanBeEnabled = true
            
            // Enable shutter button
            shutterButtonEnabled(true)
            
            // Show tick
            cell.deviceConnected = true
        } else {
            cell.deviceConnected = false
        }
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Check if remote client has any servers
        if let serverIndices = remoteClient.serverIndices where serverIndices.count != 0 {
            
            // Hide information text if servers available
            wifiInfoText.hidden = true
            
            // Return number of servers available
            return remoteClient.serverIndices!.count
        } else {
            
            // Stop outputManager if running
            sequenceManager.cancel()
            
            // Show wifi info text
            wifiInfoText.hidden = false
            
            return 0
        }
    }
}

extension WiFiViewController: UICollectionViewDelegate {
    
    // MARK: - Collection View Delegate
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(self.collectionView.frame.size.width, 44)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let serverSelected = remoteClient.serverIndices![indexPath.row]!
        
        // Reset the possibility of the hotspot to be on
        hotspotCanBeEnabled = false
        
        // Deselect the server if already selected
        if server == serverSelected {
            server = ""
            // Disable the shutter button
            shutterButtonEnabled(false)
        } else {
            server = serverSelected
        }
        
        // Reload the collection view
        collectionView.reloadData()
    }
}

extension WiFiViewController: RemoteClientDelegate {
    
    // MARK: - Remote Client Delegate (Slave)
    
    func remoteClientDidConnectToHost() {
        print("Remote Client Did Connect To Host")
        
        // Reset the possibility of the hotspot to be on
        hotspotCanBeEnabled = false
        collectionView.reloadData()
    }
    
    func remoteClientDidDisconnect(error: NSError?) {
        
        if let _ = error {
            ShowAlertInViewController(self, title: NSLocalizedString("Woops", comment: "Woops"), message: NSLocalizedString("Lost connection to Master", comment: "Lost connection to Master"), cancelButton: NSLocalizedString("OK", comment: "OK"))
        }
        
        // If output manager is running - stop it
        sequenceManager.cancel()
        
        print("Remote Client Did Disconnect")
        // Reset the possibility of the hotspot to be on
        hotspotCanBeEnabled = false
        collectionView.reloadData()
    }
    
    func remoteClientDidRefreshServers() {
        print("Remote Client Did Refresh Servers")
        
        // Check if hosts are 0
        if let serverIndices = remoteClient.serverIndices where serverIndices.count == 0 {
            
            // Disable and alpha shutter button
            shutterButtonEnabled(false)
        }
        
        // Reset the possibility of the hotspot to be on
        hotspotCanBeEnabled = false
        collectionView.reloadData()
    }
}

extension WiFiViewController: RemoteOutputServerDelegate {
    
    // MARK: - Remote Output Server Delegate (Master)
    
    func socketDidReadData() {
        print("Socket Did Read Data")
        updateLabel()
    }
    
    func socketDidAcceptNewSocket() {
        updateLabel()
        print("Socket Did Accept New Socket")
    }
    
    func socketDidDisconnect() {
        updateLabel()
        print("Socket Did Disconnect")
    }
}