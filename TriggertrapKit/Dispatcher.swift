//
//  Dispatcher.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public protocol Dispatcher { 
    func dispatch(dispatchable: Dispatchable)
}