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
    
    private var locationManager: CLLocationManager?
    private var locationAccuracy: CLLocationAccuracy?
    
    // Local variables
    private var distanceMajorUnit = ""
    private var distanceMinorUnit = ""
    private var speedUnit = ""
    
    private var distanceMajorFactor: Float = 0.0
    private var distanceMinorFactor: Float = 0.0
    private var distanceElapsed: Float = 0.0
    private var distanceRemaining: Float = 0.0
    private var interval: Float = 0.0
    private var speedMultiplier: Float = 0.0
    
    private var numberOfShotsTaken = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNumberPicker()
        
        registerForNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Setup units depending on phone locality
        setupUnits()
        
        // Load the previous value for number input
        numberInputView.value = numberInputView.savedValueForKey("distanceLapse-distance")
        
        if (settingsManager.distanceUnit.integerValue == 0) {
            self.metersLabel.text = NSLocalizedString("meters", comment: "meters");
        } else {
            self.metersLabel.text = NSLocalizedString("yards", comment: "yards");
        }
        
        WearablesManager.sharedInstance.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is DistanceLapseViewController {
            refreshLocationServices()
        } 
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        removeNotificationObservers()
        
        WearablesManager.sharedInstance.delegate = nil
    } 
    
    // MARK: - IBActions
    
    @IBAction func shutterButtonTouchUpInside(sender : UIButton) {
        
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
    
    @IBAction func openKeyboard(sender : TTNumberInput) {
        sender.openKeyboardInView(self.view, covering: self.bottomRightView)
    }
    
    // MARK: - Private
    
    private func refreshLocationServices() {
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is DistanceLapseViewController {
            
            if locationManager == nil {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                
                // Asks the user to grant permission to use the location services while using the application. If statement is required for iOS7 otherwise app will crash.
                if let locationManager = locationManager where locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                    if #available(iOS 8.0, *) {
                        locationManager.requestWhenInUseAuthorization()
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        
        locationManager?.startUpdatingLocation()
    }
    
    private func setupCircularSlider() {
        feedbackViewController.circularSlider?.minimumValue = 0.0
        feedbackViewController.circularSlider?.maximumValue = 1.0
        feedbackViewController.circularSlider?.lineWidth = 12.0
        feedbackViewController.circularSlider?.thumbImage = nil
        feedbackViewController.circularSlider?.userInteractionEnabled = false
        feedbackViewController.circularSlider?.transform = CGAffineTransformMakeRotation(CGFloat(((2.0 * M_PI) - (1.6 * M_PI)) / 2.0))
    }

    private func setupNumberPicker() {
        
        numberInputView.ttKeyboardDelegate = self
        numberInputView.delegate = self
        numberInputView.minValue = 1
        numberInputView.maxNumberLength = 5
        numberInputView.maxValue = 99999
        numberInputView.value = 25
        numberInputView.displayView.textAlignment = NSTextAlignment.Center
    }
    
    private func resetDistance() {
        distanceElapsed = 0.0
        distanceRemaining = interval
        
        updateDistanceDisplay()
    }
    
    private func updateDistanceDisplay() {
        
        feedbackViewController.sinceLabel?.text = formatDistance(distanceElapsed)
        feedbackViewController.untilLabel?.text = formatDistance(distanceRemaining)
        
        let progress = distanceElapsed / interval
        
        feedbackViewController.circularSlider?.value = progress
        
        if let location = locationManager?.location {
            feedbackViewController.speedLabel?.text = String.localizedStringWithFormat("%.2f %@", Float(max(location.speed, 0.0)) * speedMultiplier, speedUnit)
        }
    }
    
    private func formatDistance(metres: Float) -> String {
        
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
    
    private func updateInterfaceForUnknownLocation() {
        
        ShowAlertInViewController(self, title: NSLocalizedString("Where am I?", comment: "Where am I?"), message: NSLocalizedString("I don't know where I am... Are location services disabled, perhaps?", comment: "I don't know where I am... Are location services disabled, perhaps?"), cancelButton: NSLocalizedString("OK", comment: "OK"))
        
        // Stop updating location
        locationManager?.stopUpdatingLocation()
    }
    
    // MARK: - Notifications

    private func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUnits", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    private func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    // MARK: - Public 
    
    func setupUnits() {
        
        switch settingsManager.speedUnit.integerValue {
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
        
        switch settingsManager.distanceUnit.integerValue {
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
        
        if let activeViewController = sequenceManager.activeViewController where activeViewController is DistanceLapseViewController {
            
            // Assign delegates
            prepareForSequence()
            
            // Trigger the camera
            sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: settingsManager.pulseLength.doubleValue, unit: .Milliseconds))]), repeatSequence: false)
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
    
    func TTNumberInputKeyboardDidDismiss() {
        numberInputView.saveValue(numberInputView.value, forKey: "distanceLapse-distance")
    }
}

extension DistanceLapseViewController: CLLocationManagerDelegate {
    
    
    // MARK: - Location Manager Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
            
        case CLAuthorizationStatus.NotDetermined:
            manager.startUpdatingLocation()
            break
            
        case CLAuthorizationStatus.Restricted:
            updateInterfaceForUnknownLocation()
            break
            
        case CLAuthorizationStatus.Denied:
            updateInterfaceForUnknownLocation()
            break
            
        case CLAuthorizationStatus.AuthorizedAlways:
            
            if let location = manager.location where location.GPSSignalStrength() == 0 {
                updateInterfaceForUnknownLocation()
                sequenceManager.cancel()
            } else {
                manager.startUpdatingLocation()
            }
            
            break
            
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            
            if let location = manager.location {
                if location.GPSSignalStrength() == 0 {
                    updateInterfaceForUnknownLocation()
                    sequenceManager.cancel()
                } else {
                    manager.startUpdatingLocation()
                }
            } else {
                manager.startUpdatingLocation()
            }
            
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        let moved = Float(newLocation.distanceFromLocation(oldLocation))
        
        if moved < 0.0 {
            return
        }
        
        if moved > 10000.0 {
            resetDistance()
            return
        }
        
        if locationAccuracy != newLocation.horizontalAccuracy {
            locationAccuracy = newLocation.horizontalAccuracy
            updateDistanceDisplay()
            return
        }
        
        distanceElapsed += moved
        
        if distanceElapsed >= interval {
            distanceElapsed = Float(lroundf(distanceElapsed) % lroundf(interval))
            
            // Assign delegates
            prepareForSequence()
            // Trigger the camera
            sequenceManager.play(Sequence(modules: [Pulse(time: Time(duration: settingsManager.pulseLength.doubleValue, unit: .Milliseconds))]), repeatSequence: false)
            numberOfShotsTaken += 1
        }
        
        distanceRemaining = interval - distanceElapsed
        
        updateDistanceDisplay()
    }
         
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
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
