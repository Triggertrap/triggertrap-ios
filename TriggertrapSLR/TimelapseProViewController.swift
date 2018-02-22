//
//  TimelapseProViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 08/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class TimelapseProViewController: CenterViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tellMeMoreButton: BorderButton!
    @IBOutlet weak var viewInAppStoreButton: BorderButton!
    @IBOutlet weak var scrollButton: UIButton! 
    @IBOutlet weak var shimmeringView: FBShimmeringView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topGradientView: GradientOverlayView!
    @IBOutlet weak var bottomGradientView: GradientOverlayView!
    @IBOutlet weak var separatorView: UIView!
    
    private let buttonHeight: CGFloat = 44.0
    private let padding: CGFloat = 8
    
    private enum ActionSheetType {
        case TellMeMore,
        ViewInAppStore
    }
    
    private var actionSheetType: ActionSheetType?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        shimmeringView.contentView = scrollButton
        textView.text = NSLocalizedString("Triggertrap Timelapse Pro is a new approach to creating awesome timelapses. Connect your device to your camera with a Triggertrap Mobile kit, and you're set to get creative!\n\nTimelapse Pro has a modular approach to timelapse creation, letting you create sequences using the building blocks of timelapses - intervalometers and delays. With these blocks you can create timelapses of all shapes and sizes. Timelapse Pro's intervalometers allow you to set your interval between shots, as well as when you'd like the intervalometer to stop; either by the number of shots or after a set amount of time has passed.", comment: "Triggertrap Timelapse Pro is a new approach to creating awesome timelapses. Connect your device to your camera with a Triggertrap Mobile kit, and you're set to get creative!\n\nTimelapse Pro has a modular approach to timelapse creation, letting you create sequences using the building blocks of timelapses - intervalometers and delays. With these blocks you can create timelapses of all shapes and sizes. Timelapse Pro's intervalometers allow you to set your interval between shots, as well as when you'd like the intervalometer to stop; either by the number of shots or after a set amount of time has passed.")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        performThemeUpdate()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelapseProViewController.performThemeUpdate), name: ConstThemeHasBeenUpdated, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.flashScrollIndicators()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.view.bounds.height > self.view.bounds.width {
            scrollButton.hidden = true
            shimmeringView.shimmering = false
            previewHeightConstraint.constant = self.view.bounds.height / 2
            textViewHeightConstraint.constant = (self.view.frame.height / 2) - (3 * padding + 2 * buttonHeight)
        } else {
            scrollButton.hidden = false
            shimmeringView.shimmering = true
            previewHeightConstraint.constant = self.view.bounds.height
            textViewHeightConstraint.constant = SizeForText(textView.text, withFont: textView.font!, constrainedToSize: CGSize(width: textView.frame.width, height: 1000)).height + 2 * padding
        } 
        
        self.view.layoutSubviews()
        
        textView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    
    private func showActionSheet(rect: CGRect) {
        
        var openLinkTitle = ""
        
        if let actionSheetType = actionSheetType {
            switch actionSheetType {
            case ActionSheetType.TellMeMore:
                openLinkTitle = NSLocalizedString("Open in Safari", comment: "Open in Safari")
                break
                
            case ActionSheetType.ViewInAppStore:
                openLinkTitle = NSLocalizedString("Open in App Store", comment: "Open in App Store")
                break
            }
            
            // TODO: - l18n - iss#2
            let actionSheet: UIActionSheet = UIActionSheet(title: nil,
                                                           delegate: self,
                                                           cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"),
                                                           destructiveButtonTitle: nil,
                                                           otherButtonTitles: openLinkTitle)
            
            actionSheet.actionSheetStyle = UIActionSheetStyle.BlackOpaque
            
            if UIDevice.currentDevice().model == "iPhone" {
                actionSheet.showInView(scrollView)
            } else {
                // iPad
                actionSheet.showFromRect(rect, inView: scrollView, animated: true)
            }
        }
    }
    
    // MARK: - Notifications
    
    func performThemeUpdate() {
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0), NSForegroundColorAttributeName: UIColor.triggertrap_iconColor(1.0)]
        
        self.leftButton?.setBackgroundImage(ImageWithColor(UIImage(named: "MenuIcon")!, color: UIColor.triggertrap_iconColor()) , forState: .Normal)
        
        self.rightButton?.setBackgroundImage(ImageWithColor(UIImage(named: "OptionsIcon")!, color: UIColor.triggertrap_iconColor()) , forState: .Normal)
        
        scrollView.backgroundColor = UIColor.triggertrap_fillColor()
        textView.backgroundColor = UIColor.triggertrap_fillColor()
        textView.textColor = UIColor.triggertrap_accentColor()
        
        tellMeMoreButton.fillColor = UIColor.triggertrap_primaryColor()
        tellMeMoreButton.borderColor = UIColor.triggertrap_primaryColor()
        tellMeMoreButton.setTitleColor(UIColor.triggertrap_fillColor(), forState: .Normal)
        
        viewInAppStoreButton.fillColor = UIColor.triggertrap_primaryColor()
        viewInAppStoreButton.borderColor = UIColor.triggertrap_primaryColor()
        viewInAppStoreButton.setTitleColor(UIColor.triggertrap_fillColor(), forState: .Normal)
        
        bottomBackgroundView.backgroundColor = UIColor.triggertrap_naturalColor()
        topGradientView.color = UIColor.triggertrap_fillColor()
        bottomGradientView.color = UIColor.triggertrap_fillColor()
        separatorView.backgroundColor = UIColor.triggertrap_accentColor()
    }
    
    // MARK: - Actions
    
    @IBAction func scrollButtonTapped(button: UIButton) {
        scrollButton.hidden = true
        
        if scrollView.contentSize.height > (self.view.bounds.height * 2) {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: self.view.bounds.height), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: scrollView.contentSize.height - self.view.bounds.height), animated: true)
        }
    }
    
    @IBAction func tellMeMoreButtonTapped(button: BorderButton) {
        actionSheetType = ActionSheetType.TellMeMore
        showActionSheet(button.frame)
    }
    
    @IBAction func viewInAppStoreButtonTapped(button: BorderButton) {
        actionSheetType = ActionSheetType.ViewInAppStore
        showActionSheet(button.frame)
    }
}

extension TimelapseProViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // User has scrolled to the top of the page and device is in landscape
        if scrollView.contentOffset.y == 0 && self.view.bounds.height < self.view.bounds.width {
            scrollButton.hidden = false
        } else {
            scrollButton.hidden = true
        }
    }
}

extension TimelapseProViewController: UIActionSheetDelegate {
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if let actionSheetType = actionSheetType {
            
            switch actionSheetType {
                
            case ActionSheetType.TellMeMore:
                if buttonIndex == 1 {
                    UIApplication.sharedApplication().openURL(NSURL(string: constTellMeMoreLink)!)
                }
                break
                
            case ActionSheetType.ViewInAppStore:
                if buttonIndex == 1 {
                    UIApplication.sharedApplication().openURL(NSURL(string: constViewInAppStoreLink)!)
                }
                break
            }
        }
    }
}

