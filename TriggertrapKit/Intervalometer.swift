//
//  Intervalometer.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//
/**
Unwrappable module, combination of specific pattern of modules:
MirrorLockup(optional) -> Pulse -> Delay
*/

enum IntervalometerErrorType: ErrorType {
    case LessThanMinDelay,
    NoMinDelay
}

public struct Intervalometer: Unwrappable {
    
    public let name = "Intervalometer"
    public let time: Time
    public let type: UnwrappableType = .Intervalometer
    
    public var completionHandler: CompletionHandler = { (success) -> Void in }
    public var modules: [Modular]
    public var currentModule: Int
    
    private let mirrorLockup: MirrorLockup?
    private let pulse: Pulse
    private let delay: Delay
    
    /**
    - parameter time: total duration of the intervalometer module
    - parameter mirrorlockup(optional): module which requires pulse and delay
    - parameter pulse: module during which the audio buffer stays active
    */
    public init(time: Time, mirrorLockup: MirrorLockup?, pulse: Pulse) {
        
        self.time = time
        self.pulse = pulse
        self.mirrorLockup = mirrorLockup
        self.currentModule = 0
        
        let mirrorLockupDuration = mirrorLockup?.durationInMilliseconds() ?? 0
        let delayInMilliseconds = time.durationInMilliseconds - mirrorLockupDuration - pulse.time.durationInMilliseconds
        
        // Check whether the delay that is left at the end of the Intervalometer satisfies the minimum delay of the sequence manager
        if delayInMilliseconds > SequenceManager.sharedInstance.minDelay.time.durationInMilliseconds {
            self.delay = Delay(time: Time(duration: delayInMilliseconds, unit: .Milliseconds))
            self.modules = [self.mirrorLockup!, self.pulse, self.delay]
        } else {
            // Stop the Sequence and inform the user that their settings are unacceptable
            SequenceManager.sharedInstance.unwrappableDelegate?.failedToUnwrap(IntervalometerErrorType.LessThanMinDelay)
            self.modules = [Modular]()
            self.delay = Delay(time: Time(duration: 0, unit: .Milliseconds))
//            fatalError("Warning - pulse & mirrorlockup combined duration is greater than the intervalometer duration!")
        }
    }
}