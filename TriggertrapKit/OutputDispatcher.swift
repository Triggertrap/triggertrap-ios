//
//  OutputDispatcher.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
// 

open class OutputDispatcher {
    open static let sharedInstance = OutputDispatcher()
    
    open var activeDispatchers: [Dispatcher]?
    
    open let audioPlayer = AudioPlayer.sharedInstance()
}
