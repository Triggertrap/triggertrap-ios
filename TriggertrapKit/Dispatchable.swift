//
//  Dispatchable.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public protocol Dispatchable: Modular {
    var time: Time { get }
    var type: DispatchableType { get } 
}

extension Dispatchable {
    
    // MARK: - Public
    
    public mutating func unwrap(completionHandler: CompletionHandler) -> Void {
        self.completionHandler = completionHandler
        
        if SequenceManager.sharedInstance.isCurrentlyTriggering {
            // Inform the modules lifecycle protocol subscriber that the current module will be unwrapped
            unwrapWithDispatchers()
        } else {
            self.completionHandler(success: false)
        }
    }
    
    public func didUnwrap() {
        let timeElapsed = SequenceManager.sharedInstance.timeElapsed.durationInMilliseconds + self.time.durationInMilliseconds
        SequenceManager.sharedInstance.timeElapsed = Time(duration: timeElapsed, unit: .Milliseconds)
        SequenceManager.sharedInstance.sequenceDelegate?.didElapseTime?(timeElapsed) 
        
        self.completionHandler(success: true)
    }
    
    public func durationInMilliseconds() -> Double {
        return time.durationInMilliseconds
    }
    
    // MARK: - Internal
    
    internal func unwrapWithDispatchers() {
        
        
        if let activeDispatchers = OutputDispatcher.sharedInstance.activeDispatchers {
            
            for dispatcher in activeDispatchers {
                dispatcher.dispatch(self)
            }
        }
    }
}