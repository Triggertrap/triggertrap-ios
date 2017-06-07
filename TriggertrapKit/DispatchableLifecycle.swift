//
//  DispatchableLifecycle.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 06/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public protocol DispatchableLifecycle {
    /**
    Notify that the dispatchable will be dispatched.
    */
    func willDispatch(dispatchable: Dispatchable)
    
    /**
    Notify that the dispatchable has been dispatched.
    */
    func didDispatch(dispatchable: Dispatchable)
}
