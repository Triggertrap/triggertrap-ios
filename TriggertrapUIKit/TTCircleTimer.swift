//
//  TTCircleTimer.swift
//  TriggertrapSLR
//
//  Created by Alex Taffe on 4/21/18.
//  Copyright © 2018 Triggertrap Limited. All rights reserved.
//

import RPCircularProgress

class TTCircleTimer: RPCircularProgress {
    
    var delegate: TTCircleTimerDelegate?
    var cycleDuration: TimeInterval?
    var progressDirection: TTCircleTimerProgressDirection?
    var continuous: Bool
    var isRunning: Bool
    
    private var running = false
    private var startTime: Double?
    private var clockTime: Timer?
    
    var indeterminate: CFTimeInterval{
        get {
            return self.indeterminateDuration
        }
        set(newValue){
            self.indeterminateDuration = newValue
        }
    }
    
    public required init(){
        self.continuous = true
        self.isRunning = false
        super.init()
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.continuous = true
        self.isRunning = false
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){

        self.tintColor = UIColor(displayP3Red: 165.0/255.0, green: 22.0/255.0, blue: 16.0/255.0, alpha: 1.0)
        self.progressTintColor = UIColor.white
        self.backgroundColor = UIColor.clear
        self.thicknessRatio = 0.02
        self.roundedCorners = true
        self.clockwiseProgress = true
        self.indeterminateDuration = 1
        
        self.cycleDuration = 1
        self.progressDirection = .Clockwise
        self.continuous = true
        self.isRunning = false
    }
    
    func start(){
        guard !self.running else {
            return
        }
        
        if self.progressDirection == .AntiClockwise{
            self.updateProgress(1.0)
        } else {
            self.updateProgress(0.0)
        }
        self.startTime = CFAbsoluteTimeGetCurrent()
        
        self.clockTime = Timer(timeInterval: 0.02, target: self, selector: #selector(self.clockDidTick(timer:)), userInfo: nil, repeats: true)
        
        RunLoop.main.add(self.clockTime!, forMode: RunLoop.Mode.common)
        
        self.running = true
        self.isRunning = true
        
    }
    
    func stop(){
        if let timer = self.clockTime{
            timer.invalidate()
            self.clockTime = nil
        }
        if self.progressDirection == .AntiClockwise{
            self.updateProgress(1.0)
        } else {
            self.updateProgress(0.0)
        }
        
        self.running = false
        self.isRunning = false
    }
    
    func `repeat`(){
        if self.progressDirection == .AntiClockwise{
            self.updateProgress(1.0)
        } else {
            self.updateProgress(0.0)
        }
        
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    @objc func clockDidTick(timer: Timer){
        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentTime - self.startTime!
        let cycle = self.cycleDuration!
        
        if self.progressDirection == .AntiClockwise{
            let progress = 1.0 - CGFloat(elapsedTime / cycle)
            self.updateProgress(progress)
            
            if self.continuous && progress <= 0.0 {
                self.repeat()
            } else if progress <= 0.0 {
                self.delegate?.progressComplete?()
            }
        } else {
            let progress = CGFloat(elapsedTime / cycle)
            self.updateProgress(progress)
            if self.continuous && progress >= 1.0{
                self.repeat()
            } else if progress >= 1.0 {
                self.delegate?.progressComplete?()
            }
        }
    }
}

enum TTCircleTimerProgressDirection {
    case Clockwise, AntiClockwise
}

@objc protocol TTCircleTimerDelegate:class {
    @objc optional func progressComplete()
}
