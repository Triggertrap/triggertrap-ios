//
//  Unit.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
// 

public enum Unit: Symbol {
    case Milliseconds, Seconds, Minutes, Hours, Days
    
    public var symbol: String {
        get {
            switch self {
            case .Milliseconds:
                return "ms"
            case .Seconds:
                return "s"
            case .Minutes:
                return "m"
            case .Hours:
                return "h"
            case .Days:
                return "d"
            }
        }
    }
}