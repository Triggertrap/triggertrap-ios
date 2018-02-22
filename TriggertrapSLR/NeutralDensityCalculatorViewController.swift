//
//  NeutralDensityCalculatorViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 18/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

typealias NDCalculatorCompletionBlock = ((duration: UInt64) -> Void)

class NeutralDensityCalculatorViewController: SplitLayoutViewController, HorizontalPickerDelegate, TTNumberInputDelegate {
    
    var isEmbedded = false
    var ndCalculatorCompletionBlock: NDCalculatorCompletionBlock?
    
    private var kHundredHoursInMilliseconds: Int = 360000000
    private var kHourInMilliseconds: Int = 3600000
    
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
    
    private var isHoursMinutesSecondsFormat = false
    private var ndFilterArray: NSMutableArray!
    private var baseShutterSpeedArray: NSArray!
    private var ndFilterPosition = 0
    private var shutterSpeedPosition = 0
    private var duration: UInt64 = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isEmbedded {
            
            let leftBarButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Plain, target: self, action: #selector(NeutralDensityCalculatorViewController.cancelButtonTapped(_:)))
            leftBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0)], forState: .Normal)
            self.navigationItem.leftBarButtonItem = leftBarButton
        
            // Set the right bar button item.
            let rightBarButton = UIBarButtonItem(title: NSLocalizedString("OK", comment: "OK"), style: .Plain, target: self, action: #selector(NeutralDensityCalculatorViewController.calculateButtonTapped(_:)))
            rightBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0)], forState: .Normal)
            self.navigationItem.rightBarButtonItem = rightBarButton
            
            self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        }
        
        ndFilterArray = NSMutableArray(contentsOfFile: pathForResource("NDFilter"))
        
        for i in 0..<ndFilterArray.count {
            
            let filter: String = ndFilterArray[i].objectForKey("string") as! String
            
            let stop = String(format: NSLocalizedString("%@ stop", comment: "%@ stop"), filter)
            let stops = String(format: NSLocalizedString("%@ stops", comment: "%@ stops"), filter)
            
            let string: String = (i == 0) ? stop : stops
            
            ndFilterArray[i].setValue(string, forKey: "string")
        }
        
        baseShutterSpeedArray = NSArray(contentsOfFile: pathForResource("ShutterSpeed"))
        
        filterStrengthPicker.delegate = self
        filterStrengthPicker.dataSource = ndFilterArray as Array
        filterStrengthPicker.minimumValue = NSNumber(integer: 1)
        filterStrengthPicker.maximumValue = NSNumber(integer: 20)
        filterStrengthPicker.defaultIndex = ndFilterPosition
        filterStrengthPicker.tag = 0
        
        baseShutterSpeedPicker.delegate = self
        baseShutterSpeedPicker.dataSource = baseShutterSpeedArray as Array
        baseShutterSpeedPicker.minimumValue = NSNumber(float: 0.12)
        baseShutterSpeedPicker.maximumValue = NSNumber(integer: 30000)
        baseShutterSpeedPicker.defaultIndex = shutterSpeedPosition
        baseShutterSpeedPicker.tag = 1
        
        hoursMinutesSecondsView.setFontColor(UIColor.triggertrap_primaryColor(1.0))
        hoursMinutesSecondsView.showFractions = false
        hoursMinutesSecondsView.borderColor  = UIColor.clearColor()
        hoursMinutesSecondsView.maxValue = 359999990
        hoursMinutesSecondsView.value = 30000
        hoursMinutesSecondsView.displayView.textAlignment = NSTextAlignment.Center
        
        let adjPoint = hoursMinutesSecondsView.adjustedSize()
        hmsHeightConstraint.constant = adjPoint.y
        hmsWidthConstraint.constant = adjPoint.x
        hoursMinutesSecondsView.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        filterStrengthPicker.currentIndex = NSIndexPath(forRow: filterStrengthPicker.savedIndexForKey("nd-calculator.filterStrengthPicker"), inSection: 0)
        baseShutterSpeedPicker.currentIndex = NSIndexPath(forRow: baseShutterSpeedPicker.savedIndexForKey("nd-calculator.baseShutterSpeedPicker"), inSection: 0)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Private
    
    private func ndTime(stops: Int, withShutterSpeed speed: Int) -> String {
        
        var ndTimeString = ""
        
        let result = Double(baseShutterSpeedArray[speed].objectForKey("value")! as! Double) * pow(2.0, Double(stops + 1))
        
        duration = UInt64(result)
        
        if result >= baseShutterSpeedArray.lastObject!.objectForKey("value")! as! Double {
            isHoursMinutesSecondsFormat = true
            ndTimeString = "\(result)"
        } else {
            isHoursMinutesSecondsFormat = false
            
            for var i: Int = speed; result >= baseShutterSpeedArray.objectAtIndex(i).objectForKey("value")! as! Double ; i += 1 {
                
                if result > baseShutterSpeedArray.objectAtIndex(i).objectForKey("value")! as! Double {
                    
                    let lowerDif = result - Double(baseShutterSpeedArray.objectAtIndex(i).objectForKey("value") as! Double)
                    
                    let higherDif = (baseShutterSpeedArray.objectAtIndex(i + 1).objectForKey("value")! as! Double) - result
                    
                    let minimum = min(lowerDif, higherDif)
                    
                    ndTimeString = (minimum == lowerDif) ? baseShutterSpeedArray[i].objectForKey("string")! as! String : baseShutterSpeedArray[i + 1].objectForKey("string")! as! String
                }
            }
        }
        
        return ndTimeString
    }
    
    // MARK: - Horizontal Picker Delegate
    
    func horizontalPicker(horizontalPicker: AnyObject!, didSelectObjectFromDataSourceAtIndex index: Int) {
        let picker = horizontalPicker as! HorizontalPicker
        
        switch picker.tag {
            
        case 0:
            filterStrengthPicker.saveIndex(index, forKey: "nd-calculator.filterStrengthPicker")
            let array = picker.dataSource as NSArray
            
            let stops = array.objectAtIndex(index).objectForKey("string")! as! String
            let filter = array.objectAtIndex(index).objectForKey("string1")! as! String
            
            let filterText = String(format: NSLocalizedString("%@ %@ filter", comment: "%@ %@ filter"), stops, filter)
            
            stopFilterLabel.text = filterText
            ndFilterPosition = Int(index)
            break
            
        case 1:
            baseShutterSpeedPicker.saveIndex(index, forKey: "nd-calculator.baseShutterSpeedPicker")
            shutterSpeedPosition = Int(index)
            break
            
        default:
            print("default", terminator: "")
            break
        }
        
        let shutterSpeedText = ndTime(ndFilterPosition, withShutterSpeed: shutterSpeedPosition)
        
        if isHoursMinutesSecondsFormat {
            
            if (shutterSpeedText as NSString).longLongValue > CLongLong(kHundredHoursInMilliseconds) {
                stepLabel.hidden = false
                hoursLabel.hidden = false
                stepLabel.text = "\((shutterSpeedText as NSString).longLongValue / CLongLong(kHourInMilliseconds))"
                hoursMinutesSecondsView.hidden = true
            } else {
                stepLabel.hidden = true
                hoursLabel.hidden = true
                hoursMinutesSecondsView.hidden = false
                hoursMinutesSecondsView.value = CUnsignedLongLong((shutterSpeedText as NSString).longLongValue)
            }
        } else {
            stepLabel.hidden = false
            hoursLabel.hidden = true
            stepLabel.text = shutterSpeedText
            hoursMinutesSecondsView.hidden = true
        } 
    }
    
    // MARK: - Action
    
    func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func calculateButtonTapped(sender: AnyObject) {
        
        if duration < UInt64(ConstMinDuration) {
            ShowAlertInViewController(self, title: NSLocalizedString("Slow down, buddy!", comment: "Slow down, buddy!"),  message: NSLocalizedString("This shutter speed is a bit too fast for bulb mode. Try using Shutter Priority on your camera, and Triggertrap as a cable release.", comment: "This shutter speed is a bit too fast for bulb mode. Try using Shutter Priority on your camera, and Triggertrap as a cable release."), cancelButton: NSLocalizedString("OK", comment: "OK"))
        } else {
            ndCalculatorCompletionBlock?(duration: duration)
            self.dismissViewControllerAnimated(true, completion: nil)
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
        hoursMinutesSecondsView.borderColor = UIColor.clearColor()
        hoursMinutesSecondsView.borderHighlightColor = UIColor.triggertrap_primaryColor()
        hoursMinutesSecondsView.setNeedsDisplay()
    }
}
