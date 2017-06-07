//
//  SensorDelayViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 22/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class SensorDelayViewController: SplitLayoutViewController, TTNumberInputDelegate, TTKeyboardDelegate {
    
    @IBOutlet var numberInputView: TTTimeInput!
    
    
    enum SettingsType : Int {
        case SensorDelay = 0,
        SensorResetDelay = 1
    }
    
    // MARK: - Lifecycle
    
    var settingsType : SettingsType = SettingsType.SensorDelay
    
    override func viewDidLoad() {
//        layoutRatio = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? ["top": (2.0 / 4.0), "bottom": (2.0 / 4.0)] : ["top": (2.0 / 4.0), "bottom": (2.0 / 4.0)]
        
        super.viewDidLoad()
        
        numberInputView.ttKeyboardDelegate = self
        numberInputView.delegate = self
        numberInputView.minValue = 0
        numberInputView.maxValue = 3599999 // 00m:00s:000ms
        numberInputView.keyboardCanBeDismissed = false
        numberInputView.showFractionsInFull = true
        numberInputView.hoursVisible(false)
        numberInputView.maxNumberLength = 6
        
        if settingsType == SettingsType.SensorDelay {
            numberInputView.value = SettingsManager.sharedInstance().sensorDelay.unsignedLongLongValue
            title = NSLocalizedString("Sensor Delay", comment: "Sensor Delay")
        } else {
            numberInputView.value = SettingsManager.sharedInstance().sensorResetDelay.unsignedLongLongValue
            title = NSLocalizedString("Sensor Reset Delay", comment: "Sensor Reset Delay")
        }
        
        numberInputView.displayView.textAlignment = NSTextAlignment.Center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        applyThemeUpdateToTimeInput(numberInputView)
        
        self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0) 
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0), NSForegroundColorAttributeName: UIColor.triggertrap_iconColor(1.0)]
    }
    
    override func viewWillLayoutSubviews()  {
        super.viewWillLayoutSubviews()
        
        numberInputView.hideKeyboardWithAnimation(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        numberInputView.openKeyboardInView(self.view, covering: bottomRightView, animate: false)
        self.view.layoutSubviews()
    }
    
    func numberInputValueChanged() {
        
        if settingsType == SettingsType.SensorDelay {
            SettingsManager.sharedInstance().sensorDelay = NSNumber(unsignedLongLong: numberInputView.value)
        } else {
            SettingsManager.sharedInstance().sensorResetDelay = NSNumber(unsignedLongLong: numberInputView.value)
        }
    }
    
    func dismissButtonPressed() { 
        self.navigationController?.popViewControllerAnimated(true)
    } 
}