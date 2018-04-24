//
//  Modular.swift
//  Triggertrap
//
//  Created by Valentin Kalchev on 02/07/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

public typealias CompletionHandler = (_ success: Bool) -> Void

public protocol Modular: class {
    var name: String { get }
    var completionHandler: CompletionHandler { get set }
    
    /** Unwraps the module
    - parameter completionHandler: informs whether the module has been unwrapped successfully
    */
    func unwrap(_ completionHandler:@escaping (_ success: Bool) -> Void)
    
    /** 
    Informs that the module has been unwrapped
    */
    func didUnwrap()
    
    /**
    Gets the total duration of the module
    - returns: duration in milliseconds as Double
    */
    func durationInMilliseconds() -> Double
}
