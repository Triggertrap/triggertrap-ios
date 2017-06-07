//
//  SubSettingsViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 18/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import Foundation

class SubSettingsViewController: UITableViewController {
    
    enum SettingsType : Int {
        case SensorDelay = 0,
        SensorResetDelay = 1,
        PulseLength = 2,
        SpeedUnit = 3,
        DistanceUnit = 4
    }
    
    // MARK: - Properties
    
    var settingsType = SettingsType.SensorDelay
    
    private var strings: [String] = []
    private var values: [Int] = []
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var path: String?
        
        switch settingsType {
            
        case .SensorDelay:
            path = NSBundle.mainBundle().pathForResource("sensorDelays", ofType: "plist")
            break
            
        case .SensorResetDelay:
            path = NSBundle.mainBundle().pathForResource("sensorResetDelays", ofType: "plist")
            break
            
        case .PulseLength:
            path = NSBundle.mainBundle().pathForResource("pulseLengths", ofType: "plist")
            title = NSLocalizedString("Pulse Length", comment: "Pulse Length")
            //            GenerateStringsFileFromPlist("pulseLengths", plistType: .Dictionary)
            break
            
        case .SpeedUnit:
            path = NSBundle.mainBundle().pathForResource("speedUnits", ofType: "plist")
            title = NSLocalizedString("Speed Unit", comment: "Speed Unit")
            //            GenerateStringsFileFromPlist("speedUnits", plistType: .Dictionary)
            break
            
        case .DistanceUnit:
            path = NSBundle.mainBundle().pathForResource("distanceUnits", ofType: "plist")
            title = NSLocalizedString("Distance Unit", comment: "Distance Unit")
            //            GenerateStringsFileFromPlist("distanceUnits", plistType: .Dictionary)
            break
        }
        
        let dict = NSDictionary(contentsOfFile: path!)
        
        strings = dict?.objectForKey("Strings") as! Array
        values = dict?.objectForKey("Values") as! Array
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = UIColor.triggertrap_fillColor()
        self.tableView.separatorColor = UIColor.triggertrap_foregroundColor()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0), NSForegroundColorAttributeName: UIColor.triggertrap_iconColor(1.0)]
    }
    
    // MARK: - UITableView Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewCell") as! BFPaperTableViewCell
        
        // Set the font to Metric
        cell.backgroundColor = UIColor.triggertrap_fillColor()
        
        cell.usesSmartColor = false
        cell.backgroundFadeColor = UIColor.triggertrap_fillColor()
        
        cell.textLabel?.font = UIFont.triggertrap_metric_light(20.0)
        cell.textLabel?.textColor = UIColor.triggertrap_accentColor(1.0)
        cell.textLabel?.text = strings[indexPath.row]
        
        // Clear all checkmarks when reloading the cells
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        var value: Int?
        
        switch settingsType {
            
        case .SensorDelay:
            value = SettingsManager.sharedInstance().sensorDelay.integerValue
            break
            
        case .SensorResetDelay:
            value = SettingsManager.sharedInstance().sensorResetDelay.integerValue
            break
            
        case .PulseLength:
            cell.textLabel?.text = NSLocalizedString(strings[indexPath.row], tableName: "pulseLengthsPlist", bundle: .mainBundle(), value: "150 ms - camera", comment: "Ignore when translating")
            value = SettingsManager.sharedInstance().pulseLength.integerValue
            break
            
        case .SpeedUnit:
            value = SettingsManager.sharedInstance().speedUnit.integerValue
            cell.textLabel?.text = NSLocalizedString(strings[indexPath.row], tableName: "speedUnitsPlist", bundle: .mainBundle(), value: "Kilometers per hour", comment: "Ignore when translating")
            break
            
        case .DistanceUnit:
            value = SettingsManager.sharedInstance().distanceUnit.integerValue
            cell.textLabel?.text = NSLocalizedString(strings[indexPath.row], tableName: "distanceUnitsPlist", bundle: .mainBundle(), value: "Meters / Kilometers", comment: "Ignore when translating")
            break
        }
        
        // Add red checkmark to the cell with value equal to value from settings
        if value == (values[indexPath.row] as Int) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.tintColor = UIColor.triggertrap_primaryColor(1.0)
        }
        
        return cell
    }
    
    // MARK: - UITableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch settingsType {
            
        case .SensorDelay:
            SettingsManager.sharedInstance().sensorDelay = values[indexPath.row] as NSNumber
            break
            
        case .SensorResetDelay:
            SettingsManager.sharedInstance().sensorResetDelay = values[indexPath.row] as NSNumber
            break
            
        case .PulseLength:
            SettingsManager.sharedInstance().pulseLength = values[indexPath.row] as NSNumber
            break
            
        case .SpeedUnit:
            SettingsManager.sharedInstance().speedUnit = values[indexPath.row] as NSNumber
            break
            
        case .DistanceUnit:
            SettingsManager.sharedInstance().distanceUnit = values[indexPath.row] as NSNumber
            break
        }
        
        tableView.reloadData()
    }
}