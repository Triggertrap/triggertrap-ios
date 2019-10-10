//
//  SunriseSunsetCalculatorViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 10/10/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//


import UIKit
import CoreLocation

class SunriseSunsetCalculatorViewController: SplitLayoutViewController, CLLocationManagerDelegate {
    
    fileprivate enum DayTimeStatus : Int {
        case dayTime = 0,
        nightTime = 1
    }
    
    @IBOutlet var whiteView: UIView!
    
    // Top View - Grey View
    
    @IBOutlet var titleLabelTop: UILabel!
    @IBOutlet var timeLabelTop: UILabel!
    @IBOutlet var timeRemainingLabelTop: UILabel!
    @IBOutlet var lightTimeLabelTop: UILabel!
    
    // Bottom View - Grey View
    
    @IBOutlet var titleLabelBottom: UILabel!
    @IBOutlet var timeLabelBottom: UILabel!
    @IBOutlet var timeRemainingLabelBottom: UILabel!
    @IBOutlet var lightTimeLabelBottom: UILabel!
    
    //Diagram View - White View
    
    @IBOutlet var firstLightDiagramLabel: UILabel!
    @IBOutlet var sunriseDiagramLabel: UILabel!
    @IBOutlet var sunsetDiagramLabel: UILabel!
    @IBOutlet var lastLightDiagramLabel: UILabel!
    
    @IBOutlet var sunToCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var sunView: UIView!
    
    @IBOutlet var arcImageView: UIImageView!
    
    @IBOutlet var lineVerticalConstraint: NSLayoutConstraint!
    @IBOutlet var arcToLineConstraint: NSLayoutConstraint!
    
    @IBOutlet var flatLineImageView: UIImageView!
    @IBOutlet var sunImageView: UIImageView!
    @IBOutlet var sunRotationCenterView: UIView!
    
    fileprivate var nextAstronomicalDateForFirstLight: Date!
    fileprivate var nextAstronomicalDateForLastLight: Date!
    fileprivate var nextAstronomicalDateForSunrise: Date!
    fileprivate var nextAstronomicalDateForSunset: Date!
    
    fileprivate var hasAstronomicalDatePassedForSunrise = false
    fileprivate var hasAstronomicalDatePassedForSunset = false
    
    //Location Manager
    
    fileprivate var locationManager: CLLocationManager!
    fileprivate var calculator: SunriseSunsetCalculator!
    
    //Timer
    
    fileprivate var displayTimer: Timer!
    fileprivate var startTime: CFAbsoluteTime!
    fileprivate var absoluteTimeSunrise: CFAbsoluteTime!
    fileprivate var absoluteTimeSunset: CFAbsoluteTime!
    fileprivate var timeRemainingUntilSunrise: CFAbsoluteTime!
    fileprivate var timeRemainingUntilSunset: CFAbsoluteTime!
    
    fileprivate var _displayedAlert: Bool!
    
    //Sun Animation
    
    fileprivate var initialSunAnimationDone: Bool!
    fileprivate var isSunAnimating: Bool!
    fileprivate var isDayTimeStatusChanging: Bool!
    
    fileprivate var oneDegreeAbsoluteTime: CFAbsoluteTime!
    fileprivate var absoluteTimeBetweenSunriseAndSunset: CFAbsoluteTime!
    
    fileprivate var degrees: Int = 0
    fileprivate var dayTimeStatus: DayTimeStatus!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isSunAnimating = false
        isDayTimeStatusChanging = false
        
        registerForNotifications()
        
        layoutRatio = ["top": (CGFloat(1.0 / 2.0)), "bottom": (CGFloat(1.0 / 2.0))]
        updateSunConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _displayedAlert = false
        initialSunAnimationDone = false
        
        createEmptyUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshLocationServices()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.dayTimeStatus != nil {
            switch self.dayTimeStatus.rawValue {
            case DayTimeStatus.dayTime.rawValue:
                //Arc line y will be equal to the white view center
                lineVerticalConstraint.constant = 0;
                break
                
            case DayTimeStatus.nightTime.rawValue:
                //Arc sunrise/sunset line "y" will be move to the center of the space between the City Label and the top of the white view
                lineVerticalConstraint.constant = arcImageView.frame.size.height / 2
                
                //Moving the arc under the arc sunrise/sunset line
                arcToLineConstraint.constant = -arcImageView.frame.size.height
                break
                
            default:
                print("default")
                break
            }
        } else {
            lineVerticalConstraint.constant = 0;
        }
        
        self.topLeftView.layoutIfNeeded()
        updateSunConstraint()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeLocationManager()
        NotificationCenter.default.removeObserver(self)
        stopTimer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopTimer()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        removeLocationManager()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notifications
    
    @objc func updateTodayTomorrow() {
        titleLabelTop.text =  NSLocalizedString("Sunrise Today", comment: "Sunrise Today")
        titleLabelBottom.text = NSLocalizedString("Sunset Tonight", comment: "Sunset Tonight")
    }
    
    @objc func startLocationManager() {
        
        if locationManager != nil {
            initialSunAnimationDone = false
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func stopLocationManager() {
        locationManager.stopUpdatingLocation()
    }
    
    fileprivate func removeLocationManager() {
        
        if locationManager != nil {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            locationManager = nil
        }
        
        stopTimer()
    }
    
    
    // MARK: - Private
    
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SunriseSunsetCalculatorViewController.startLocationManager), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SunriseSunsetCalculatorViewController.stopLocationManager), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SunriseSunsetCalculatorViewController.updateTodayTomorrow), name: UIApplication.significantTimeChangeNotification, object: nil)
    }
    
    fileprivate func createEmptyUI() {
        
        //Grey View
        titleLabelTop.text = NSLocalizedString("Sunrise", comment: "Sunrise")
        timeLabelTop.text = "--:--"
        timeRemainingLabelTop.text = ""
        lightTimeLabelTop.text = "--:--"
        titleLabelBottom.text = NSLocalizedString("Sunset", comment: "Sunset")
        timeLabelBottom.text = "--:--"
        lightTimeLabelBottom.text = "--:--"
        cityLabel.text = ""
        
        //White view
        sunriseDiagramLabel.text = "--:--"
        sunsetDiagramLabel.text = "--:--"
        timeRemainingLabelBottom.text = ""
        firstLightDiagramLabel.text = "--:--"
        lastLightDiagramLabel.text = "--:--"
    }
    
    fileprivate func astronomicalTime() {
        
        nextAstronomicalDateForFirstLight = calculator.nextAstronomicalDate(for: AstronomicalType.firstLight.rawValue)
        nextAstronomicalDateForLastLight = calculator.nextAstronomicalDate(for: AstronomicalType.lastLight.rawValue)
        nextAstronomicalDateForSunrise = calculator.nextAstronomicalDate(for: AstronomicalType.sunrise.rawValue)
        nextAstronomicalDateForSunset = calculator.nextAstronomicalDate(for: AstronomicalType.sunset.rawValue)
        
        hasAstronomicalDatePassedForSunrise = calculator.hasAstronomicalDatePassed(withType: AstronomicalType.sunrise.rawValue)
        hasAstronomicalDatePassedForSunset = calculator.hasAstronomicalDatePassed(withType: AstronomicalType.sunset.rawValue)
    }
    
    fileprivate func createGreyViewContent() {
        
        if hasAstronomicalDatePassedForSunrise && !hasAstronomicalDatePassedForSunset {
            self.dayTimeStatus = DayTimeStatus.dayTime
        } else {
            self.dayTimeStatus = DayTimeStatus.nightTime
        }
        
        if self.dayTimeStatus == DayTimeStatus.nightTime {
            
            //Check if sunrise and sunset have passed, if yes - Sunrise and Sunset will be tomorrow
            if hasAstronomicalDatePassedForSunrise && hasAstronomicalDatePassedForSunset {
                titleLabelTop.text = NSLocalizedString("Sunrise Tomorrow", comment: "Sunrise Tomorrow")
                titleLabelBottom.text = NSLocalizedString("Sunset Tomorrow", comment: "Sunset Tomorrow")
            } else {
                titleLabelTop.text = NSLocalizedString("Sunrise Today", comment: "Sunrise Today")
                titleLabelBottom.text = NSLocalizedString("Sunset Tonight", comment: "Sunset Tonight")
            }
    
            //Get next sunrise time
            timeLabelTop.text = getDateAsString(nextAstronomicalDateForSunrise, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short) as String
            
            //Get next first light time
            let firstLight = getDateAsString(nextAstronomicalDateForFirstLight, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)

            lightTimeLabelTop.text = String(format: NSLocalizedString("First light at %@", comment: "First light at %@"), firstLight)
                
            //Get next sunset time
            timeLabelBottom.text = getDateAsString(nextAstronomicalDateForSunset, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short) as String
            
            //Get next last light time
            let lastLight = getDateAsString(nextAstronomicalDateForLastLight, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
            
            lightTimeLabelBottom.text = String(format: NSLocalizedString("Last light at %@", comment: "Last light at %@"), lastLight)
        } else {
            //Set title for Sunset - because next one is today do not add Next
            titleLabelTop.text = NSLocalizedString("Sunset Tonight", comment: "Sunset Tonight")
            
            //Get next sunset time
            timeLabelTop.text = getDateAsString(nextAstronomicalDateForSunset, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short) as String
            
            //Get next last light time
            let lastLight = getDateAsString(nextAstronomicalDateForLastLight, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
            
            lightTimeLabelTop.text = String(format: NSLocalizedString("Last light at %@", comment: "Last light at %@"), lastLight)
            
            //Set title for sunrise - because the next one is tomorrow add Next
            titleLabelBottom.text = NSLocalizedString("Sunrise Tomorrow", comment: "Sunrise Tomorrow")
            
            //Get next sunrise time
            timeLabelBottom.text = getDateAsString(nextAstronomicalDateForSunrise, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short) as String
            
            //Get next first light time
            let firstLight = getDateAsString(nextAstronomicalDateForFirstLight, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
            
            lightTimeLabelBottom.text = String(format: NSLocalizedString("First light at %@", comment: "First light at %@"), firstLight)
        }
    }
    
    fileprivate func createWhiteViewContent() {
        
        switch self.dayTimeStatus.rawValue {
        case DayTimeStatus.dayTime.rawValue:
            print("Day time")
            break
            
        case DayTimeStatus.nightTime.rawValue:
            print("Night time")
            break
        default:
            print("default")
            break
        }
        
        var absoluteTimeSunsetForAnimation: CFAbsoluteTime
        var absoluteTimeSunriseForAnimation: CFAbsoluteTime
        var sunTime: CFAbsoluteTime
        
        //DIAGRAM
        var hoursAndMinutesForFirstLight: NSArray!
        var hoursAndMinutesForSunrise: NSArray!
        var hoursAndMinutesForSunset: NSArray = hoursAndMinutesForDate(calculator.astronomicalDate(for: Date(), withType: AstronomicalType.sunset.rawValue))
        var hoursAndMinutesForLastLight: NSArray = hoursAndMinutesForDate(calculator.astronomicalDate(for: Date(), withType: AstronomicalType.lastLight.rawValue))
        
        
        sunImageView.image = (self.dayTimeStatus == DayTimeStatus.nightTime) ? ImageWithColor(UIImage(named: "solarCalculatorGreySun")!, color: UIColor.triggertrap_foregroundColor()) : ImageWithColor(UIImage(named: "solarCalculatorRedSun")!, color: UIColor.triggertrap_primaryColor())
        
        arcImageView.image = (self.dayTimeStatus == DayTimeStatus.nightTime) ? ImageWithColor(UIImage(named: "solarCalculatorArcFlipped")!, color: UIColor.triggertrap_foregroundColor()) : ImageWithColor(UIImage(named: "solarCalculatorArc")!, color: UIColor.triggertrap_foregroundColor())
        
        lineVerticalConstraint.constant = (self.dayTimeStatus == DayTimeStatus.nightTime) ? arcImageView.frame.size.height / 2 : 0
        
        // Move the arc below the line if it has been flipped
        arcToLineConstraint.constant = (self.dayTimeStatus == DayTimeStatus.nightTime) ? -arcImageView.frame.size.height : 0
        
        print("\(arcToLineConstraint.constant)")
        
        switch self.dayTimeStatus.rawValue {
        case DayTimeStatus.dayTime.rawValue:
            hoursAndMinutesForSunrise = hoursAndMinutesForDate(calculator.astronomicalDate(for: Date(), withType: AstronomicalType.sunrise.rawValue))
            hoursAndMinutesForFirstLight = hoursAndMinutesForDate(calculator.astronomicalDate(for: Date(), withType: AstronomicalType.firstLight.rawValue))
            
            if !isSunAnimating && !isDayTimeStatusChanging {
                sunView.transform = CGAffineTransform(rotationAngle: degreesToRadians(0))
            }
            
            // Today sunrise and sunset as sun is in the middle of them
            absoluteTimeSunriseForAnimation = (calculator.astronomicalDate(for: Date(), withType: AstronomicalType.sunrise.rawValue)).timeIntervalSinceReferenceDate
            absoluteTimeSunsetForAnimation = (calculator.astronomicalDate(for: Date(), withType: AstronomicalType.sunset.rawValue)).timeIntervalSinceReferenceDate
            
            // Sun current time minus the sunrise time as animation will commit from Sunrice
            sunTime = Date().timeIntervalSinceReferenceDate - absoluteTimeSunriseForAnimation
            
            //Get the absolute time by taking the sunrise time from the sunset time as the sunrise is in the past and sunset is in the future
            absoluteTimeBetweenSunriseAndSunset = absoluteTimeSunsetForAnimation - absoluteTimeSunriseForAnimation;
            
            //Degrees are calculated from 0 up to 180 during day time, device sun time by absolute time multiplied by 180
            degrees = Int(sunTime / absoluteTimeBetweenSunriseAndSunset * 180)
            
            break
            
        case DayTimeStatus.nightTime.rawValue:
            
            //Get times for the labels on the graph
            hoursAndMinutesForSunrise = hoursAndMinutesForDate(nextAstronomicalDateForSunrise)
            hoursAndMinutesForFirstLight = hoursAndMinutesForDate(nextAstronomicalDateForFirstLight)
            
            //Start sunView rotation from 180 degrees
            if (!isSunAnimating && !isDayTimeStatusChanging) {
                sunView.transform = CGAffineTransform(rotationAngle: degreesToRadians(180))
            }
            
            absoluteTimeSunsetForAnimation = calculator.astronomicalDate(for: Date(), withType: AstronomicalType.sunset.rawValue).timeIntervalSinceReferenceDate
            
            //Next sunrise and sunset as both last day sunrise and sunset have passed
            absoluteTimeSunriseForAnimation = nextAstronomicalDateForSunrise.timeIntervalSinceReferenceDate
            
            //Date has updated (passed 24 hours, sunset will have greater value than sunrise), therefore get the absolute sunset value for last night
            if (absoluteTimeSunsetForAnimation > absoluteTimeSunriseForAnimation) {
                
                let calendar: Calendar = Calendar.current
                
                var components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: Date())
                
                //Increment todays day with 1
                components.day = components.day! - 1
                
                hoursAndMinutesForSunset = hoursAndMinutesForDate(calculator.astronomicalDate(for: calendar.date(from: components), withType: AstronomicalType.sunset.rawValue))
                
                hoursAndMinutesForLastLight = hoursAndMinutesForDate(calculator.astronomicalDate(for: calendar.date(from: components), withType: AstronomicalType.lastLight.rawValue))
                
                absoluteTimeSunsetForAnimation = calculator.astronomicalDate(for: calendar.date(from: components), withType: AstronomicalType.sunset.rawValue).timeIntervalSinceReferenceDate
            }
            
            //Sun current time minus the sunset time as animation will commit from Sunset
            sunTime = Date().timeIntervalSinceReferenceDate - absoluteTimeSunsetForAnimation
            
            //Get the absolute time by taking the sunset time from the sunrise time as the sunset is in the past and sunrise is in the future
            absoluteTimeBetweenSunriseAndSunset = absoluteTimeSunriseForAnimation - absoluteTimeSunsetForAnimation
            
            //Degrees are calculated from 180 to 360 degrees, sun starts its animation from 180.
            let degreeCalculation = sunTime / absoluteTimeBetweenSunriseAndSunset * 180 //had to separate due to some swift compiler complexity bug
            degrees = Int(degreeCalculation + 180)
            break
            
        default:
            print("default")
            break
        }
        
        //Set one degree of time by deviding the difference between Sunrise and Sunset by 180
        oneDegreeAbsoluteTime = absoluteTimeBetweenSunriseAndSunset / 180
        
        if (!initialSunAnimationDone) {
            animateSunWithDuration(2, delay: 0, objectDegrees: degrees)
        }
        
        sunriseDiagramLabel.text = String(format: "%02d:%02d", (hoursAndMinutesForSunrise[0] as! NSNumber).intValue, (hoursAndMinutesForSunrise[1] as! NSNumber).intValue)
        sunsetDiagramLabel.text = String(format: "%02d:%02d", (hoursAndMinutesForSunset[0] as! NSNumber).intValue, (hoursAndMinutesForSunset[1] as! NSNumber).intValue)
        firstLightDiagramLabel.text = String(format: "%02d:%02d", (hoursAndMinutesForFirstLight[0] as! NSNumber).intValue, (hoursAndMinutesForFirstLight[1] as! NSNumber).intValue)
        lastLightDiagramLabel.text = String(format: "%02d:%02d", (hoursAndMinutesForLastLight[0] as! NSNumber).intValue, (hoursAndMinutesForLastLight[1] as! NSNumber).intValue)
        
        isDayTimeStatusChanging = false
    }
    
    fileprivate func refreshLocationServices() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 500.0
            
            if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                locationManager.requestWhenInUseAuthorization()
            } 

            updateCalculator()
        }
    }
    
    fileprivate func retrieveCity() {
        
        if let locationManager = locationManager, let location = locationManager.location {
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                if let placemarks = placemarks {
                    for i in 0..<placemarks.count {
                        let placemark = placemarks[i]
                        
                        if let locality = placemark.locality, let country = placemark.country {
                            self.cityLabel.text = "\(locality), \(country)"
                        } else if let country = placemark.country {
                            self.cityLabel.text = "\(country)"
                        } else if let locality = placemark.locality {
                            self.cityLabel.text = "\(locality)"
                        }
                    }
                }
            })
        }
    }
    
    fileprivate func getDateAsString(_ date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> NSString {
        
        return DateFormatter.localizedString(from: date, dateStyle: dateStyle, timeStyle: timeStyle) as NSString;
    }
    
    fileprivate func updateCalculator() {
        
        // Check if location has been picked up befor updating the UI
        if let location = locationManager.location {
            
            // Check if calculator already exists
            if calculator == nil {
                calculator = SunriseSunsetCalculator()
            }
            
            calculator.setCoordinates(location.coordinate)
            astronomicalTime()
            createGreyViewContent()
            createWhiteViewContent()
            retrieveCity()
            
            if displayTimer == nil {
                startTimer()
            }
        }
    }
    
    fileprivate func degreesToRadians(_ degreesToConvert: Int) -> CGFloat {
        return CGFloat(Double(degreesToConvert) / 180.0 * Double.pi)
    }
    
    fileprivate func hoursAndMinutesForDate(_ date: Date) -> NSArray {
        var array: NSArray
        
        let calendar: Calendar = Calendar.current
        
        let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: date)
        
        var hour: NSNumber = NSNumber(value: components.hour!)
        let minute: NSNumber = NSNumber(value: components.minute!)
        
        if !is24hSettingsOn() {
            if hour.int32Value > 12 {
                let hourInt = hour.int32Value - 12
                hour = NSNumber(value: hourInt as Int32)
            }
        }
        
        array = [hour, minute]
        return array
    }
    
    fileprivate func is24hSettingsOn() -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = DateFormatter.Style.short
        
        let dateString: NSString = formatter.string(from: Date()) as NSString
        
        let amRange: NSRange = dateString.range(of: formatter.amSymbol)
        let pmRange: NSRange = dateString.range(of: formatter.pmSymbol)
        
        let is24h: Bool = amRange.location == NSNotFound && pmRange.location == NSNotFound
        
        return is24h
    }
    
    // MARK: - Animations
    
    fileprivate func animateSunWithDuration(_ duration: Int, delay: Int, objectDegrees: Int) {
        
        if !isSunAnimating {
            
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                self.isSunAnimating = true
                self.sunView.transform = CGAffineTransform(rotationAngle: self.degreesToRadians(objectDegrees))
                self.updateSunConstraint()
                }, completion: { (finished: Bool) -> Void in
                    if (finished) {
                        self.isSunAnimating = false
                        self.initialSunAnimationDone = true
                    }
            })
        }
    }
    
    fileprivate func updateSunConstraint() {
        let diagramCalculations = self.arcImageView.frame.width / 2 - self.sunImageView.frame.width / 2 - self.flatLineImageView.frame.height / 10
        //deal with half pixels depending on the device's scale ratio
        let scale = UIScreen.main.scale
        self.sunToCenterConstraint.constant =  round(diagramCalculations - 1.0 / scale)
    }
    
    // MARK: - Timer
    
    fileprivate func startTimer() {
        
        stopTimer()
        
        startTime = CFAbsoluteTimeGetCurrent()
        
        displayTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SunriseSunsetCalculatorViewController.timerFired(_:)), userInfo: nil, repeats: true)
        
        absoluteTimeSunrise = nextAstronomicalDateForSunrise.timeIntervalSinceReferenceDate
        absoluteTimeSunset = nextAstronomicalDateForSunset.timeIntervalSinceReferenceDate
    }
    
    fileprivate func stopTimer() {
        
        if displayTimer != nil {
            displayTimer.invalidate()
            displayTimer = nil
        }
    }
    
    fileprivate func updateDisplay(_ elapsedTime: CFAbsoluteTime) {
        
        if initialSunAnimationDone == true {
            
            absoluteTimeBetweenSunriseAndSunset = absoluteTimeBetweenSunriseAndSunset - 1
            
            if Int(absoluteTimeBetweenSunriseAndSunset) % Int(oneDegreeAbsoluteTime) == 0 {
                degrees += 1
                animateSunWithDuration(1, delay: 0, objectDegrees: degrees)
            }
        }
        
        // Sunset
        
        if  (absoluteTimeSunset - startTime - elapsedTime) <= 0 {
            isDayTimeStatusChanging = true
            astronomicalTime()
            createGreyViewContent()
            createWhiteViewContent()
            absoluteTimeSunset = nextAstronomicalDateForSunset.timeIntervalSinceReferenceDate
        } else {
            timeRemainingUntilSunset = absoluteTimeSunset - (startTime + elapsedTime)
        }
        
        if (absoluteTimeSunrise - startTime - elapsedTime) <= 0 {
            isDayTimeStatusChanging = true
            astronomicalTime()
            createGreyViewContent()
            createWhiteViewContent()
            absoluteTimeSunrise = nextAstronomicalDateForSunrise.timeIntervalSinceReferenceDate
        } else {
            timeRemainingUntilSunrise = absoluteTimeSunrise - (startTime + elapsedTime)
        }
        
        timeRemainingLabelTop.text = self.dayTimeStatus == DayTimeStatus.nightTime ?
            NSString(fromTimeInterval: timeRemainingUntilSunrise, format: NSLocalizedString("In %@", comment: "In %@"), compact: false, decimal: false) as String
            : NSString(fromTimeInterval: timeRemainingUntilSunset, format: NSLocalizedString("In %@", comment: "In %@"), compact: false, decimal: false) as String
        
        timeRemainingLabelBottom.text = self.dayTimeStatus == DayTimeStatus.nightTime ?
            NSString(fromTimeInterval: timeRemainingUntilSunset, format: NSLocalizedString("In %@", comment: "In %@"), compact: false, decimal: false) as String
            : NSString(fromTimeInterval: timeRemainingUntilSunrise, format: NSLocalizedString("In %@", comment: "In %@"), compact: false, decimal: false) as String
    }
    
    @objc func timerFired(_ timer: Timer) {
        let elapsedTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent() - startTime
        updateDisplay(elapsedTime)
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case CLAuthorizationStatus.notDetermined:
            
            if CLLocationManager.locationServicesEnabled() {
                manager.startUpdatingLocation()
            } else {
                updateInterfaceForUnknownLocation()
            }

            break
            
        case CLAuthorizationStatus.restricted:
            updateInterfaceForUnknownLocation()
            break
        
        case CLAuthorizationStatus.denied:
            updateInterfaceForUnknownLocation()
            break
        
        case CLAuthorizationStatus.authorizedWhenInUse:
            
            if let location = manager.location {
                
                // This application is authorized to use location services
                if (location.gpsSignalStrength() == 0) {
                    updateInterfaceForUnknownLocation()
                } else {
                    manager.startUpdatingLocation()
                }
            } else {
                manager.startUpdatingLocation()
            }

            break
            
        case CLAuthorizationStatus.authorizedAlways:
            
            if let location = manager.location {
                
                // This application is authorized to use location services
                if location.gpsSignalStrength() == 0 {
                    updateInterfaceForUnknownLocation()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateCalculator()
    }
    
    fileprivate func updateInterfaceForUnknownLocation() {
        
        ShowAlertInViewController(self, title: NSLocalizedString("Where am I?", comment: "Where am I?"), message: NSLocalizedString("I don't know where I am... Are location services disabled, perhaps?", comment: "I don't know where I am... Are location services disabled, perhaps?"), cancelButton: NSLocalizedString("OK", comment: "OK")) 
        
        stopTimer()
        
        createEmptyUI()
        
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Theme
    
    override func performThemeUpdate() {
        super.performThemeUpdate()
        
        titleLabelTop.textColor = UIColor.triggertrap_foregroundColor()
        timeLabelTop.textColor = UIColor.triggertrap_primaryColor()
        timeRemainingLabelTop.textColor = UIColor.triggertrap_accentColor()
        lightTimeLabelTop.textColor = UIColor.triggertrap_accentColor()
        
        titleLabelBottom.textColor = UIColor.triggertrap_foregroundColor()
        timeLabelBottom.textColor = UIColor.triggertrap_primaryColor()
        timeRemainingLabelBottom.textColor = UIColor.triggertrap_accentColor()
        lightTimeLabelBottom.textColor = UIColor.triggertrap_accentColor()
        
        firstLightDiagramLabel.textColor = UIColor.triggertrap_foregroundColor()
        sunriseDiagramLabel.textColor = UIColor.triggertrap_foregroundColor()
        sunsetDiagramLabel.textColor = UIColor.triggertrap_foregroundColor()
        lastLightDiagramLabel.textColor = UIColor.triggertrap_foregroundColor()
        
        cityLabel.textColor = UIColor.triggertrap_accentColor()
        
        flatLineImageView.image = ImageWithColor(UIImage(named: "solarCalculatorFlatFill")!, color: UIColor.triggertrap_primaryColor())
        
        arcImageView.image = ImageWithColor(UIImage(named: "solarCalculatorArc")!, color: UIColor.triggertrap_foregroundColor())
        sunImageView.image = ImageWithColor(UIImage(named: "solarCalculatorRedSun")!, color: UIColor.triggertrap_primaryColor())
    }
}
