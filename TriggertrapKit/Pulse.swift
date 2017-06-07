//
//  Pulse.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public struct Pulse: Dispatchable {
    
    public let name = "Pulse"
    public let type: DispatchableType
    public let time: Time
    
    public var completionHandler: CompletionHandler = { (success) -> Void in }
    
    public init(time: Time) {
        self.time = time
        self.type = .Pulse
    }
}