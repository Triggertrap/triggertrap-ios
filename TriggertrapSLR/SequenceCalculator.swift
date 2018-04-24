//
//  SequenceCalculator.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 28/07/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

import Foundation

let MinimumGapBetweenHDRExposures = 1000.0
class SequenceCalculator {
    static let sharedInstance = SequenceCalculator()
    
    // MARK: - Startrail Calculations
    
    func starTrailSequenceForExposures(_ expCount: Int, pulse: Pulse, delay: Delay) -> Sequence {
        
        var modules = [Modular](repeating: Pulse(time: Time(duration: 0, unit: .milliseconds)), count: expCount * 2 - 1)
        
        for index in 0..<expCount {
            modules[index * 2] = pulse
            
            // Ignore the lase delay 
            if index != (expCount - 1) {
                modules[index * 2 + 1] = delay
            }
        }
        
        return Sequence(modules: modules)
    }
    
    // MARK: - HDR Calculations
    
    func hdrSequenceForExposures(_ expCount: Int, midExpDuration: Double, evStep: Double, interval: Double) -> Sequence {
        
        var modules = [Modular](repeating: Pulse(time: Time(duration: 0, unit: .milliseconds)), count: expCount * 2)
        
        var j = 0
        let step = (expCount - 1) / 2
        
        var index = -step
        
        while index <= step{
            let exposure = (pow(pow(2, evStep), Double(index)) * midExpDuration)
            modules[j] = Pulse(time: Time(duration: exposure, unit: .milliseconds))
            modules[j + 1] = Delay(time: Time(duration: MinimumGapBetweenHDRExposures, unit: .milliseconds))
            
            j += 2
            index += 1
        }
        
        if interval > 0 {
            let time = durationForModulesInMilliseconds(modules)
            
            if time >= interval {
                modules[modules.count - 1] = Delay(time: Time(duration: time - interval + MinimumGapBetweenHDRExposures, unit: .milliseconds))
            } else {
                modules[modules.count - 1] = Delay(time: Time(duration: interval - time + MinimumGapBetweenHDRExposures, unit: .milliseconds))
            }
        }
        
        return Sequence(modules: modules)
    }
    
    func timeForSequence(_ sequence: [Double]) -> Double{
        let expCount = sequence.count / 2
        
        var time = 0.0
        
        for index in 0..<expCount {
            time += sequence[index*2]
            time += sequence[(index*2)+1]
        }
        
        return time
    } 
    
    func durationForModulesInMilliseconds(_ modules: [Modular]) -> Double {
        var duration = 0.0
        
        for module in modules {
            duration += module.durationInMilliseconds()
        }
        
        return duration
    }
    
    func maximumNumberOfExposuresForMinumumExposure(_ minExposure: Double, midExposure: Double, evStep: Double) -> Int {
        var minimumExp = 0.0
        
        var index = 19
        
        while index > 1{
            minimumExp = minimumExposureForHDRExposures(index, midExposure: midExposure, evStep: evStep)
            
            if minimumExp >= minExposure {
                return index
            }
            
            index -= 2
        }
        
        return 0
    }
    
    func minimumExposureForHDRExposures(_ expCount: Int, midExposure: Double, evStep: Double) -> Double {
        let num: Double = Double(-(expCount - 1) / 2)
        return pow(pow(2, evStep), num) * midExposure
    }
    
    // MARK: - Bramping Calculations
    
    func brampingSequenceForExposures(_ expCount: Int, firstExposure: Double, lastExposure: Double, interval: Double) -> Sequence {
        var modules = [Modular](repeating: Pulse(time: Time(duration: 0, unit: .milliseconds)), count: expCount * 2)
        
        for index in 0..<expCount {
            let fraction = Double(index) / Double(expCount - 1)
            let exposure = fraction * (lastExposure - firstExposure) + firstExposure
            
            modules[index * 2] = Pulse(time: Time(duration: exposure, unit: .milliseconds))
            modules[index * 2 + 1] = Delay(time: Time(duration: interval - exposure, unit: .milliseconds))
        }
        
        return Sequence(modules: modules)
    }
    
    // MARK: - TimeWarp Calculations
    
    func timeWarpSequenceForExposures(_ expCount: Int,  duration: Double, pulseLength: Double, minimumGap: Double, interpolator: CubicBezierInterpolator) -> Sequence {
        let pauses: [Double] = interpolator.pauses(forExposures: Int32(expCount), sequenceDuration: Int(duration), pulseLength: Int(pulseLength), minimumGapBetweenPulses: Int(minimumGap)) as! [Double]
        
        var modules = [Modular](repeating: Pulse(time: Time(duration: 0, unit: .milliseconds)), count: expCount * 2)
        
        for index in 0..<expCount {
            modules[index * 2] = Pulse(time: Time(duration: pulseLength, unit: .milliseconds))
            
            if index < pauses.count {
                if pauses[index] >= minimumGap {
                    modules[index * 2 + 1] = Delay(time: Time(duration: pauses[index], unit: .milliseconds))
                } else {
                    modules[index * 2 + 1] = Delay(time: Time(duration: minimumGap, unit: .milliseconds))
                }
            }
        }
        
        return Sequence(modules: modules)
    }
}
