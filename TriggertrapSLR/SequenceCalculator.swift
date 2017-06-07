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
    
    func starTrailSequenceForExposures(expCount: Int, pulse: Pulse, delay: Delay) -> Sequence {
        
        var modules = [Modular](count: expCount * 2 - 1, repeatedValue: Pulse(time: Time(duration: 0, unit: .Milliseconds)))
        
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
    
    func hdrSequenceForExposures(var expCount: Int, midExpDuration: Double, evStep: Double, interval: Double) -> Sequence {
        if expCount % 2 != 1 {
            expCount++
        }
        
        var modules = [Modular](count: expCount * 2, repeatedValue: Pulse(time: Time(duration: 0, unit: .Milliseconds)))
        
        var j = 0
        let step = (expCount - 1) / 2
        
        for var index = -step; index <= step; index++ {
            let exposure = (pow(pow(2, evStep), Double(index)) * midExpDuration)
            modules[j] = Pulse(time: Time(duration: exposure, unit: .Milliseconds))
            modules[j + 1] = Delay(time: Time(duration: MinimumGapBetweenHDRExposures, unit: .Milliseconds))
            
            j += 2
        }
        
        if interval > 0 {
            let time = durationForModulesInMilliseconds(modules)
            
            if time >= interval {
                modules[modules.count - 1] = Delay(time: Time(duration: time - interval + MinimumGapBetweenHDRExposures, unit: .Milliseconds))
            } else {
                modules[modules.count - 1] = Delay(time: Time(duration: interval - time + MinimumGapBetweenHDRExposures, unit: .Milliseconds))
            }
        }
        
        return Sequence(modules: modules)
    }
    
    func timeForSequence(sequence: [Double]) -> Double{
        let expCount = sequence.count / 2
        
        var time = 0.0
        
        for index in 0..<expCount {
            time += sequence[index*2]
            time += sequence[(index*2)+1]
        }
        
        return time
    } 
    
    func durationForModulesInMilliseconds(modules: [Modular]) -> Double {
        var duration = 0.0
        
        for module in modules {
            duration += module.durationInMilliseconds()
        }
        
        return duration
    }
    
    func maximumNumberOfExposuresForMinumumExposure(minExposure: Double, midExposure: Double, evStep: Double) -> Int {
        var minimumExp = 0.0
        
        for var index = 19; index > 1; index-=2 {
            minimumExp = minimumExposureForHDRExposures(index, midExposure: midExposure, evStep: evStep)
            
            if minimumExp >= minExposure {
                return index
            }
        }
        
        return 0
    }
    
    func minimumExposureForHDRExposures(expCount: Int, midExposure: Double, evStep: Double) -> Double {
        let num: Double = Double(-(expCount - 1) / 2)
        return pow(pow(2, evStep), num) * midExposure
    }
    
    // MARK: - Bramping Calculations
    
    func brampingSequenceForExposures(expCount: Int, firstExposure: Double, lastExposure: Double, interval: Double) -> Sequence {
        var modules = [Modular](count: expCount * 2, repeatedValue: Pulse(time: Time(duration: 0, unit: .Milliseconds)))
        
        for var index = 0; index < expCount; index++ {
            let fraction = Double(index) / Double(expCount - 1)
            let exposure = fraction * (lastExposure - firstExposure) + firstExposure
            
            modules[index * 2] = Pulse(time: Time(duration: exposure, unit: .Milliseconds))
            modules[index * 2 + 1] = Delay(time: Time(duration: interval - exposure, unit: .Milliseconds))
        }
        
        return Sequence(modules: modules)
    }
    
    // MARK: - TimeWarp Calculations
    
    func timeWarpSequenceForExposures(expCount: Int,  duration: Double, pulseLength: Double, minimumGap: Double, interpolator: CubicBezierInterpolator) -> Sequence {
        let pauses: [Double] = interpolator.pausesForExposures(Int32(expCount), sequenceDuration: Int(duration), pulseLength: Int(pulseLength), minimumGapBetweenPulses: Int(minimumGap)) as! [Double]
        
        var modules = [Modular](count: expCount * 2, repeatedValue: Pulse(time: Time(duration: 0, unit: .Milliseconds)))
        
        for index in 0..<expCount {
            modules[index * 2] = Pulse(time: Time(duration: pulseLength, unit: .Milliseconds))
            
            if index < pauses.count {
                if pauses[index] >= minimumGap {
                    modules[index * 2 + 1] = Delay(time: Time(duration: pauses[index], unit: .Milliseconds))
                } else {
                    modules[index * 2 + 1] = Delay(time: Time(duration: minimumGap, unit: .Milliseconds))
                }
            }
        }
        
        return Sequence(modules: modules)
    }
}