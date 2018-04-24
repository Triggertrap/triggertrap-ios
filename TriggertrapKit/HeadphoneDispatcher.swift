//
//  HeadphoneDispatcher.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

open class HeadphoneDispatcher: NSObject, Dispatcher {
    open static let sharedInstance = HeadphoneDispatcher()
    
    fileprivate var dispatchable: Dispatchable!
    
    fileprivate override init() {
        super.init()
    }
    
    open func dispatch(_ dispatchable: Dispatchable) {
        self.dispatchable = dispatchable
        
        OutputDispatcher.sharedInstance.audioPlayer?.start()
    
        switch dispatchable.type {
        case .Pulse:
            // Audio buffer is only precise for less than 15 seconds duration (less than 50ms discrepancy). Otherwise use the precise timer to get accurate duration.
            if dispatchable.time.durationInMilliseconds > Time(duration: 15, unit: .seconds).durationInMilliseconds {
                OutputDispatcher.sharedInstance.audioPlayer?.delegate = nil
                PreciseTimer.scheduleAction(#selector(HeadphoneDispatcher.didDispatchAudio), target: self, inTimeInterval: dispatchable.time.durationInSeconds)
                OutputDispatcher.sharedInstance.audioPlayer?.playAudio(forDuration: UInt64.max)
            } else {
                OutputDispatcher.sharedInstance.audioPlayer?.delegate = self
                OutputDispatcher.sharedInstance.audioPlayer?.playAudio(forDuration: UInt64(dispatchable.time.durationInMilliseconds))
            }
            
        case .Delay:
            OutputDispatcher.sharedInstance.audioPlayer?.delegate = nil
            PreciseTimer.scheduleAction(#selector(HeadphoneDispatcher.didDispatch), target: self, inTimeInterval: dispatchable.time.durationInSeconds)
        }
    }
    
    @objc func didDispatchAudio() {
        OutputDispatcher.sharedInstance.audioPlayer?.stop()
        self.didDispatch()
    }
    
    @objc func didDispatch() {
        if SequenceManager.sharedInstance.isCurrentlyTriggering {
            self.dispatchable.didUnwrap() 
        } 
    }
}

extension HeadphoneDispatcher: AudioPlayerDelegate {
    public func audioPlayerlDidFinishPlayingAudio() {
        self.didDispatch()
    }
}
