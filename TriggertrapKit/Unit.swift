//
//  Unit.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
// 

public enum Unit: Symbol {
    case milliseconds, seconds, minutes, hours, days
    
    public var symbol: String {
        get {
            switch self {
            case .milliseconds:
                return "ms"
            case .seconds:
                return "s"
            case .minutes:
                return "m"
            case .hours:
                return "h"
            case .days:
                return "d"
            }
        }
    }
}
