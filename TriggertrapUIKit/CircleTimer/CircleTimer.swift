//
//  CircleTimer.swift
//  CircleTimer
//
//  Created by Valentin Kalchev on 09/10/2015.
//  Copyright © 2015 TriggertrapLtd. All rights reserved.
//

import UIKit

class CircleTimer: UIView {
    fileprivate var angle: CGFloat = 90
    fileprivate var startTime: Double!
    fileprivate var timer: Timer?
    
    var clockwise = false
    var progress: CGFloat = 0
    var nightTime = false
    var cycleDuration: Double = 1.0
    var continuous = true
    var indeterminate = false
    var lineThickness: CGFloat = 4.0 
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func start() {
        
        self.startTime = CFAbsoluteTimeGetCurrent();
        timer = Timer(timeInterval: 0.02, target: self, selector: #selector(CircleTimer.clockDidTick(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func clockDidTick(_ timer: Timer) {
      
        if !indeterminate {
            
            progress = CGFloat((CFAbsoluteTimeGetCurrent() - startTime) / self.cycleDuration)
            
            if progress > 1.0 {
                continuous ? repeatProcess() : stop()
            }
        } else {
            
            angle = -90 + CGFloat((CFAbsoluteTimeGetCurrent() - startTime) / self.cycleDuration) * 360
            angle = clockwise ? angle * -1 : angle
        }
        
        setNeedsDisplay()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        progress = 0
        angle = 90.0
        setNeedsDisplay()
    }
    
    func repeatProcess() {
        progress = 0
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    override func draw(_ rect: CGRect) {
        TimerStyleKit.drawCircleTimer(fraction: progress, clockwise: clockwise, angle: angle, size: rect.size, lineThickness: lineThickness, nightTime: nightTime)
    }
}
