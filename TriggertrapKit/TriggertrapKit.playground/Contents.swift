import UIKit

// MARK: - Time

protocol Symbol {
    var symbol: String { get }
}

enum Unit: Symbol {
    
    // TODO: Can this be improved?
    
    case Milliseconds
    case Seconds
    case Minutes
    case Hours
    case Days
    
    var symbol: String {
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

struct Time {
    
    // TODO: - Is Double the best type to be used (CUnsignedLongLong)?
    
    let duration: Double
    let unit: Unit
    
    init(duration: Double, unit: Unit) {

        // TODO: - Make sure that duration is always positive, otherwise throw an error
        self.duration = duration
        self.unit = unit
    }
    
    var durationInMilliseconds: Double {
        get {
            switch unit {
                case .Milliseconds: return duration
                case .Seconds: return duration * 1000
                case .Minutes: return duration * 1000 * 60
                case .Hours: return duration * 1000 * 60 * 60
                case .Days: return duration * 1000 * 60 * 60 * 24
            }
        }
    }
    
    var durationInSeconds: Double {
        get {
            return durationInMilliseconds / 1000
        }
    }
    
    var durationInMinutes: Double {
        get {
            return durationInSeconds / 60
        }
    }
    
    var durationInHours: Double {
        get {
            return durationInMinutes / 60
        }
    }
    
    var durationInDays: Double {
        get {
            return durationInHours / 24
        }
    }
    
    func symbol() -> String {
        return unit.symbol
    }
}

// MARK: - Output Handler

final class OutputDispatcher {
    static let sharedInstance = OutputDispatcher()
    
    var activeDispatchers: [Dispatcher]?
}

// MARK: - Dispatchers

protocol Dispatcher {
    func dispatch(dispatchable: Dispatchable)
}

struct WifiDispatcher: Dispatcher {
    func dispatch(dispatchable: Dispatchable) {
        
        if let pulse = dispatchable as? Pulse {
            println("Will dispatch pulse with duration: \(pulse.time.durationInMilliseconds)")
            sleep(UInt32(pulse.time.durationInMilliseconds))
        }
        
        if let delay = dispatchable as? Delay {
            println("Will dispatch pulse with delay: \(delay.time.durationInMilliseconds)")
            sleep(UInt32(delay.time.durationInMilliseconds))
        }
    }
}

struct DongleDispatcher: Dispatcher {
    func dispatch(dispatchable: Dispatchable) {
        
        if let pulse = dispatchable as? Pulse {
            println("Will dispatch pulse with duration: \(pulse.time.durationInMilliseconds)")
            sleep(UInt32(pulse.time.durationInMilliseconds))
        }
        
        if let delay = dispatchable as? Delay {
            println("Will dispatch pulse with delay: \(delay.time.durationInMilliseconds)")
            sleep(UInt32(delay.time.durationInMilliseconds))
        }
    }
}

// TODO - Write dispatchers here

// MARK: - Dispatchable

protocol Dispatchable: Modular {
    var time: Time { get }
    func dispatchWithDispatcher(dispatcher: Dispatcher)
}

struct Pulse: Dispatchable {
    let time: Time
    
    func dispatchWithDispatcher(dispatcher: Dispatcher) {
        dispatcher.dispatch(self)
    }
    
    func unwrap() {
        // TODO: - Swift 2.0, this can go in the unwrap() of the Dispatchable extension and get removed from the Pulse and Delay
        println("Unwrapping Pulse with duration \(self.time.durationInMilliseconds)")
        
        if let activeDispatchers = OutputDispatcher.sharedInstance.activeDispatchers {
            for dispatcher in activeDispatchers {
                dispatchWithDispatcher(dispatcher)
            }
        }
    }
}

struct Delay: Dispatchable {
    let time: Time
    
    func dispatchWithDispatcher(dispatcher: Dispatcher) {
        dispatcher.dispatch(self)
    }
    
    func unwrap() {
        // TODO: - Swift 2.0, this can go in the unwrap() of the Dispatchable extension and get removed from the Pulse and Delay
        println("Unwrapping Delay with duration \(self.time.durationInMilliseconds)")
        
        if let activeDispatchers = OutputDispatcher.sharedInstance.activeDispatchers {
            for dispatcher in activeDispatchers {
                dispatchWithDispatcher(dispatcher)
            }
        }
    }
}

// MARK: - Modular

protocol Modular {
    func unwrap()
}

struct Intervalometer: Modular {
    let time: Time
    let pulse: Pulse
    let mirrorLockup: MirrorLockup?
    
    private var delay: Delay = Delay(time: Time(duration: 150, unit: .Milliseconds))
    
    init(time: Time, pulse: Pulse, mirrorLockup: MirrorLockup?) {
        self.time = time
        self.pulse = pulse
        self.mirrorLockup = mirrorLockup
    }
    
    func unwrap() {
        println("Unwrapping Intervalometer")
        
        if self.time.durationInMilliseconds < pulse.time.durationInMilliseconds {
            println("Warning - pulse duration is greater than the intervalometer duration!")
            // TODO: - Interval duration is less than the pulse duration - show warning message to the user
            return
        } else {
            
            // |/| MirrorLockup Pulse?| MirrorLockup Delay?| Pulse | Delay |/|
            
            if let mirrorLockup = mirrorLockup {
                
                if self.time.durationInMilliseconds < (pulse.time.durationInMilliseconds + mirrorLockup.durationInMilliseconds()) {
                    println("Warning - pulse & mirrorlockup combined duration is greater than the intervalometer duration!")
                    // TODO: - Interval duration is less than the pulse duration and the mirror lockup duration - show warning message to the user
                    return
                }
                
                mirrorLockup.unwrap()
            }
            
            pulse.unwrap()
        }
    }
}

struct MirrorLockup: Modular {
    let pulse: Pulse
    let delay: Delay
    
    func unwrap() {
        SequenceHandler.sharedInstance.activeModule = self
        println("Unwrapping MirrorLockup")
        pulse.unwrap()
        delay.unwrap()
    }
    
    /*
    * Return the total duration of the mirror lockup in milliseconds
    */
    func durationInMilliseconds() -> Double {
        return pulse.time.durationInMilliseconds + delay.time.durationInMilliseconds
    }
}

struct Repeats: Modular {
    let modules: [Modular]
    let count: Int
    
    func unwrap() {
        print("Unwrapping Repeat module. Repeating \(count) times!")
        
        // TODO: - Unwrap the repeat modules one by one
        
        for index in 0..<count {
            println("Count: \(index)")
            for module in modules {
                module.unwrap()
            }
        }
    }
}

// MARK: - Sequence

struct Sequence {
    let modules: [Modular]
}

class SequenceHandler {
    static let sharedInstance = SequenceHandler()
    var activeModule: Modular?
}

// Set active dispatchers
OutputDispatcher.sharedInstance.activeDispatchers = [WifiDispatcher(), DongleDispatcher()]

// Pulse & Delay example
let pulse = Pulse(time: Time(duration: 1.0, unit: .Days))
pulse.time.durationInMilliseconds

let delay = Delay(time: Time(duration: 3.0, unit: .Milliseconds))

// MirrorLockup example
let mirrorLockupPulse = Pulse(time: Time(duration: 1.0, unit: .Milliseconds))
let mirrorLockupDelay = Delay(time: Time(duration: 2.0, unit: .Milliseconds))
let mirrorLockup = MirrorLockup(pulse: mirrorLockupPulse, delay: mirrorLockupDelay)

// Intervalometer example
let intervalometer = Intervalometer(time: Time(duration: 10.0, unit: Unit.Milliseconds), pulse: pulse, mirrorLockup: mirrorLockup)

// Repeat example
let repeat = Repeats(modules: [intervalometer], count: 5)

// Sequence example
let sequence = Sequence(modules: [repeat, intervalometer])

for module in sequence.modules {
    module.unwrap()
}
