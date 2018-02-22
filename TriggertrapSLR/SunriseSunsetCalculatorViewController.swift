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
    
    private enum DayTimeStatus : Int {
        case DayTime = 0,
        NightTime = 1
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
    
    private var nextAstronomicalDateForFirstLight: NSDate!
    private var nextAstronomicalDateForLastLight: NSDate!
    private var nextAstronomicalDateForSunrise: NSDate!
    private var nextAstronomicalDateForSunset: NSDate!
    
    private var hasAstronomicalDatePassedForSunrise = false
    private var hasAstronomicalDatePassedForSunset = false
    
    //Location Manager
    
    private var locationManager: CLLocationManager!
    private var calculator: SunriseSunsetCalculator!
    
    //Timer
    
    private var displayTimer: NSTimer!
    private var startTime: CFAbsoluteTime!
    private var absoluteTimeSunrise: CFAbsoluteTime!
    private var absoluteTimeSunset: CFAbsoluteTime!
    private var timeRemainingUntilSunrise: CFAbsoluteTime!
    private var timeRemainingUntilSunset: CFAbsoluteTime!
    
    private var _displayedAlert: Bool!
    
    //Sun Animation
    
    private var initialSunAnimationDone: Bool!
    private var isSunAnimating: Bool!
    private var isDayTimeStatusChanging: Bool!
    
    private var oneDegreeAbsoluteTime: CFAbsoluteTime!
    private var absoluteTimeBetweenSunriseAndSunset: CFAbsoluteTime!
    
    private var degrees: Int = 0
    private var dayTimeStatus: DayTimeStatus!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isSunAnimating = false
        isDayTimeStatusChanging = false
        
        registerForNotifications()
        
        layoutRatio = ["top": (1.0 / 2.0), "bottom": (1.0 / 2.0)]
        updateSunConstraint()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        _displayedAlert = false
        initialSunAnimationDone = false
        
        createEmptyUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshLocationServices()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.dayTimeStatus != nil {
            switch self.dayTimeStatus.rawValue {
            case DayTimeStatus.DayTime.rawValue:
                //Arc line y will be equal to the white view center
                lineVerticalConstraint.constant = 0;
                break
                
            case DayTimeStatus.NightTime.rawValue:
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeLocationManager()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        stopTimer()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        stopTimer()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        
        removeLocationManager()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Notifications
    
    func updateTodayTomorrow() {
        titleLabelTop.text =  NSLocalizedString("Sunrise Today", comment: "Sunrise Today")
        titleLabelBottom.text = NSLocalizedString("Sunset Tonight", comment: "Sunset Tonight")
    }
    
    func startLocationManager() {
        
        if locationManager != nil {
            initialSunAnimationDone = false
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
    }
    
    private func removeLocationManager() {
        
        if locationManager != nil {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            locationManager = nil
        }
        
        stopTimer()
    }
    
    
    // MARK: - Private
    
    private func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SunriseSunsetCalculatorViewController.startLocationManager), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SunriseSunsetCalculatorViewController.stopLocationManager), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SunriseSunsetCalculatorViewController.updateTodayTomorrow), name: UIApplicationSignificantTimeChangeNotification, object: nil)
    }
    
    private func createEmptyUI() {
        
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
    
    private func astronomicalTime() {
        
        nextAstronomicalDateForFirstLight = calculator.nextAstronomicalDateFor(AstronomicalType.FirstLight.rawValue)
        nextAstronomicalDateForLastLight = calculator.nextAstronomicalDateFor(AstronomicalType.LastLight.rawValue)
        nextAstronomicalDateForSunrise = calculator.nextAstronomicalDateFor(AstronomicalType.Sunrise.rawValue)
        nextAstronomicalDateForSunset = calculator.nextAstronomicalDateFor(AstronomicalType.Sunset.rawValue)
        
        hasAstronomicalDatePassedForSunrise = calculator.hasAstronomicalDatePassedWithType(AstronomicalType.Sunrise.rawValue)
        hasAstronomicalDatePassedForSunset = calculator.hasAstronomicalDatePassedWithType(AstronomicalType.Sunset.rawValue)
    }
    
    private func createGreyViewContent() {
        
        if hasAstronomicalDatePassedForSunrise && !hasAstronomicalDatePassedForSunset {
            self.dayTimeStatus = DayTimeStatus.DayTime
        } else {
            self.dayTimeStatus = DayTimeStatus.NightTime
        }
        
        if self.dayTimeStatus == DayTimeStatus.NightTime {
            
            //Check if sunrise and sunset have passed, if yes - Sunrise and Sunset will be tomorrow
            if hasAstronomicalDatePassedForSunrise && hasAstronomicalDatePassedForSunset {
                titleLabelTop.text = NSLocalizedString("Sunrise Tomorrow", comment: "Sunrise Tomorrow")
                titleLabelBottom.text = NSLocalizedString("Sunset Tomorrow", comment: "Sunset Tomorrow")
            } else {
                titleLabelTop.text = NSLocalizedString("Sunrise Today", comment: "Sunrise Today")
                titleLabelBottom.text = NSLocalizedString("Sunset Tonight", comment: "Sunset Tonight")
            }
    
            //Get next sunrise time
            timeLabelTop.text = getDateAsString(nextAstronomicalDateForSunrise, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle) as String
            
            //Get next first light time
            let firstLight = getDateAsString(nextAstronomicalDateForFirstLight, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)

            lightTimeLabelTop.text = String(format: NSLocalizedString("First light at %@", comment: "First light at %@"), firstLight)
                
            //Get next sunset time
            timeLabelBottom.text = getDateAsString(nextAstronomicalDateForSunset, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle) as String
            
            //Get next last light time
            let lastLight = getDateAsString(nextAstronomicalDateForLastLight, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            
            lightTimeLabelBottom.text = String(format: NSLocalizedString("Last light at %@", comment: "Last light at %@"), lastLight)
        } else {
            //Set title for Sunset - because next one is today do not add Next
            titleLabelTop.text = NSLocalizedString("Sunset Tonight", comment: "Sunset Tonight")
            
            //Get next sunset time
            timeLabelTop.text = getDateAsString(nextAstronomicalDateForSunset, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle) as String
            
            //Get next last light time
            let lastLight = getDateAsString(nextAstronomicalDateForLastLight, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            
            lightTimeLabelTop.text = String(format: NSLocalizedString("Last light at %@", comment: "Last light at %@"), lastLight)
            
            //Set title for sunrise - because the next one is tomorrow add Next
            titleLabelBottom.text = NSLocalizedString("Sunrise Tomorrow", comment: "Sunrise Tomorrow")
            
            //Get next sunrise time
            timeLabelBottom.text = getDateAsString(nextAstronomicalDateForSunrise, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle) as String
            
            //Get next first light time
            let firstLight = getDateAsString(nextAstronomicalDateForFirstLight, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            
            lightTimeLabelBottom.text = String(format: NSLocalizedString("First light at %@", comment: "First light at %@"), firstLight)
        }
    }
    
    private func createWhiteViewContent() {
        
        switch self.dayTimeStatus.rawValue {
        case DayTimeStatus.DayTime.rawValue:
            print("Day time")
            break
            
        case DayTimeStatus.NightTime.rawValue:
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
        var hoursAndMinutesForSunset: NSArray = hoursAndMinutesForDate(calculator.astronomicalDateFor(NSDate(), withType: AstronomicalType.Sunset.rawValue))
        var hoursAndMinutesForLastLight: NSArray = hoursAndMinutesForDate(calculator.astronomicalDateFor(NSDate(), withType: AstronomicalType.LastLight.rawValue))
        
        
        sunImageView.image = (self.dayTimeStatus == DayTimeStatus.NightTime) ? ImageWithColor(UIImage(named: "solarCalculatorGreySun")!, color: UIColor.triggertrap_foregroundColor()) : ImageWithColor(UIImage(named: "solarCalculatorRedSun")!, color: UIColor.triggertrap_primaryColor())
        
        arcImageView.image = (self.dayTimeStatus == DayTimeStatus.NightTime) ? ImageWithColor(UIImage(named: "solarCalculatorArcFlipped")!, color: UIColor.triggertrap_foregroundColor()) : ImageWithColor(UIImage(named: "solarCalculatorArc")!, color: UIColor.triggertrap_foregroundColor())
        
        lineVerticalConstraint.constant = (self.dayTimeStatus == DayTimeStatus.NightTime) ? arcImageView.frame.size.height / 2 : 0
        
        // Move the arc below the line if it has been flipped
        arcToLineConstraint.constant = (self.dayTimeStatus == DayTimeStatus.NightTime) ? -arcImageView.frame.size.height : 0
        
        print("\(arcToLineConstraint.constant)")
        
        switch self.dayTimeStatus.rawValue {
        case DayTimeStatus.DayTime.rawValue:
            hoursAndMinutesForSunrise = hoursAndMinutesForDate(calculator.astronomicalDateFor(NSDate(), withType: AstronomicalType.Sunrise.rawValue))
            hoursAndMinutesForFirstLight = hoursAndMinutesForDate(calculator.astronomicalDateFor(NSDate(), withType: AstronomicalType.FirstLight.rawValue))
            
            if !isSunAnimating && !isDayTimeStatusChanging {
                sunView.transform = CGAffineTransformMakeRotation(degreesToRadians(0))
            }
            
            // Today sunrise and sunset as sun is in the middle of them
            absoluteTimeSunriseForAnimation = (calculator.astronomicalDateFor(NSDate(), withType: AstronomicalType.Sunrise.rawValue)).timeIntervalSinceReferenceDate
            absoluteTimeSunsetForAnimation = (calculator.astronomicalDateFor(NSDate(), withType: AstronomicalType.Sunset.rawValue)).timeIntervalSinceReferenceDate
            
            // Sun current time minus the sunrise time as animation will commit from Sunrice
            sunTime = NSDate().timeIntervalSinceReferenceDate - absoluteTimeSunriseForAnimation
            
            //Get the absolute time by taking the sunrise time from the sunset time as the sunrise is in the past and sunset is in the future
            absoluteTimeBetweenSunriseAndSunset = absoluteTimeSunsetForAnimation - absoluteTimeSunriseForAnimation;
            
            //Degrees are calculated from 0 up to 180 during day time, device sun time by absolute time multiplied by 180
            degrees = Int(sunTime / absoluteTimeBetweenSunriseAndSunset * 180)
            
            break
            
        case DayTimeStatus.NightTime.rawValue:
            
            //Get times for the labels on the graph
            hoursAndMinutesForSunrise = hoursAndMinutesForDate(nextAstronomicalDateForSunrise)
            hoursAndMinutesForFirstLight = hoursAndMinutesForDate(nextAstronomicalDateForFirstLight)
            
            //Start sunView rotation from 180 degrees
            if (!isSunAnimating && !isDayTimeStatusChanging) {
                sunView.transform = CGAffineTransformMakeRotation(degreesToRadians(180))
            }
            
            absoluteTimeSunsetForAnimation = calculator.astronomicalDateFor(NSDate(), withType: AstronomicalType.Sunset.rawValue).timeIntervalSinceReferenceDate
            
            //Next sunrise and sunset as both last day sunrise and sunset have passed
            absoluteTimeSunriseForAnimation = nextAstronomicalDateForSunrise.timeIntervalSinceReferenceDate
            
            //Date has updated (passed 24 hours, sunset will have greater value than sunrise), therefore get the absolute sunset value for last night
            if (absoluteTimeSunsetForAnimation > absoluteTimeSunriseForAnimation) {
                
                let calendar: NSCalendar = NSCalendar.currentCalendar()
                
                let components: NSDateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: NSDate())
                
                //Increment todays day with 1
                components.day = components.day - 1
                
                hoursAndMinutesForSunset = hoursAndMinutesForDate(calculator.astronomicalDateFor(calendar.dateFromComponents(components), withType: AstronomicalType.Sunset.rawValue))
                
                hoursAndMinutesForLastLight = hoursAndMinutesForDate(calculator.astronomicalDateFor(calendar.dateFromComponents(components), withType: AstronomicalType.LastLight.rawValue))
                
                absoluteTimeSunsetForAnimation = calculator.astronomicalDateFor(calendar.dateFromComponents(components), withType: AstronomicalType.Sunset.rawValue).timeIntervalSinceReferenceDate
            }
            
            //Sun current time minus the sunset time as animation will commit from Sunset
            sunTime = NSDate().timeIntervalSinceReferenceDate - absoluteTimeSunsetForAnimation
            
            //Get the absolute time by taking the sunset time from the sunrise time as the sunset is in the past and sunrise is in the future
            absoluteTimeBetweenSunriseAndSunset = absoluteTimeSunriseForAnimation - absoluteTimeSunsetForAnimation
            
            //Degrees are calculated from 180 to 360 degrees, sun starts its animation from 180.
            degrees = Int((sunTime / absoluteTimeBetweenSunriseAndSunset) * 180 + 180);
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
        
        sunriseDiagramLabel.text = String(format: "%02d:%02d", hoursAndMinutesForSunrise[0].integerValue, hoursAndMinutesForSunrise[1].integerValue)
        sunsetDiagramLabel.text = String(format: "%02d:%02d", hoursAndMinutesForSunset[0].integerValue, hoursAndMinutesForSunset[1].integerValue)
        firstLightDiagramLabel.text = String(format: "%02d:%02d", hoursAndMinutesForFirstLight[0].integerValue, hoursAndMinutesForFirstLight[1].integerValue)
        lastLightDiagramLabel.text = String(format: "%02d:%02d", hoursAndMinutesForLastLight[0].integerValue, hoursAndMinutesForLastLight[1].integerValue)
        
        isDayTimeStatusChanging = false
    }
    
    private func refreshLocationServices() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 500.0
            
            if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
                locationManager.requestWhenInUseAuthorization()
            } 

            updateCalculator()
        }
    }
    
    private func retrieveCity() {
        
        if let locationManager = locationManager, location = locationManager.location {
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                if let placemarks = placemarks {
                    for i in 0..<placemarks.count {
                        let placemark = placemarks[i]
                        
                        if let locality = placemark.locality, country = placemark.country {
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
    
    private func getDateAsString(date: NSDate, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> NSString {
        
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: dateStyle, timeStyle: timeStyle);
    }
    
    private func updateCalculator() {
        
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
    
    private func degreesToRadians(degreesToConvert: Int) -> CGFloat {
        return CGFloat(Double(degreesToConvert) / 180.0 * M_PI)
    }
    
    private func hoursAndMinutesForDate(date: NSDate) -> NSArray {
        var array: NSArray
        
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        let components: NSDateComponents = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: date)
        
        var hour: NSNumber = NSNumber(integer: components.hour)
        let minute: NSNumber = NSNumber(integer: components.minute)
        
        if !is24hSettingsOn() {
            if hour.intValue > 12 {
                let hourInt = hour.intValue - 12
                hour = NSNumber(int: hourInt)
            }
        }
        
        array = [hour, minute]
        return array
    }
    
    private func is24hSettingsOn() -> Bool {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let dateString: NSString = formatter.stringFromDate(NSDate())
        
        let amRange: NSRange = dateString.rangeOfString(formatter.AMSymbol)
        let pmRange: NSRange = dateString.rangeOfString(formatter.PMSymbol)
        
        let is24h: Bool = amRange.location == NSNotFound && pmRange.location == NSNotFound
        
        return is24h
    }
    
    // MARK: - Animations
    
    private func animateSunWithDuration(duration: Int, delay: Int, objectDegrees: Int) {
        
        if !isSunAnimating {
            
            UIView.animateWithDuration(NSTimeInterval(duration), animations: { () -> Void in
                self.isSunAnimating = true
                self.sunView.transform = CGAffineTransformMakeRotation(self.degreesToRadians(objectDegrees))
                self.updateSunConstraint()
                }, completion: { (finished: Bool) -> Void in
                    if (finished) {
                        self.isSunAnimating = false
                        self.initialSunAnimationDone = true
                    }
            })
        }
    }
    
    private func updateSunConstraint() {
        self.sunToCenterConstraint.constant = self.whiteView.frame.size.width / 2 - self.sunriseDiagramLabel.frame.origin.x - self.sunriseDiagramLabel.frame.size.width - self.sunImageView.frame.size.width / 2.0 - self.sunRotationCenterView.frame.size.width / 2.0
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        
        stopTimer()
        
        startTime = CFAbsoluteTimeGetCurrent()
        
        displayTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SunriseSunsetCalculatorViewController.timerFired(_:)), userInfo: nil, repeats: true)
        
        absoluteTimeSunrise = nextAstronomicalDateForSunrise.timeIntervalSinceReferenceDate
        absoluteTimeSunset = nextAstronomicalDateForSunset.timeIntervalSinceReferenceDate
    }
    
    private func stopTimer() {
        
        if displayTimer != nil {
            displayTimer.invalidate()
            displayTimer = nil
        }
    }
    
    private func updateDisplay(elapsedTime: CFAbsoluteTime) {
        
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
        
        timeRemainingLabelTop.text = self.dayTimeStatus == DayTimeStatus.NightTime ?
            NSString(fromTimeInterval: timeRemainingUntilSunrise, format: NSLocalizedString("In %@", comment: "In %@"), compact: false, decimal: false) as String
            : NSString(fromTimeInterval: timeRemainingUntilSunset, format: NSLocalizedString("In %@", comment: "In %@"), compact: false, decimal: false) as String
        
        timeRemainingLabelBottom.text = self.dayTimeStatus == DayTimeStatus.NightTime ?
            NSString(fromTimeInterval: timeRemainingUntilSunset, format: NSLocalizedString("In %@", comment: "In %@"), compact: false, decimal: false) as String
            : NSString(fromTimeInterval: timeRemainingUntilSunrise, format: NSLocalizedString("In %@", comment: "In %@"), compact: false, decimal: false) as String
    }
    
    func timerFired(timer: NSTimer) {
        let elapsedTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent() - startTime
        updateDisplay(elapsedTime)
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case CLAuthorizationStatus.NotDetermined:
            
            if CLLocationManager.locationServicesEnabled() {
                manager.startUpdatingLocation()
            } else {
                updateInterfaceForUnknownLocation()
            }

            break
            
        case CLAuthorizationStatus.Restricted:
            updateInterfaceForUnknownLocation()
            break
        
        case CLAuthorizationStatus.Denied:
            updateInterfaceForUnknownLocation()
            break
        
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            
            if let location = manager.location {
                
                // This application is authorized to use location services
                if (location.GPSSignalStrength() == 0) {
                    updateInterfaceForUnknownLocation()
                } else {
                    manager.startUpdatingLocation()
                }
            } else {
                manager.startUpdatingLocation()
            }

            break
            
        case CLAuthorizationStatus.AuthorizedAlways:
            
            if let location = manager.location {
                
                // This application is authorized to use location services
                if location.GPSSignalStrength() == 0 {
                    updateInterfaceForUnknownLocation()
                } else {
                    manager.startUpdatingLocation()
                }
            } else {
                manager.startUpdatingLocation()
            }
            
            break 
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateCalculator()
    }
    
    private func updateInterfaceForUnknownLocation() {
        
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