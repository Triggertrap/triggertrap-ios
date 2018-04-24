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
    @objc optional func didPlaySequence()
    
    /**
    Notify that the sequence has been paused.
    */
    @objc optional func didPauseSequence()
    
    /**
    Notify that the sequence has been resumed.
    */
    @objc optional func didResumeSequence()
    
    /**
    Notify that the sequence has been cancelled.
    */
    @objc optional func didCancelSequence()
    
    /**
    Use to get the total time elapsed from the sequence after each dispatchable execution. Duration is returned in milliseconds.
    */
    @objc optional func didElapseTime(_ milliseconds: Double)
    
    /**
    Notify that the sequence has successfully finished executing.
    */
    @objc optional func didFinishSequence()
}
