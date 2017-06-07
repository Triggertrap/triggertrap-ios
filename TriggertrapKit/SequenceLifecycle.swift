//
//  SequenceLifecycle.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 15/07/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

@objc public protocol SequenceLifecycle {
    /**
    Notify that the sequence has been started.
    */
    optional func didPlaySequence()
    
    /**
    Notify that the sequence has been paused.
    */
    optional func didPauseSequence()
    
    /**
    Notify that the sequence has been resumed.
    */
    optional func didResumeSequence()
    
    /**
    Notify that the sequence has been cancelled.
    */
    optional func didCancelSequence()
    
    /**
    Use to get the total time elapsed from the sequence after each dispatchable execution. Duration is returned in milliseconds.
    */
    optional func didElapseTime(milliseconds: Double)
    
    /**
    Notify that the sequence has successfully finished executing.
    */
    optional func didFinishSequence()
}
