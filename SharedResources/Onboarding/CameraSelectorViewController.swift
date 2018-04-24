//
//  CameraSelectorViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 28/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class CameraSelectorViewController: OnboardingViewController {
    
    @IBOutlet var kitImageView: UIImageView!
    @IBOutlet var whiteView: UIView!
    @IBOutlet var whiteViewDescriptionLabel: UILabel!
    @IBOutlet var whiteViewTitleLabel: UILabel!
    @IBOutlet var getMobileKitButton: UIButton!
    @IBOutlet var greyViewInformationLabel: UILabel!
    @IBOutlet var greyViewPraiseLabel: UILabel!
    @IBOutlet var pickersView: UIView!
    
    @IBOutlet var separatorLine: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    // Information view
    @IBOutlet var informationView: UIView!
    
    @IBOutlet var dismissButton: UIButton!
    
    // MARK: - Local Variables
    var cableSelector = CableSelector()
    var cameraManufacturers: [String] = Array()
    var cameraModelsForSelectedManufacturer: [String] = Array()
    var lastCameraManufacturerSelected: Int = 0
    var lastCameraModelSelected: Int = 0
    var urlForCable: String?
    let defaults = UserDefaults.standard
    
    // MARK: - Outlets
    @IBOutlet var cameraManufacturerPicker: UIPickerView!
    @IBOutlet var cameraModelPicker: UIPickerView!
    @IBOutlet var buyButton: UIButton!
    
    // MARK: - Lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraManufacturerPicker.selectRow(lastCameraManufacturerSelected, inComponent: 0, animated: false)
        cameraModelPicker.selectRow(lastCameraModelSelected, inComponent: 0, animated: false)
    }
    
    func commonInit() {
        
        cameraManufacturerPicker.tag = 0
        cameraManufacturerPicker.dataSource = self
        cameraManufacturerPicker.delegate = self
        
        cameraModelPicker.tag = 1
        cameraModelPicker.dataSource = self
        cameraModelPicker.delegate = self
        
        lastCameraManufacturerSelected = 0
        lastCameraModelSelected = 5
        
        // Get all camera manufacturers
        cameraManufacturers = cableSelector.cameraManufacturers() as! [String]
        
        // Get camera manufacturer selected from array of camera manufacturers and store it as a string
        let cameraManufacturerSelected = cameraManufacturers[lastCameraManufacturerSelected]
        
        // Get all camera models for selected camera manufacturer
        cameraModelsForSelectedManufacturer = cableSelector.cameraModels(forManufacturer: cameraManufacturerSelected) as! [String]
        
        // Get camera model selected from array of camera models
        let cameraModelSelected = cameraModelsForSelectedManufacturer[lastCameraModelSelected] as String
        
        // Get cable from selected camera manufacturer and model
        let cable = cableSelector.cable(forCameraManufacturer: cameraManufacturerSelected, withModel: cameraModelSelected) as String
        
        kitImageView.image = UIImage(named: cable)
        
        urlForCable = cableSelector.url(forCable: cable)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func buyButtonTapped(_ button: UIButton) {
        
        if (urlForCable != nil) {
            
            showActionSheet(button.frame)
        }
    }
}

extension CameraSelectorViewController: UIPickerViewDelegate {
    
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            
            lastCameraManufacturerSelected = row as Int;
            lastCameraModelSelected = 0;
            
            //Get last row selected while interacting with the cameraManufacturerPicker and find the manufacturer selected
            let cameraManufacturerSelected: String = cameraManufacturers[lastCameraManufacturerSelected] as String
            
            cameraModelsForSelectedManufacturer = cableSelector.cameraModels(forManufacturer: cameraManufacturerSelected) as! [String]
            
            cameraModelPicker.reloadAllComponents()
            cameraModelPicker.selectRow(0, inComponent: 0, animated: true)
            
        } else {
            lastCameraModelSelected = row;
        }
        
        let cameraManufacturerSelected: String = cameraManufacturers[lastCameraManufacturerSelected] as String
        let cameraModelSelected: String = cameraModelsForSelectedManufacturer[lastCameraModelSelected] as String
        
        let cable: String = cableSelector.cable(forCameraManufacturer: cameraManufacturerSelected, withModel: cameraModelSelected) as String
        
        urlForCable = cableSelector.url(forCable: cable)
        kitImageView.image = UIImage(named: cable)
    }
}

extension CameraSelectorViewController: UIPickerViewDataSource {
    
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

extension CameraSelectorViewController: UIActionSheetDelegate {
    
    fileprivate func showActionSheet(_ rect: CGRect) {
        
        let actionSheet: UIActionSheet = UIActionSheet(title: nil,
            delegate: self,
            cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"),
            destructiveButtonTitle: nil,
            otherButtonTitles: NSLocalizedString("Open in Safari", comment: "Open in Safari"))
        
        actionSheet.actionSheetStyle = UIActionSheetStyle.blackOpaque
        
        let deviceType = UIDevice.current.model
        
        if deviceType == "iPhone" {
            actionSheet.show(in: self.view)
        } else {
            // iPad
            actionSheet.show(from: rect, in: self.view, animated: true)
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            UIApplication.shared.openURL(URL(string: urlForCable!)!)
        }
    }
}
