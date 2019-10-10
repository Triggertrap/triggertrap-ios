//
//  DistanceLapseViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit
import CoreLocation

class DistanceLapseViewController: TTViewController, CicularSliderDelegate, TTKeyboardDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var metersLabel: UILabel!
    @IBOutlet weak var numberInputView: TTNumberInput!
    
    fileprivate var locationManager: CLLocationManager?
    fileprivate var locationAccuracy: CLLocationAccuracy?
    
    // Local variables
    fileprivate var distanceMajorUnit = ""
    fileprivate var distanceMinorUnit = ""
    fileprivate var speedUnit = ""
    
    fileprivate var distanceMajorFactor: Float = 0.0
    fileprivate var distanceMinorFactor: Float = 0.0
    fileprivate var distanceElapsed: Float = 0.0
    fileprivate var distanceRemaining: Float = 0.0
    fileprivate var interval: Float = 0.0
    fileprivate var speedMultiplier: Float = 0.0
    
    fileprivate var numberOfShotsTaken = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNumberPicker()
        
        registerForNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Setup units depending on phone locality
        setupUnits()
        
        // Load the previous value for number input
        numberInputView.value = numberInputView.savedValue(forKey: "distanceLapse-distance")
        
        if (settingsManager?.distanceUnit.intValue == 0) {
            self.metersLabel.text = NSLocalizedString("meters", comment: "meters");
        } else {
            self.metersLabel.text = NSLocalizedString("yards", comment: "yards");
        }
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is DistanceLapseViewController {
            refreshLocationServices()
        } 
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        removeNotificationObservers()
        
        WearablesManager.sharedInstance.delegate = nil
    } 
    
    // MARK: - IBActions
    
    @IBAction func shutterButtonTouchUpInside(_ sender : UIButton) {
        
        if sequenceManager.activeViewController == nil {
            
            if sufficientVolumeToTrigger() {
                sequenceManager.activeViewController = self
                
                
                //Show red view
                showFeedbackView(ConstStoryboardIdentifierDistanceFeedbackView)
                
                //Setup circular slider
                setupCircularSlider()
                
                // Convert yards to meters if Miles/Yards using the distanceMinorFactor
                interval = Float(self.numberInputView.value) * distanceMinorFactor
                
                // Start location manager
                refreshLocationServices()
                
                // Recalculate distance
                resetDistance()
             }
            
        } else {
            
            // Stop location services
            locationManager?.stopUpdatingLocation()
            
            // Stop output manager
            sequenceManager.cancel()
        }
    }
    
    @IBAction func openKeyboard(_ sender : TTNumberInput) {
        sender.openKeyboard(in: self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Private
    
    fileprivate func refreshLocationServices() {
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is DistanceLapseViewController {
            
            if locationManager == nil {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                
                // Asks the user to grant permission to use the location services while using the application. If statement is required for iOS7 otherwise app will crash.
                if let locationManager = locationManager, locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                    locationManager.requestWhenInUseAuthorization()
                }
            }
        }
        
        locationManager?.startUpdatingLocation()
    }
    
    fileprivate func setupCircularSlider() {
        feedbackViewController.circularSlider?.minimumValue = 0.0
        feedbackViewController.circularSlider?.maximumValue = 1.0
        feedbackViewController.circularSlider?.lineWidth = 12.0
        feedbackViewController.circularSlider?.thumbImage = nil
        feedbackViewController.circularSlider?.isUserInteractionEnabled = false
        feedbackViewController.circularSlider?.transform = CGAffineTransform(rotationAngle: CGFloat(((2.0 * Double.pi) - (1.6 * Double.pi)) / 2.0))
    }

    fileprivate func setupNumberPicker() {
        
        numberInputView.ttKeyboardDelegate = self
        numberInputView.delegate = self
        numberInputView.minValue = 1
        numberInputView.maxNumberLength = 5
        numberInputView.maxValue = 99999
        numberInputView.value = 25
        numberInputView.displayView.textAlignment = NSTextAlignment.center
    }
    
    fileprivate func resetDistance() {
        distanceElapsed = 0.0
        distanceRemaining = interval
        
        updateDistanceDisplay()
    }
    
    fileprivate func updateDistanceDisplay() {
        
        feedbackViewController.sinceLabel?.text = formatDistance(distanceElapsed)
        feedbackViewController.untilLabel?.text = formatDistance(distanceRemaining)
        
        let progress = distanceElapsed / interval
        
        feedbackViewController.circularSlider?.value = progress
        
        if let location = locationManager?.location {
            feedbackViewController.speedLabel?.text = String.localizedStringWithFormat("%.2f %@", Float(max(location.speed, 0.0)) * speedMultiplier, speedUnit)
        }
    }
    
    fileprivate func formatDistance(_ metres: Float) -> String {
        
        var value: Float = 0.0
        var unit: String = ""
        var pattern: String = ""
        
        if metres >= distanceMajorFactor {
            value = metres / distanceMajorFactor
            unit = distanceMajorUnit
            pattern = "%.2f %@"
        } else {
            value = metres / distanceMinorFactor
            unit = distanceMinorUnit
            pattern = "%.0f %@"
        }
        
        return String.localizedStringWithFormat(pattern, value, unit)
    }
    
    fileprivate func updateInterfaceForUnknownLocation() {
        
        ShowAlertInViewController(self, title: NSLocalizedString("Where am I?", comment: "Where am I?"), message: NSLocalizedString("I don't know where I am... Are location services disabled, perhaps?", comment: "I don't know where I am... Are location services disabled, perhaps?"), cancelButton: NSLocalizedString("OK", comment: "OK"))
        
        // Stop updating location
        locationManager?.stopUpdatingLocation()
    }
    
    // MARK: - Notifications

    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(DistanceLapseViewController.setupUnits), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    fileprivate func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    // MARK: - Public 
    
    @objc func setupUnits() {
        
        switch settingsManager!.speedUnit.intValue {
        case 0:
            // Meters per second
            speedUnit = NSLocalizedString("m/s", comment: "m/s")
            speedMultiplier = 1
            break
            
        case 1:
            // Miles per hour
            speedUnit = NSLocalizedString("mph", comment: "mph")
            speedMultiplier = 2.237
            break
            
        case 2:
            // Kilometers per hour
            speedUnit = NSLocalizedString("km/h", comment: "km/h")
            speedMultiplier = 3.6
            break
            
        default:
            // Meters per second
            speedUnit = NSLocalizedString("m/s", comment: "m/s")
            speedMultiplier = 1
            break
        }
        
        switch settingsManager!.distanceUnit.intValue {
        case 0:
            // Meters / Kilometers
            distanceMajorUnit = NSLocalizedString("km", comment: "km")
            distanceMinorUnit = NSLocalizedString("m", comment: "m")
            
            distanceMajorFactor = 1000.0
            distanceMinorFactor = 1.0
            
            break
        case 1:
            // Miles / Yards
            distanceMajorUnit = NSLocalizedString("miles", comment: "miles")
            distanceMinorUnit = NSLocalizedString("yards", comment: "yards")
            
            // 1609.44 meters in a mile
            distanceMajorFactor = 1609.44
            
            // 0.9144 meters in a yard
            distanceMinorFactor = 0.9144
            break
            
        default:
            // Meters / Kilometers
            distanceMajorUnit = NSLocalizedString("km", comment: "km")
            distanceMinorUnit = NSLocalizedString("m", comment: "m")
            
            distanceMajorFactor = 1000.0
            distanceMinorFactor = 1.0
            break
        }
    }
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        applyThemeUpdateToNumberInput(numberInputView)
    }
    
    override func feedbackViewShowAnimationCompleted() {
        super.feedbackViewShowAnimationCompleted()
        
        if let activeViewController = sequenceManager.activeViewController, activeViewController is DistanceLapseViewController {
            
            // Assign delegates
            prepareForSequence()
            
            // Trigger the camera
            sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: (settingsManager?.pulseLength.doubleValue)!, unit: .milliseconds))]), repeatSequence: false)
        }
    }
    
    override func didFinishSequence() {
        // Override the default behaviour of the
    }
    
    override func didCancelSequence() {
        super.didCancelSequence()
    }
}

