//
//  SequenceManager.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

func onMain(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), block)
}

public class SequenceManager {
    public static let sharedInstance = SequenceManager()
    
    // Delagate for informing the subscribed classes/structures/enums about the progress of the unwrappables (mirrorlockup/intervalometer/repeat)
    public var unwrappableDelegate: UnwrappableLifecycle?
    
    // Delagate for informing the subscribed classes/structures/enums about the progress of the dispatchables (pulse/delay)
    public var dispatchableDelegate: DispatchableLifecycle?
    
    // Delagate for informing the subscribed classes/structures/enums about the progress of the sequence
    public var sequenceDelegate: SequenceLifecycle?
    
    // Minimum delay for intervalometer
    public var minDelay: Delay!
    
    // Counts the progress of the sequence since it was started
    internal var timeElapsed: Time!
    
    public var activeViewController: AnyObject? {
        didSet {
            UIApplication.sharedApplication().idleTimerDisabled = activeViewController != nil ? true : false
        }
    }
    
    // Checks whether the sequence is triggerable
    var isCurrentlyTriggering: Bool {
        get {
            return isTriggering
        }
    }
    
    private var isTriggering: Bool!
    private var sequence: Sequence!
    private var repeatSequence = false
    
    private init() {
        isTriggering = false
        sequence = Sequence(modules: [])
        minDelay = Delay(time: Time(duration: 150, unit: .Milliseconds))
        timeElapsed = Time(duration: 0, unit: .Milliseconds)
    }
    
    private var currentModule = 0
    
    // MARK: - Public
    
    /** Plays the sequence of modules from the available dispatchers
    - parameter sequence: group of modules to be unwrapped
    */
    
    public func play(sequence: Sequence, repeatSequence: Bool) {
        
        // If it is currently triggering - return
        if isCurrentlyTriggering {
            return
        }
        
        self.sequence = sequence
        self.repeatSequence = repeatSequence
        self.currentModule = 0
        
        isTriggering = true
        timeElapsed = Time(duration: 0, unit: .Milliseconds)
        
        unwrapSequence(sequence)
        self.sequenceDelegate?.didPlaySequence?()
    }
    
    /**
     Cancels the sequence of modules that is currently being played
     */
    public func cancel() {
        
        // Inform the class that has subscribed to the SequenceLifecycle protocol that the sequence has been canceled
        self.sequenceDelegate?.didCancelSequence?()
        
        // Stop the sequence
        stopSequence()
        
    }
    
    // MARK: - Private
    
    private func unwrapSequence(sequence: Sequence) {
        
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
    
    private func stopSequence() { 
        
        self.isTriggering = false
        // Stop TTAudio player.
        // Note: This will execute the audioPlayerlDidFinishPlayingAudio() from the AudioPlayerDelegate and all subscribed classes to it.
        OutputDispatcher.sharedInstance.audioPlayer.stopAudio()
        PreciseTimer.removeAllScheduledEvents()
    }
}