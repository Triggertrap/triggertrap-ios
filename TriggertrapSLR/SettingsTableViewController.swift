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
    
    @IBOutlet weak var resetCell: BFPaperTableViewCell!
    @IBOutlet weak var resetLabel: UILabel!
    
    @IBOutlet weak var nightModeCell: UITableViewCell!
    @IBOutlet weak var nightTimeSwitch: UISwitch!
    @IBOutlet var nightTimeInfo: UIButton!
    @IBOutlet weak var nightTimeLabel: UILabel!
    
    // MARK: - Properties
    
    fileprivate let settingsManager = SettingsManager.sharedInstance()
    fileprivate var type = SubSettingsViewController.SettingsType.sensorDelay
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide previous screen title from the back button in case we use SettingsTableViewController as initial screen as opposed to OptionsTableViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        if #available(iOS 13.0, *) {
            self.nightTimeSwitch.isHidden = true
        } else {
            self.nightTimeInfo.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performThemeUpdate()
    }
    
    @IBAction func nightTimeInfoTapped(_ sender: Any) {
        let alert = UIAlertController(title: "This option has moved", message: "iOS 13 now has dark mode built in. Either visit Settings or Control Center to enable or disable it.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func nightTimeSwitchValueChanged(_ nightTimeSwitch: UISwitch) {
        UserDefaults.standard.set(nightTimeSwitch.isOn ? 1 : 0, forKey: ConstAppTheme)
        UserDefaults.standard.synchronize()
        
        // Set application window background fill color
        (UIApplication.shared.delegate as! AppDelegate).window?.backgroundColor = UIColor.triggertrap_fillColor(1.0)
        
        // Post a notification that the app theme has been updated
        NotificationCenter.default.post(name: Notification.Name(rawValue: ConstThemeHasBeenUpdated), object: nil)
        
        performThemeUpdate()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *){
            performThemeUpdate()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "showSubSettings") {
            let vc = segue.destination as! SubSettingsViewController
            vc.settingsType = type
        } else if segue.identifier == "showDelay" {
            let vc = segue.destination as! SensorDelayViewController
            
            if type.rawValue == 0 {
                vc.settingsType = SensorDelayViewController.SettingsType.sensorDelay
            } else if type.rawValue == 1 {
                vc.settingsType = SensorDelayViewController.SettingsType.sensorResetDelay
            }
        }
    }
    
    // MARK: - Private
    
    fileprivate func performThemeUpdate() {
        
        self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.triggertrap_metric_regular(23.0), NSAttributedString.Key.foregroundColor: UIColor.triggertrap_iconColor(1.0)]
        
        self.view.backgroundColor = UIColor.triggertrap_fillColor()
        
        switch AppTheme() {
        case .normal:
            nightTimeSwitch.isOn = false
            break
            
        case .night:
            nightTimeSwitch.isOn = true
            break
        }
        
        sensorDelay.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.sensorDelay)
        sensorResetDelay.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.sensorResetDelay)
        pulseLength.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.pulseLength)
        speedUnit.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.speedUnit)
        distanceUnit.text = valueForSettingsWithType(SubSettingsViewController.SettingsType.distanceUnit)
        
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        
        version.text = "\(versionNumber) (\(buildNumber))"
        
        applyThemeToCell(sensorDelayCell, titleLabel: sensorDelayTitle, descriptionLabel: sensorDelay)
        applyThemeToCell(sensorResetDelayCell, titleLabel: sensorResetDelayTitle, descriptionLabel: sensorResetDelay)
        applyThemeToCell(pulseLengthCell, titleLabel: pulseLengthTitle, descriptionLabel: pulseLength)
        applyThemeToCell(speedUnitCell, titleLabel: speedUnitTitle, descriptionLabel: speedUnit)
        applyThemeToCell(distanceCell, titleLabel: distanceTitle, descriptionLabel: distanceUnit)
        applyThemeToCell(versionCell, titleLabel: versionTitle, descriptionLabel: version)
        
        nightModeCell.backgroundColor = UIColor.triggertrap_fillColor()
        nightTimeLabel.textColor = UIColor.triggertrap_accentColor()
        
        resetCell.backgroundColor = UIColor.triggertrap_fillColor()
        resetCell.usesSmartColor = false
        resetCell.backgroundFadeColor = UIColor.triggertrap_fillColor()
        resetLabel.textColor = UIColor.triggertrap_primaryColor()
        
        self.tableView.backgroundColor = UIColor.triggertrap_backgroundColor()
        self.tableView.separatorColor = UIColor.triggertrap_foregroundColor()
        
        
        let numSections = self.tableView.numberOfSections
        for i in 0..<numSections{
            let header = self.tableView.headerView(forSection: i)
            guard header != nil else{
                continue
            }
            header?.backgroundView?.backgroundColor = UIColor.triggertrap_tableHeaderBackgroundColor()
        }
        
        self.tableView.reloadData()
        
        nightTimeSwitch.thumbTintColor = nightTimeSwitch.isOn ? UIColor.triggertrap_fillColor() : UIColor.triggertrap_foregroundColor()
        nightTimeSwitch.onTintColor = UIColor.triggertrap_primaryColor()
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    fileprivate func applyThemeToCell(_ cell: BFPaperTableViewCell, titleLabel: UILabel, descriptionLabel: UILabel) {
        
        // If this cell has an accessory view
        if cell.accessoryType == .disclosureIndicator {
            cell.accessoryView = UIImageView(image: ImageWithColor(UIImage(named: "DisclosureIndicator")!, color: UIColor.triggertrap_foregroundColor()))
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 8, height: 13)
        }
        
        cell.backgroundColor = UIColor.triggertrap_fillColor()
        cell.usesSmartColor = false
        cell.backgroundFadeColor = UIColor.triggertrap_fillColor()
        
        titleLabel.textColor = UIColor.triggertrap_accentColor()
        descriptionLabel.textColor = UIColor.triggertrap_foregroundColor()
    }
    
    fileprivate func valueForSettingsWithType(_ type: SubSettingsViewController.SettingsType) -> String {
        
        var path: String?
        
        switch type {
            
        case SubSettingsViewController.SettingsType.sensorDelay:
            path = pathForResource("sensorDelays")
            break
            
        case SubSettingsViewController.SettingsType.sensorResetDelay:
            path = pathForResource("sensorResetDelays")
            break
            
        case SubSettingsViewController.SettingsType.pulseLength:
            path = pathForResource("pulseLengths")
            break
            
        case SubSettingsViewController.SettingsType.speedUnit:
            path = pathForResource("speedUnits")
            break
            
        case SubSettingsViewController.SettingsType.distanceUnit:
            path = pathForResource("distanceUnits")
            break
        }
        
        let dict = NSDictionary(contentsOfFile: path!)
        let settingsStrings = dict?.object(forKey: "Strings") as! [String]
        let settingsValues = dict?.object(forKey: "Values") as! [Int]
        
        var settingsValue = ""
        
        switch type {
            
        case SubSettingsViewController.SettingsType.sensorDelay:
            settingsValue = timeFormatted((settingsManager?.sensorDelay.uint64Value)!)
            
        case SubSettingsViewController.SettingsType.sensorResetDelay:
            
            settingsValue = timeFormatted((settingsManager?.sensorResetDelay.uint64Value)!)
            
        case SubSettingsViewController.SettingsType.pulseLength:
            
            for i in 0..<settingsValues.count {
                if settingsValues[i] as Int == settingsManager?.pulseLength.intValue {
                    settingsValue = NSLocalizedString(settingsStrings[i] as String, tableName: "pulseLengthsPlist", bundle: Bundle.main, value: "", comment: "")
                    break
                }
            }
            break
            
        case SubSettingsViewController.SettingsType.speedUnit:
            
            for i in 0..<settingsValues.count {
                if settingsValues[i] as Int == settingsManager?.speedUnit.intValue { 
                    settingsValue = NSLocalizedString(settingsStrings[i] as String, tableName: "speedUnitsPlist", bundle: Bundle.main, value: "", comment: "")
                    break
                }
            }
            break
            
        case SubSettingsViewController.SettingsType.distanceUnit:
            
            for i in 0..<settingsValues.count {
                
                if settingsValues[i] as Int == settingsManager?.distanceUnit.intValue { 
                    settingsValue = NSLocalizedString(settingsStrings[i] as String, tableName: "distanceUnitsPlist", bundle: Bundle.main, value: "", comment: "")
                    break
                }
            }
            break
        }
        
        return settingsValue
    }
    
    fileprivate func timeFormatted(_ totalSeconds: CUnsignedLongLong) -> String {
        
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
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let identifier = cell?.reuseIdentifier
        
        if identifier != nil {
            // The identifiers are set in the storyboard for each cell
            switch (identifier!) {
            case "SensorDelayCell":
                type = SubSettingsViewController.SettingsType.sensorDelay
                performSegue(withIdentifier: "showDelay", sender: self)
                break
                
            case "SensorResetDelayCell":
                type = SubSettingsViewController.SettingsType.sensorResetDelay
                performSegue(withIdentifier: "showDelay", sender: self)
                break
                
            case "PulseLengthCell":
                type = SubSettingsViewController.SettingsType.pulseLength
                performSegue(withIdentifier: "showSubSettings", sender: self)
                break
                
            case "SpeedUnitCell":
                type = SubSettingsViewController.SettingsType.speedUnit
                performSegue(withIdentifier: "showSubSettings", sender: self)
                break
                
            case "DistanceUnitCell":
                type = SubSettingsViewController.SettingsType.distanceUnit
                performSegue(withIdentifier: "showSubSettings", sender: self)
                break;
                
            case "ResetCell":
                settingsManager?.resetSettings()
                nightTimeSwitch.isOn = false
                nightTimeSwitchValueChanged(nightTimeSwitch)
                break;
                
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
