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
        case sensorDelay = 0,
        sensorResetDelay = 1
    }
    
    // MARK: - Lifecycle
    
    var settingsType : SettingsType = SettingsType.sensorDelay
    
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
        
        if settingsType == SettingsType.sensorDelay {
            numberInputView.value = SettingsManager.sharedInstance().sensorDelay.uint64Value
            title = NSLocalizedString("Sensor Delay", comment: "Sensor Delay")
        } else {
            numberInputView.value = SettingsManager.sharedInstance().sensorResetDelay.uint64Value
            title = NSLocalizedString("Sensor Reset Delay", comment: "Sensor Reset Delay")
        }
        
        numberInputView.displayView.textAlignment = NSTextAlignment.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyThemeUpdateToTimeInput(numberInputView)
        
        self.navigationController?.navigationBar.tintColor = UIColor.triggertrap_iconColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0) 
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.triggertrap_metric_regular(23.0), NSAttributedStringKey.foregroundColor: UIColor.triggertrap_iconColor(1.0)]
    }
    
    override func viewWillLayoutSubviews()  {
        super.viewWillLayoutSubviews()
        
        numberInputView.hideKeyboard(withAnimation: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        numberInputView.openKeyboard(in: self.view, covering: bottomRightView, animate: false)
        self.view.layoutSubviews()
    }
    
    func numberInputValueChanged() {
        
        if settingsType == SettingsType.sensorDelay {
            SettingsManager.sharedInstance().sensorDelay = NSNumber(value: numberInputView.value as UInt64)
        } else {
            SettingsManager.sharedInstance().sensorResetDelay = NSNumber(value: numberInputView.value as UInt64)
        }
    }
    
    func dismissButtonPressed() { 
        self.navigationController?.popViewController(animated: true)
    } 
}
