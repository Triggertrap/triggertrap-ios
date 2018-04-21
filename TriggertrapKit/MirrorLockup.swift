//
//  MirrorLockup.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

/**
Unwrappable module, combination of specific pattern of modules:
Pulse -> Delay
*/
public class MirrorLockup: Unwrappable {
    public /** Unwraps the module
     - parameter completionHandler: informs whether the module has been unwrapped successfully
     */
    func unwrap(_ completionHandler: (Bool) -> Void) {
        
    }

    
    public let name = "Mirror Lockup"
    public let type: UnwrappableType = .MirrorLockup
    
    public var modules: [Modular]
    public var currentModule: Int
    public var completionHandler: CompletionHandler = { (success) -> Void in }
    
    fileprivate let pulse: Pulse
    fileprivate let delay: Delay
    
    /**
    - parameter pulse: module during which the audio buffer stays active
    - parameter delay: module during which the audio buffer is inactive
    */
    public init(pulse: Pulse, delay: Delay) {
        self.pulse = pulse
        self.delay = delay
        self.modules = [self.pulse, self.delay]
        self.currentModule = 0
    } 
}

