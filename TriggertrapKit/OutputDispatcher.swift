//
//  OutputDispatcher.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
// 

public class OutputDispatcher {
    public static let sharedInstance = OutputDispatcher()
    
    public var activeDispatchers: [Dispatcher]?
    
    public let audioPlayer = AudioPlayer.sharedInstance()
}