//
//  UnwrappableLifecycle.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 06/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public protocol UnwrappableLifecycle {
    /**
    Notify that the unwrappable will be unwrapped.
    */
    func willUnwrap(unwrappable: Unwrappable)
    
    /**
    Failed to unwrap the unwrappable.
    */
    func failedToUnwrap(error: ErrorType)
    
    /**
    Notify that the unwrappable did unwrap.
    */
    func didUnwrap(unwrappable: Unwrappable)
}