extension DistanceLapseViewController: TTNumberInputDelegate {
    
    // MARK: - TTNumberInput Delegate
    
    func ttNumberInputKeyboardDidDismiss() {
        numberInputView.saveValue(numberInputView.value, forKey: "distanceLapse-distance")
    }
}

extension DistanceLapseViewController: CLLocationManagerDelegate {
    
    
    // MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case CLAuthorizationStatus.notDetermined:
            manager.startUpdatingLocation()
            break
            
        case CLAuthorizationStatus.restricted:
            updateInterfaceForUnknownLocation()
            break
            
        case CLAuthorizationStatus.denied:
            updateInterfaceForUnknownLocation()
            break
            
        case CLAuthorizationStatus.authorizedAlways:
            
            if let location = manager.location, location.gpsSignalStrength() == 0 {
                updateInterfaceForUnknownLocation()
                sequenceManager.cancel()
            } else {
                manager.startUpdatingLocation()
            }
            
            break
            
        case CLAuthorizationStatus.authorizedWhenInUse:
            
            if let location = manager.location {
                if location.gpsSignalStrength() == 0 {
                    updateInterfaceForUnknownLocation()
                    sequenceManager.cancel()
                } else {
                    manager.startUpdatingLocation()
                }
            } else {
                manager.startUpdatingLocation()
            }
            
            break
        @unknown default:
            updateInterfaceForUnknownLocation()
            break
        }
    }
    
         
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
        updateInterfaceForUnknownLocation()
        sequenceManager.cancel()
    }
}


extension DistanceLapseViewController: WearableManagerDelegate {
    
    func watchDidTrigger() {
        self.shutterButtonTouchUpInside(UIButton())
    }
}
