//
//  Repeat.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

/**
Unwrappable module, combination of modules which can get repeated multiple times.
*/
public struct Repeat: Unwrappable {
    
    public let name = "Repeat"
    public let repeatCount: Int
    public let type: UnwrappableType
    
    public var modules: [Modular]
    public var currentModule: Int
    public var completionHandler: CompletionHandler = { (success) -> Void in }
    
    public var currentRepeatCount: Int 
    
    /**
    - parameter modules: modules to be executed by the repeat module
    - parameter repeatCount: number of times the modules have to be executed after the first time. Pass '0' to execute once.
    */
    public init(modules: [Modular], repeatCount: Int) {
        self.modules = modules
        self.repeatCount = repeatCount
        self.currentModule = 0
        self.currentRepeatCount = 0 
        self.type = .Repeat
    }
    
    public mutating func unwrapModule() {
        
        // Check if the current module index is greated than the modules count
        if currentModule > self.modules.count - 1 {
            
            // Increment the repeat count
            currentRepeatCount += 1
            
            // Check if the repeat count is greater than the total repeat module counts
            if currentRepeatCount > repeatCount {
                
                // Repeat module did unwrap
                didUnwrap()
            } else {
                
                // Reset the current module and start unwrapping from the beginning of the modules array
                currentModule = 0
                unwrapModule()
            }
        } else {
            self.modules[currentModule].unwrap({ (success) -> Void in
                success ? self.nextModule() : self.completionHandler(success: false)
            })
        }
    }
    
    public func durationInMilliseconds() -> Double {
        var duration = 0.0
        
        for module in modules {
            duration += module.durationInMilliseconds()
        }
        
        return duration * Double(repeatCount + 1)
    }
}

