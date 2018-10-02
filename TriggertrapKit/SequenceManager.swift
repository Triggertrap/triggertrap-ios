//
//  SequenceManager.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

func onMain(_ block: @escaping ()->()) {
    DispatchQueue.main.async(execute: block)
}

open class SequenceManager {
    public static let sharedInstance = SequenceManager()
    
    // Delagate for informing the subscribed classes/structures/enums about the progress of the unwrappables (mirrorlockup/intervalometer/repeat)
    open var unwrappableDelegate: UnwrappableLifecycle?
    
    // Delagate for informing the subscribed classes/structures/enums about the progress of the dispatchables (pulse/delay)
    open var dispatchableDelegate: DispatchableLifecycle?
    
    // Delagate for informing the subscribed classes/structures/enums about the progress of the sequence
    open var sequenceDelegate: SequenceLifecycle?
    
    // Minimum delay for intervalometer
    open var minDelay: Delay!
    
    // Counts the progress of the sequence since it was started
    internal var timeElapsed: Time!
    
    open var activeViewController: AnyObject? {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = activeViewController != nil ? true : false
        }
    }
    
    // Checks whether the sequence is triggerable
    var isCurrentlyTriggering: Bool {
        get {
            return isTriggering
        }
    }
    
    fileprivate var isTriggering: Bool!
    fileprivate var sequence: Sequence!
    fileprivate var repeatSequence = false
    
    fileprivate init() {
        isTriggering = false
        sequence = Sequence(modules: [])
        minDelay = Delay(time: Time(duration: 150, unit: .milliseconds))
        timeElapsed = Time(duration: 0, unit: .milliseconds)
    }
    
    fileprivate var currentModule = 0
    
    // MARK: - Public
    
    /** Plays the sequence of modules from the available dispatchers
    - parameter sequence: group of modules to be unwrapped
    */
    
    open func play(_ sequence: Sequence, repeatSequence: Bool) {
        
        // If it is currently triggering - return
        if isCurrentlyTriggering {
            return
        }
        
        self.sequence = sequence
        self.repeatSequence = repeatSequence
        self.currentModule = 0
        
        isTriggering = true
        timeElapsed = Time(duration: 0, unit: .milliseconds)
        
        unwrapSequence(sequence)
        self.sequenceDelegate?.didPlaySequence?()
    }
    
    /**
     Cancels the sequence of modules that is currently being played
     */
    open func cancel() {
        
        // Inform the class that has subscribed to the SequenceLifecycle protocol that the sequence has been canceled
        self.sequenceDelegate?.didCancelSequence?()
        
        // Stop the sequence
        stopSequence()
        
    }
    
    // MARK: - Private
    
    fileprivate func unwrapSequence(_ sequence: Sequence) {
        
        if self.isCurrentlyTriggering {
            
            // Check if current index is less than the total count of all modules in the sequence
            if self.currentModule < self.sequence.modules.count {
                
                // Check that current modules is a dispatchable
                guard let dispatchable = self.sequence.modules[self.currentModule] as? Dispatchable else {
                    print("Module is not a dispatchable!")
                    return
                }
                
                // Inform the active view controller that a dispatchable will dispatch
                self.dispatchableDelegate?.willDispatch(dispatchable)
                
                // Unwrap the dispatchable
                self.sequence.modules[self.currentModule].unwrap({ (success) -> Void in
                    if success {
                        // Inform the active view controller that the dispatchable has ended its execution
                        onMain {
                            self.dispatchableDelegate?.didDispatch(dispatchable)
                            self.currentModule += 1
                            self.unwrapSequence(sequence)
                        }
                    } else {
                        // Cancel the sequence execution
                        onMain {
                            self.cancel()
                        }
                    }
                })
                
                // Repeat the sequence execution
            } else if self.repeatSequence {
                self.currentModule = 0
                self.unwrapSequence(sequence)
            } else {
                // Sequence has finished executing
                self.isTriggering = false
                self.sequenceDelegate?.didFinishSequence?()
            }
        }
    }
    
    fileprivate func stopSequence() { 
        
        self.isTriggering = false
        // Stop TTAudio player.
        // Note: This will execute the audioPlayerlDidFinishPlayingAudio() from the AudioPlayerDelegate and all subscribed classes to it.
        OutputDispatcher.sharedInstance.audioPlayer?.stopAudio()
        PreciseTimer.removeAllScheduledEvents()
    }
}
