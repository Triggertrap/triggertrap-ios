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
        case sensorDelay = 0,
        sensorResetDelay = 1,
        pulseLength = 2,
        speedUnit = 3,
        distanceUnit = 4
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return AppTheme() == .normal ? .lightContent : .default
    }
    
    // MARK: - Properties
    
    var settingsType = SettingsType.sensorDelay
    
    fileprivate var strings: [String] = []
    fileprivate var values: [Int] = []
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var path: String?
        
        switch settingsType {
            
        case .sensorDelay:
            path = Bundle.main.path(forResource: "sensorDelays", ofType: "plist")
            break
            
        case .sensorResetDelay:
            path = Bundle.main.path(forResource: "sensorResetDelays", ofType: "plist")
            break
            
        case .pulseLength:
            path = Bundle.main.path(forResource: "pulseLengths", ofType: "plist")
            title = NSLocalizedString("Pulse Length", comment: "Pulse Length")
            //            GenerateStringsFileFromPlist("pulseLengths", plistType: .Dictionary)
            break
            
        case .speedUnit:
            path = Bundle.main.path(forResource: "speedUnits", ofType: "plist")
            title = NSLocalizedString("Speed Unit", comment: "Speed Unit")
            //            GenerateStringsFileFromPlist("speedUnits", plistType: .Dictionary)
            break
            
        case .distanceUnit:
            path = Bundle.main.path(forResource: "distanceUnits", ofType: "plist")
            title = NSLocalizedString("Distance Unit", comment: "Distance Unit")
            //            GenerateStringsFileFromPlist("distanceUnits", plistType: .Dictionary)
            break
        }
        
        let dict = NSDictionary(contentsOfFile: path!)
        
        strings = dict?.object(forKey: "Strings") as! Array
        values = dict?.object(forKey: "Values") as! Array
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = UIColor.triggertrap_fillColor()
        self.tableView.separatorColor = UIColor.triggertrap_foregroundColor()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.triggertrap_metric_regular(23.0), NSAttributedStringKey.foregroundColor: UIColor.triggertrap_iconColor(1.0)]
    }
    
    // MARK: - UITableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! BFPaperTableViewCell
        
        // Set the font to Metric
        cell.backgroundColor = UIColor.triggertrap_fillColor()
        
        cell.usesSmartColor = false
        cell.backgroundFadeColor = UIColor.triggertrap_fillColor()
        
        cell.textLabel?.font = UIFont.triggertrap_metric_light(20.0)
        cell.textLabel?.textColor = UIColor.triggertrap_accentColor(1.0)
        cell.textLabel?.text = strings[indexPath.row]
        
        // Clear all checkmarks when reloading the cells
        if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        var value: Int?
        
        switch settingsType {
            
        case .sensorDelay:
            value = SettingsManager.sharedInstance().sensorDelay.intValue
            break
            
        case .sensorResetDelay:
            value = SettingsManager.sharedInstance().sensorResetDelay.intValue
            break
            
        case .pulseLength:
            cell.textLabel?.text = NSLocalizedString(strings[indexPath.row], tableName: "pulseLengthsPlist", bundle: .main, value: "150 ms - camera", comment: "Ignore when translating")
            value = SettingsManager.sharedInstance().pulseLength.intValue
            break
            
        case .speedUnit:
            value = SettingsManager.sharedInstance().speedUnit.intValue
            cell.textLabel?.text = NSLocalizedString(strings[indexPath.row], tableName: "speedUnitsPlist", bundle: .main, value: "Kilometers per hour", comment: "Ignore when translating")
            break
            
        case .distanceUnit:
            value = SettingsManager.sharedInstance().distanceUnit.intValue
            cell.textLabel?.text = NSLocalizedString(strings[indexPath.row], tableName: "distanceUnitsPlist", bundle: .main, value: "Meters / Kilometers", comment: "Ignore when translating")
            break
        }
        
        // Add red checkmark to the cell with value equal to value from settings
        if value == (values[indexPath.row] as Int) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.tintColor = UIColor.triggertrap_primaryColor(1.0)
        }
        
        return cell
    }
    
    // MARK: - UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch settingsType {
            
        case .sensorDelay:
            SettingsManager.sharedInstance().sensorDelay = values[indexPath.row] as NSNumber
            break
            
        case .sensorResetDelay:
            SettingsManager.sharedInstance().sensorResetDelay = values[indexPath.row] as NSNumber
            break
            
        case .pulseLength:
            SettingsManager.sharedInstance().pulseLength = values[indexPath.row] as NSNumber
            break
            
        case .speedUnit:
            SettingsManager.sharedInstance().speedUnit = values[indexPath.row] as NSNumber
            break
            
        case .distanceUnit:
            SettingsManager.sharedInstance().distanceUnit = values[indexPath.row] as NSNumber
            break
        }
        
        tableView.reloadData()
    }
}
