//
//  Delay.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public struct Delay: Dispatchable {
    
    public let name = "Delay"
    public let type: DispatchableType
    public let time: Time
    
    public var completionHandler: CompletionHandler = { (success) -> Void in }
    
    public init(time: Time) {
        self.time = time
        self.type = .Delay 
    }
}