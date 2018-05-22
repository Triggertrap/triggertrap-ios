//
//  CableSelectorViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 18/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class CableSelectorViewController: SplitLayoutViewController {
    
    fileprivate let LastCameraManufacturerSelected = "LastCameraManufacturerSelected"
    fileprivate let LastCameraModelSelected = "LastCameraModelSelected"
    fileprivate let LastCableModelSelected = "LastCableModelSelected"
    
    // MARK: - Local Variables
    
    fileprivate let cableSelector = CableSelector()
    fileprivate var cameraManufacturers: [String] = Array()
    fileprivate var cameraModelsForSelectedManufacturer: [String] = Array()
    fileprivate var lastCameraManufacturerSelected: Int = 0
    fileprivate var lastCameraModelSelected: Int = 0
    fileprivate var urlForCable: String?
    fileprivate let defaults = UserDefaults.standard
    
    // MARK: - Outlets
    
    @IBOutlet weak var cameraManufacturerPicker: UIPickerView!
    @IBOutlet weak var cameraModelPicker: UIPickerView!
    @IBOutlet weak var cableImageView: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutRatio["top"] = 0.5
        layoutRatio["bottom"] = 0.5
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the status bar with animation
        
        self.prefersStatusBarHidden
        
        cameraManufacturerPicker.selectRow(lastCameraManufacturerSelected, inComponent: 0, animated: false)
        cameraModelPicker.selectRow(lastCameraModelSelected, inComponent: 0, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Override defay
        topLeftView.backgroundColor = UIColor.white
        bottomRightView.backgroundColor = UIColor(hex: 0xEFEFEF, alpha: 1.0)
        separatorView?.backgroundColor = UIColor(hex: 0x313131, alpha: 1.0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Show the status bar with animation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private 
    
    fileprivate func commonInit() {
        
        cameraManufacturerPicker.tag = 0
        cameraManufacturerPicker.dataSource = self
        cameraManufacturerPicker.delegate = self
        
        cameraModelPicker.tag = 1
        cameraModelPicker.dataSource = self
        cameraModelPicker.delegate = self
        
        lastCameraManufacturerSelected = 0;
        lastCameraModelSelected = 0;
        
        if (defaults.object(forKey: LastCameraManufacturerSelected) != nil) {
            lastCameraManufacturerSelected = defaults.object(forKey: LastCameraManufacturerSelected) as! Int
        }
        
        if (defaults.object(forKey: LastCameraModelSelected) != nil) {
            lastCameraModelSelected = defaults.object(forKey: LastCameraModelSelected) as! Int
        }
        
        // Get all camera manufacturers
        cameraManufacturers = cableSelector.cameraManufacturers() as! [String]
        
        // Get camera manufacturer selected from array of camera manufacturers and store it as a string
        let cameraManufacturerSelected: String = cameraManufacturers[lastCameraManufacturerSelected]
        
        // Get all camera models for selected camera manufacturer
        cameraModelsForSelectedManufacturer = cableSelector.cameraModels(forManufacturer: cameraManufacturerSelected) as! [String]
        
        // Get camera model selected from array of camera models
        let cameraModelSelected: String = cameraModelsForSelectedManufacturer[lastCameraModelSelected] as String
        
        // Get cable from selected camera manufacturer and model
        let cable: String = cableSelector.cable(forCameraManufacturer: cameraManufacturerSelected, withModel: cameraModelSelected) as String
        
        cableImageView.image = UIImage(named: cable)
        
        let title = String(format: NSLocalizedString("Find a %@ cable on eBay", comment: "Find a %@ cable on eBay"), cable)
        
        buyButton.setTitle(title, for: UIControlState())
        
        urlForCable = cableSelector.url(forCable: cable)
    }
    
    // MARK: - IBActions
    
    @IBAction func buyButtonTapped(_: AnyObject) {
        
        if (urlForCable != nil) {
            UIApplication.shared.openURL(URL(string: urlForCable!)!)
        }
    }
    
    // Call this function to dismiss the view controller from a storyboard view controller button
    @IBAction func dismissViewController(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CableSelectorViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            
            lastCameraManufacturerSelected = row as Int;
            lastCameraModelSelected = 0;
            
            //Get last row selected while interacting with the cameraManufacturerPicker and find the manufacturer selected
            let cameraManufacturerSelected: String = cameraManufacturers[lastCameraManufacturerSelected] as String
            
            cameraModelsForSelectedManufacturer = cableSelector.cameraModels(forManufacturer: cameraManufacturerSelected) as! [String]
            
            defaults.set(lastCameraManufacturerSelected as NSNumber, forKey: LastCameraManufacturerSelected)
            
            defaults.set(lastCameraModelSelected as NSNumber, forKey: LastCameraModelSelected)
            defaults.synchronize()
            
            cameraModelPicker.reloadAllComponents()
            cameraModelPicker.selectRow(0, inComponent: 0, animated: true)
            
        } else {
            
            lastCameraModelSelected = row;
            defaults.set(lastCameraModelSelected as NSNumber, forKey: LastCameraModelSelected)
            defaults.synchronize()
        }
        
        let cameraManufacturerSelected: String = cameraManufacturers[lastCameraManufacturerSelected] as String
        let cameraModelSelected: String = cameraModelsForSelectedManufacturer[lastCameraModelSelected] as String
        
        let cable: String = cableSelector.cable(forCameraManufacturer: cameraManufacturerSelected, withModel: cameraModelSelected) as String
        
        urlForCable = cableSelector.url(forCable: cable)
        cableImageView.image = UIImage(named: cable)
        
        let title = String(format: NSLocalizedString("Find a %@ cable on eBay", comment: "Find a %@ cable on eBay"), cable)
        
        buyButton.setTitle(title, for: UIControlState())
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        if pickerView.tag == 0 {
            pickerLabel.font = UIFont.triggertrap_metric_regular(18.0)
            pickerLabel.text = cameraManufacturers[row] as String
        } else {
            pickerLabel.font = UIFont.triggertrap_metric_light(18.0)
            pickerLabel.text = cameraModelsForSelectedManufacturer[row] as String
        }
        
        pickerLabel.minimumScaleFactor = 0.5
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
}

extension CableSelectorViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 0 {
            return cameraManufacturers.count
        } else {
            return cameraModelsForSelectedManufacturer.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
