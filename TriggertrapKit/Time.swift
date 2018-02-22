//
//  Time.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public struct Time {
    
    fileprivate let duration: Double
    fileprivate let unit: Unit
    
    // MARK: Lifecycle
    
    public init(duration: Double, unit: Unit) {
        
        // TODO: - Make sure that duration is always positive, otherwise throw an error
        self.duration = duration
        self.unit = unit
    }
    
    // MARK: Public 
    
    public var durationInMilliseconds: Double {
        get {
            switch unit {
                case .milliseconds: return duration
                case .seconds: return duration * MillisecondsPerSecond
                case .minutes: return duration * MillisecondsPerMinute
                case .hours: return duration * MillisecondsPerHour
                case .days: return duration * MillisecondsPerDay
            }
        }
    }
    
    public var durationInSeconds: Double {
        get {
            return durationInMilliseconds / MillisecondsPerSecond
        }
    }
    
    public var durationInMinutes: Double {
        get {
            return durationInSeconds / SecondsInMinute
        }
    }
    
    public var durationInHours: Double {
        get {
            return durationInMinutes / MinutesInHour
        }
    }
    
    public var durationInDays: Double {
        get {
            return durationInHours / HoursInDay
        }
    }
    
    public func symbol() -> String {
        return unit.symbol
    }
}
