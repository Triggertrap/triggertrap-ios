//
//  SettingsTableViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 18/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import Foundation

class SettingsTableViewController : UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var sensorDelayCell: BFPaperTableViewCell!
    @IBOutlet weak var sensorDelayTitle: UILabel!
    @IBOutlet weak var sensorDelay: UILabel!
    
    @IBOutlet weak var sensorResetDelayCell: BFPaperTableViewCell!
    @IBOutlet weak var sensorResetDelayTitle: UILabel!
    @IBOutlet weak var sensorResetDelay: UILabel!
    
    @IBOutlet weak var pulseLengthTitle: UILabel!
    @IBOutlet weak var pulseLengthCell: BFPaperTableViewCell!
    @IBOutlet weak var pulseLength: UILabel!
    
    @IBOutlet weak var speedUnitCell: BFPaperTableViewCell!
    @IBOutlet weak var speedUnitTitle: UILabel!
    @IBOutlet weak var speedUnit: UILabel!
    
    @IBOutlet weak var distanceCell: BFPaperTableViewCell!
    @IBOutlet weak var distanceTitle: UILabel!
    @IBOutlet weak var distanceUnit: UILabel!
    
    @IBOutlet weak var versionCell: BFPaperTableViewCell!
    @IBOutlet weak var versionTitle: UILabel!
    @IBOutlet weak var version: UILabel!
    
    @IBOutlet weak var imageCreditCell: BFPaperTableViewCell!
    @IBOutlet weak var imageCreditTitle: UILabel!
    @IBOutlet weak var imageCredit: UILabel!
    
    @IBOutlet weak var resetCell: BFPaperTableViewCell!
    @IBOutlet weak var resetLabel: UILabel!
    
    @IBOutlet weak var nightModeCell: UITableViewCell!
    @IBOutlet weak var nightTimeSwitch: UISwitch!
    @IBOutlet weak var nightTimeLabel: UILabel!
    
    // MARK: - Properties
    
    private let settingsManager = SettingsManager.sharedInstance()
    private var type = SubSettingsViewController.SettingsType.SensorDelay
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Hide previous screen title from the back button in case we use SettingsTableViewController as initial screen as opposed to OptionsTableViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        performThemeUpdate()
    }
    
    @IBAction func nightTimeSwitchValueChanged(nightTimeSwitch: UISwitch) {
        NSUserDefaults.standardUserDefaults().setInteger(nightTimeSwitch.on ? 1 : 0, forKey: ConstAppTheme)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Set application window background fill color
        (UIApplication.sharedApplication().delegate as! AppDelegate).window?.backgroundColor = UIColor.triggertrap_fillColor(1.0)
        
        // Post a notification that the app theme has been updated
        NSNotificationCenter.defaultCenter().postNotificationName(ConstThemeHasBeenUpdated, object: nil)
        
        performThemeUpdate()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "showSubSettings") {
            let vc = segue.destinationViewController as! SubSettingsViewController
            vc.settingsType = type
        } else if segue.identifier == "showDelay" {
            let vc = segue.destinationViewController as! SensorDelayViewController
            
            if type.rawValue == 0 {
                vc.settingsType = SensorDelayViewController.SettingsType.SensorDelay
            } else if type.rawValue == 1 {
                vc.settingsType = SensorDelayViewController.SettingsType.SensorResetDelay
            }
        }
    }
    
    // MARK: - Private
    
    private func performThemeUpdate() {
        
        self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0), NSForegroundColorAttributeName: UIColor.triggertrap_iconColor(1.0)]
        
        self.view.backgroundColor = UIColor.triggertrap_fillColor()
        
        switch AppTheme() {
        case .Normal:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            nightTimeSwitch.on = false
            break
            
        case .Night:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            nightTimeSwitch.on = true
            break
        }
        
        sensorDelay.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.SensorDelay)
        sensorResetDelay.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.SensorResetDelay)
        pulseLength.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.PulseLength)
        speedUnit.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.SpeedUnit)
        distanceUnit.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.DistanceUnit)
        
        let versionNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        
        version.text = "\(versionNumber) (\(buildNumber))"
        
        applyThemeToCell(sensorDelayCell, titleLabel: sensorDelayTitle, descriptionLabel: sensorDelay)
        applyThemeToCell(sensorResetDelayCell, titleLabel: sensorResetDelayTitle, descriptionLabel: sensorResetDelay)
        applyThemeToCell(pulseLengthCell, titleLabel: pulseLengthTitle, descriptionLabel: pulseLength)
        applyThemeToCell(speedUnitCell, titleLabel: speedUnitTitle, descriptionLabel: speedUnit)
        applyThemeToCell(distanceCell, titleLabel: distanceTitle, descriptionLabel: distanceUnit)
        applyThemeToCell(versionCell, titleLabel: versionTitle, descriptionLabel: version)
        applyThemeToCell(imageCreditCell, titleLabel: imageCreditTitle, descriptionLabel: imageCredit)
        
        nightModeCell.backgroundColor = UIColor.triggertrap_fillColor()
        nightTimeLabel.textColor = UIColor.triggertrap_accentColor()
        
        resetCell.backgroundColor = UIColor.triggertrap_fillColor()
        resetCell.usesSmartColor = false
        resetCell.backgroundFadeColor = UIColor.triggertrap_fillColor()
        resetLabel.textColor = UIColor.triggertrap_primaryColor()
        
        self.tableView.backgroundColor = UIColor.triggertrap_backgroundColor()
        self.tableView.separatorColor = UIColor.triggertrap_foregroundColor()
        
        self.tableView.reloadData()
        
        nightTimeSwitch.thumbTintColor = nightTimeSwitch.on ? UIColor.triggertrap_fillColor() : UIColor.triggertrap_foregroundColor()
        nightTimeSwitch.onTintColor = UIColor.triggertrap_primaryColor()
    }
    
    private func applyThemeToCell(cell: BFPaperTableViewCell, titleLabel: UILabel, descriptionLabel: UILabel) {
        
        // If this cell has an accessory view
        if cell.accessoryType == .DisclosureIndicator {
            cell.accessoryView = UIImageView(image: ImageWithColor(UIImage(named: "DisclosureIndicator")!, color: UIColor.triggertrap_foregroundColor()))
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 8, height: 13)
        }
        
        cell.backgroundColor = UIColor.triggertrap_fillColor()
        cell.usesSmartColor = false
        cell.backgroundFadeColor = UIColor.triggertrap_fillColor()
        
        titleLabel.textColor = UIColor.triggertrap_accentColor()
        descriptionLabel.textColor = UIColor.triggertrap_foregroundColor()
    }
    
    private func valueForSettingsWithType(type: SubSettingsViewController.SettingsType) -> String {
        
        var path: String?
        
        switch type {
            
        case SubSettingsViewController.SettingsType.SensorDelay:
            path = pathForResource("sensorDelays")
            break
            
        case SubSettingsViewController.SettingsType.SensorResetDelay:
            path = pathForResource("sensorResetDelays")
            break
            
        case SubSettingsViewController.SettingsType.PulseLength:
            path = pathForResource("pulseLengths")
            break
            
        case SubSettingsViewController.SettingsType.SpeedUnit:
            path = pathForResource("speedUnits")
            break
            
        case SubSettingsViewController.SettingsType.DistanceUnit:
            path = pathForResource("distanceUnits")
            break
        }
        
        let dict = NSDictionary(contentsOfFile: path!)
        let settingsStrings = dict?.objectForKey("Strings") as! [String]
        let settingsValues = dict?.objectForKey("Values") as! [Int]
        
        var settingsValue = ""
            
        switch type {
            
        case SubSettingsViewController.SettingsType.SensorDelay:
            settingsValue = timeFormatted(settingsManager.sensorDelay.unsignedLongLongValue)
            
        case SubSettingsViewController.SettingsType.SensorResetDelay:
            
            settingsValue = timeFormatted(settingsManager.sensorResetDelay.unsignedLongLongValue)
            
        case SubSettingsViewController.SettingsType.PulseLength:
            
            for i in 0..<settingsValues.count {
                if settingsValues[i] as Int == settingsManager.pulseLength.integerValue {
                    settingsValue = NSLocalizedString(settingsStrings[i] as String, tableName: "pulseLengthsPlist", bundle: NSBundle.mainBundle(), value: "", comment: "")
                    break
                }
            }
            break
            
        case SubSettingsViewController.SettingsType.SpeedUnit:
            
            for i in 0..<settingsValues.count {
                if settingsValues[i] as Int == settingsManager.speedUnit.integerValue { 
                    settingsValue = NSLocalizedString(settingsStrings[i] as String, tableName: "speedUnitsPlist", bundle: NSBundle.mainBundle(), value: "", comment: "")
                    break
                }
            }
            break
            
        case SubSettingsViewController.SettingsType.DistanceUnit:
            
            for i in 0..<settingsValues.count {
                
                if settingsValues[i] as Int == settingsManager.distanceUnit.integerValue { 
                    settingsValue = NSLocalizedString(settingsStrings[i] as String, tableName: "distanceUnitsPlist", bundle: NSBundle.mainBundle(), value: "", comment: "")
                    break
                }
            }
            break
        }
        
        return settingsValue
    }
    
    private func timeFormatted(totalSeconds: CUnsignedLongLong) -> String {
        
        let msperhour: CUnsignedLongLong = 3600000
        let mspermin: CUnsignedLongLong = 60000
        
        let hrs: CUnsignedLongLong = totalSeconds / msperhour
        let mins: CUnsignedLongLong = totalSeconds % msperhour / mspermin
        let secs: CUnsignedLongLong = ((totalSeconds % msperhour) % mspermin) / 1000
        let frac: CUnsignedLongLong = totalSeconds % 1000
        
        if hrs == 0 {
            
            if mins == 0 {
                
                if secs == 0 {
                    return ("\(frac)ms")
                } else {
                    return ("\(secs)s \(frac)ms")
                }
            } else {
                return ("\(mins)m \(secs)s \(frac)ms")
            }
        } else {
            return ("\(hrs)h \(mins)m \(secs)s \(frac)ms")
        }
    }
    
    // MARK: - TableView Data Source
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            
            // There is a bug with Apple's API for version 8.0.x where changing the font of the header view causes a crash
            if (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.1 || (UIDevice.currentDevice().systemVersion as NSString).doubleValue < 8.0 {
                // Set the font to Metric
                headerView.textLabel?.font = UIFont.triggertrap_metric_regular(18.0)
                headerView.textLabel?.textColor = UIColor.triggertrap_accentColor()
                headerView.contentView.backgroundColor = UIColor.triggertrap_backgroundColor()
            }
        }
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let identifier = cell?.reuseIdentifier
        
        if identifier != nil {
            // The identifiers are set in the storyboard for each cell
            switch (identifier!) {
            case "SensorDelayCell":
                type = SubSettingsViewController.SettingsType.SensorDelay
                performSegueWithIdentifier("showDelay", sender: self)
                break
                
            case "SensorResetDelayCell":
                type = SubSettingsViewController.SettingsType.SensorResetDelay
                performSegueWithIdentifier("showDelay", sender: self)
                break
                
            case "PulseLengthCell":
                type = SubSettingsViewController.SettingsType.PulseLength
                performSegueWithIdentifier("showSubSettings", sender: self)
                break
                
            case "SpeedUnitCell":
                type = SubSettingsViewController.SettingsType.SpeedUnit
                performSegueWithIdentifier("showSubSettings", sender: self)
                break
                
            case "DistanceUnitCell":
                type = SubSettingsViewController.SettingsType.DistanceUnit
                performSegueWithIdentifier("showSubSettings", sender: self)
                break;
                
            case "ResetCell":
                settingsManager.resetSettings()
                nightTimeSwitch.on = false
                nightTimeSwitchValueChanged(nightTimeSwitch)
                break;
                
            default:
                break
            }
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}