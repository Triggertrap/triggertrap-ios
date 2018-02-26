//
//  NeutralDensityCalculatorViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 18/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

typealias NDCalculatorCompletionBlock = ((_ duration: UInt64) -> Void)

class NeutralDensityCalculatorViewController: SplitLayoutViewController, HorizontalPickerDelegate, TTNumberInputDelegate {
    
    var isEmbedded = false
    var ndCalculatorCompletionBlock: NDCalculatorCompletionBlock?
    
    fileprivate var kHundredHoursInMilliseconds: Int = 360000000
    fileprivate var kHourInMilliseconds: Int = 3600000
    
    @IBOutlet weak var filterStrengthLabel: UILabel!
    @IBOutlet weak var baseShutterSpeedLabel: UILabel!
    @IBOutlet weak var filterStrengthPicker: HorizontalPicker!
    @IBOutlet weak var baseShutterSpeedPicker: HorizontalPicker!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var shutterSpeedLabel: UILabel!
    @IBOutlet weak var stopFilterLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var hoursMinutesSecondsView: TTTimeInput!
    @IBOutlet weak var hmsWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hmsHeightConstraint: NSLayoutConstraint!
    
    fileprivate var isHoursMinutesSecondsFormat = false
    fileprivate var ndFilterArray: NSMutableArray!
    fileprivate var baseShutterSpeedArray: NSArray!
    fileprivate var ndFilterPosition = 0
    fileprivate var shutterSpeedPosition = 0
    fileprivate var duration: UInt64 = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isEmbedded {
            
            let leftBarButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .plain, target: self, action: #selector(NeutralDensityCalculatorViewController.cancelButtonTapped(_:)))
            leftBarButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.triggertrap_metric_regular(23.0)], for: UIControlState())
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            // Set the right bar button item.
            let rightBarButton = UIBarButtonItem(title: NSLocalizedString("OK", comment: "OK"), style: .plain, target: self, action: #selector(NeutralDensityCalculatorViewController.calculateButtonTapped(_:)))
            rightBarButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.triggertrap_metric_regular(23.0)], for: UIControlState())
            self.navigationItem.rightBarButtonItem = rightBarButton
            
            self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        }
        
        ndFilterArray = NSMutableArray(contentsOfFile: pathForResource("NDFilter"))
        
        for i in 0..<ndFilterArray.count {
            
            let filter: String = (ndFilterArray[i] as AnyObject).object(forKey: "string") as! String
            
            let stop = String(format: NSLocalizedString("%@ stop", comment: "%@ stop"), filter)
            let stops = String(format: NSLocalizedString("%@ stops", comment: "%@ stops"), filter)
            
            let string: String = (i == 0) ? stop : stops
            
            (ndFilterArray[i] as AnyObject).setValue(string, forKey: "string")
        }
        
        baseShutterSpeedArray = NSArray(contentsOfFile: pathForResource("ShutterSpeed"))
        
        filterStrengthPicker.delegate = self
        filterStrengthPicker.dataSource = ndFilterArray as Array
        filterStrengthPicker.minimumValue = NSNumber(value: 1 as Int)
        filterStrengthPicker.maximumValue = NSNumber(value: 20 as Int)
        filterStrengthPicker.defaultIndex = ndFilterPosition
        filterStrengthPicker.tag = 0
        
        baseShutterSpeedPicker.delegate = self
        baseShutterSpeedPicker.dataSource = baseShutterSpeedArray as Array
        baseShutterSpeedPicker.minimumValue = NSNumber(value: 0.12 as Float)
        baseShutterSpeedPicker.maximumValue = NSNumber(value: 30000 as Int)
        baseShutterSpeedPicker.defaultIndex = shutterSpeedPosition
        baseShutterSpeedPicker.tag = 1
        
        hoursMinutesSecondsView.setFontColor(UIColor.triggertrap_primaryColor(1.0))
        hoursMinutesSecondsView.showFractions = false
        hoursMinutesSecondsView.borderColor  = UIColor.clear
        hoursMinutesSecondsView.maxValue = 359999990
        hoursMinutesSecondsView.value = 30000
        hoursMinutesSecondsView.displayView.textAlignment = NSTextAlignment.center
        
        let adjPoint = hoursMinutesSecondsView.adjustedSize()
        hmsHeightConstraint.constant = adjPoint.y
        hmsWidthConstraint.constant = adjPoint.x
        hoursMinutesSecondsView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterStrengthPicker.currentIndex = IndexPath(row: filterStrengthPicker.savedIndex(forKey: "nd-calculator.filterStrengthPicker"), section: 0)
        baseShutterSpeedPicker.currentIndex = IndexPath(row: baseShutterSpeedPicker.savedIndex(forKey: "nd-calculator.baseShutterSpeedPicker"), section: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private
    
    fileprivate func ndTime(_ stops: Int, withShutterSpeed speed: Int) -> String {
        
        var ndTimeString = ""
        
        let result = Double((baseShutterSpeedArray[speed] as AnyObject).object(forKey: "value")! as! Double) * pow(2.0, Double(stops + 1))
        
        duration = UInt64(result)
        
        if result >= (baseShutterSpeedArray.lastObject! as AnyObject).object(forKey: "value")! as! Double {
            isHoursMinutesSecondsFormat = true
            ndTimeString = "\(result)"
        } else {
            isHoursMinutesSecondsFormat = false
            
            var i = speed
            
            while result >= (baseShutterSpeedArray.object(at: i) as AnyObject).object(forKey: "value")! as! Double {
                
                if result > (baseShutterSpeedArray.object(at: i) as AnyObject).object(forKey: "value")! as! Double {
                    
                    let lowerDif = result - Double((baseShutterSpeedArray.object(at: i) as AnyObject).object(forKey: "value") as! Double)
                    
                    let higherDif = ((baseShutterSpeedArray.object(at: i + 1) as AnyObject).object(forKey: "value")! as! Double) - result
                    
                    let minimum = min(lowerDif, higherDif)
                    
                    ndTimeString = (minimum == lowerDif) ? (baseShutterSpeedArray[i] as AnyObject).object(forKey: "string")! as! String : (baseShutterSpeedArray[i + 1] as AnyObject).object(forKey: "string")! as! String
                }
                
                i += 1
            }
        }
        
        return ndTimeString
    }
    
    // MARK: - Horizontal Picker Delegate
    
    func horizontalPicker(_ horizontalPicker: Any!, didSelectObjectFromDataSourceAt index: Int) {
        let picker = horizontalPicker as! HorizontalPicker
        
        switch picker.tag {
            
        case 0:
            filterStrengthPicker.save(index, forKey: "nd-calculator.filterStrengthPicker")
            let array = picker.dataSource as NSArray
            
            let stops = (array.object(at: index) as AnyObject).object(forKey: "string")! as! String
            let filter = (array.object(at: index) as AnyObject).object(forKey: "string1")! as! String
            
            let filterText = String(format: NSLocalizedString("%@ %@ filter", comment: "%@ %@ filter"), stops, filter)
            
            stopFilterLabel.text = filterText
            ndFilterPosition = Int(index)
            break
            
        case 1:
            baseShutterSpeedPicker.save(index, forKey: "nd-calculator.baseShutterSpeedPicker")
            shutterSpeedPosition = Int(index)
            break
            
        default:
            print("default", terminator: "")
            break
        }
        
        let shutterSpeedText = ndTime(ndFilterPosition, withShutterSpeed: shutterSpeedPosition)
        
        if isHoursMinutesSecondsFormat {
            
            if (shutterSpeedText as NSString).longLongValue > CLongLong(kHundredHoursInMilliseconds) {
                stepLabel.isHidden = false
                hoursLabel.isHidden = false
                stepLabel.text = "\((shutterSpeedText as NSString).longLongValue / CLongLong(kHourInMilliseconds))"
                hoursMinutesSecondsView.isHidden = true
            } else {
                stepLabel.isHidden = true
                hoursLabel.isHidden = true
                hoursMinutesSecondsView.isHidden = false
                hoursMinutesSecondsView.value = CUnsignedLongLong((shutterSpeedText as NSString).longLongValue)
            }
        } else {
            stepLabel.isHidden = false
            hoursLabel.isHidden = true
            stepLabel.text = shutterSpeedText
            hoursMinutesSecondsView.isHidden = true
        } 
    }
    
    // MARK: - Action
    
    @objc func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func calculateButtonTapped(_ sender: AnyObject) {
        
        if duration < UInt64(ConstMinDuration) {
            ShowAlertInViewController(self, title: NSLocalizedString("Slow down, buddy!", comment: "Slow down, buddy!"),  message: NSLocalizedString("This shutter speed is a bit too fast for bulb mode. Try using Shutter Priority on your camera, and Triggertrap as a cable release.", comment: "This shutter speed is a bit too fast for bulb mode. Try using Shutter Priority on your camera, and Triggertrap as a cable release."), cancelButton: NSLocalizedString("OK", comment: "OK"))
        } else {
            ndCalculatorCompletionBlock?(duration)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        if isEmbedded {
            self.leftButton?.removeFromSuperview()
            self.rightButton?.removeFromSuperview()
            
            // Update the color of the Cancel/OK buttons
            self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        }
        
        filterStrengthLabel.textColor = UIColor.triggertrap_foregroundColor()
        baseShutterSpeedLabel.textColor = UIColor.triggertrap_foregroundColor()
        
        applyThemeUpdateToPicker(filterStrengthPicker)
        applyThemeUpdateToPicker(baseShutterSpeedPicker)
        
        shutterSpeedLabel.textColor = UIColor.triggertrap_primaryColor()
        stopFilterLabel.textColor = UIColor.triggertrap_primaryColor()
        stepLabel.textColor = UIColor.triggertrap_primaryColor()
        hoursLabel.textColor = UIColor.triggertrap_primaryColor()
        
        hoursMinutesSecondsView.setFontColor(UIColor.triggertrap_primaryColor())
        hoursMinutesSecondsView.borderColor = UIColor.clear
        hoursMinutesSecondsView.borderHighlightColor = UIColor.triggertrap_primaryColor()
        hoursMinutesSecondsView.setNeedsDisplay()
    }
}
