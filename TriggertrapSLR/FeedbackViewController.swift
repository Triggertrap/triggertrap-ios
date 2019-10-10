//
//  FeedbackViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 19/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit
import TTCounterLabel

class FeedbackViewController: UIViewController, TTCounterLabelDelegate, TTCircleTimerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var counterLabel: TTCounterLabel?
    @IBOutlet var circleTimer: TTCircleTimer?
    
    // Bramping/Star Trail/LE HDR/LE HDR Timelapse
    
    @IBOutlet var exposureLabel: UILabel?
    @IBOutlet var exposureCounterLabel: TTCounterLabel?
    @IBOutlet var pauseLabel: UILabel?
    @IBOutlet var pauseCounterLabel: TTCounterLabel?
    @IBOutlet var shotsTakenLabel: UILabel?
    
    // Timelapse / Timewarp (use elapsed label for next)
    
    @IBOutlet var elapsedLabel: UILabel?
    @IBOutlet var elapsedCounterLabel: TTCounterLabel?
    
    @IBOutlet var infoLabel: UILabel?
    @IBOutlet var feedbackPanel: UIView?
    
    //Distance Lapse
    
    @IBOutlet var circularSlider: TTCircularSlider?
    
    @IBOutlet var untilLabel: UILabel?
    @IBOutlet var sinceLabel: UILabel?
    @IBOutlet var speedLabel: UILabel?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.triggertrap_primaryColor(1.0)
        
        counterLabel?.boldFont = UIFont.triggertrap_openSans_bold(55.0)
        counterLabel?.regularFont = UIFont.triggertrap_openSans_regular(55.0)
        counterLabel?.font = UIFont.triggertrap_openSans_regular(25.0)
        
        exposureCounterLabel?.boldFont = UIFont.triggertrap_openSans_bold(17.0)
        exposureCounterLabel?.regularFont = UIFont.triggertrap_openSans_regular(17.0)
        exposureCounterLabel?.font = UIFont.triggertrap_openSans_regular(13.0)
        
        pauseCounterLabel?.boldFont = UIFont.triggertrap_openSans_bold(17.0)
        pauseCounterLabel?.regularFont = UIFont.triggertrap_openSans_regular(17.0)
        pauseCounterLabel?.font = UIFont.triggertrap_openSans_regular(13.0)
        
        elapsedCounterLabel?.boldFont = UIFont.triggertrap_openSans_bold(17.0)
        elapsedCounterLabel?.regularFont = UIFont.triggertrap_openSans_regular(17.0)
        elapsedCounterLabel?.font = UIFont.triggertrap_openSans_regular(13.0) 
        
        performThemeUpdate()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *){
            performThemeUpdate()
        }
    }
    
    func performThemeUpdate() {
        self.view.backgroundColor = UIColor.triggertrap_primaryColor()
        
        feedbackPanel?.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_primaryColor(), change: 0.2)
        
        counterLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        counterLabel?.updateApperance()
        
        circleTimer?.trackTintColor = UIColor.triggertrap_trackTintColor(1.0)
        circleTimer?.progressTintColor = UIColor.triggertrap_fillColor(1.0)
        
        exposureCounterLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        exposureCounterLabel?.updateApperance()
        
        pauseLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        pauseCounterLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        pauseCounterLabel?.updateApperance()
        
        elapsedCounterLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        elapsedCounterLabel?.updateApperance()
        
        exposureLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        elapsedLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        
        infoLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        untilLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        sinceLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        speedLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        
        shotsTakenLabel?.textColor = UIColor.triggertrap_fillColor(1.0)
        
        circularSlider?.minimumTrackTintColor = UIColor.triggertrap_color(UIColor.triggertrap_primaryColor(), change: 0.2)
        circularSlider?.maximumTrackTintColor = UIColor.triggertrap_naturalColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startAnimations() {
        circleTimer?.start()
        counterLabel?.start()
        elapsedCounterLabel?.start()
    }
    
    func stopAnimations() {
        circleTimer?.stop()
        
        counterLabel?.stop()
        counterLabel?.reset()
        
        elapsedCounterLabel?.stop()
        elapsedCounterLabel?.reset()
        
        exposureCounterLabel?.stop()
        pauseCounterLabel?.stop()
    }
    
    func resumeAnimations() {
        
        if ((circleTimer?.indeterminate) != nil) {
            circleTimer?.indeterminate = 1
        }
        
        circleTimer?.layer.layoutIfNeeded()
        circleTimer?.layer.setNeedsDisplay()
    } 
    
    // MARK: - TTCounterLabelDelegate
    
    func countdownDidEnd(forSource source: TTCounterLabel!) {
        //
    }
    
    // MARK: - TTCircleTimerDelegate
    
    func progressComplete() {
        //
    }
    
}
