//
//  Unwrappable.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 08/07/2015.
//  Copyright © 2015 Triggertrap Limited. All rights reserved.
//

public protocol Unwrappable: Modular {
    
    var modules: [Modular] { get set }
    var currentModule: Int { get set }
    var type: UnwrappableType { get }
    
    func nextModule()
    func unwrapModule()
}

extension Unwrappable {
    
    // MARK: - Public
    
    public func unwrap(_ completionHandler: @escaping CompletionHandler) -> Void {
        self.completionHandler = completionHandler
        
        if SequenceManager.sharedInstance.isCurrentlyTriggering {
            // Inform the modules lifecycle protocol subscriber that the current module will be unwrapped
            onMain {
                //SequenceManager.sharedInstance.unwrappableDelegate?.willUnwrap(self)
            }
            
            unwrapModule()
        } else {
            self.completionHandler(false)
        }
    }
    
    public func unwrapModule() {
        
        if currentModule > self.modules.count - 1 {
            self.didUnwrap()
        } else {
            self.modules[currentModule].unwrap({ (success) -> Void in 
                success ? self.nextModule() : self.completionHandler(false)
            })
        }
    }
    
    public func nextModule() {
        
        self.currentModule += 1
        
        if SequenceManager.sharedInstance.isCurrentlyTriggering {
            unwrapModule()
        } else {
            self.completionHandler(false)
        }
    }
    
    public func didUnwrap() {
        
        // Inform the modules lifecycle protocol subscriber that the current module was unwrapped
        onMain {
            SequenceManager.sharedInstance.unwrappableDelegate?.didUnwrap(self)
        }
        
        self.completionHandler(true)
    }
    
    public func durationInMilliseconds() -> Double {
        var duration = 0.0
        
        for module in modules {
            duration += module.durationInMilliseconds()
        }
        
        return duration
    }
}
