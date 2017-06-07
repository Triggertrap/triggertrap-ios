//
//  Sequence.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public struct Sequence {
    public var modules: [Modular]
    
    internal var currentModule: Int
    internal var completionHandler: CompletionHandler = { (success) -> Void in }
    
    // MARK: Lifecycle
    
    public init(modules: [Modular]) {
        self.modules = modules
        self.currentModule = 0
    } 
    
    // MARK: - Public
    
    func durationInMilliseconds() -> Double {
        var duration = 0.0
        
        for module in modules {
            duration += module.durationInMilliseconds()
        }
        
        return duration
    }
}
