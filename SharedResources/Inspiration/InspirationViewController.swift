//
//  InspirationViewController.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 13/04/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class InspirationViewController: UIViewController {
  
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var carouselHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollButton: UIButton!
    @IBOutlet weak var shimmeringView: FBShimmeringView!
    @IBOutlet weak var topGradientOverlayView: GradientOverlayView!
    @IBOutlet weak var bottomGradientOverlayView: GradientOverlayView!
    
    let padding: CGFloat = 8.0
    let buttonHeight: CGFloat = 44.0
    
    enum ActionSheetType {
        case Flickr,
        Instagram,
        Twitter,
        Facebook
    }
    
    var actionSheetType: ActionSheetType?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        shimmeringView.contentView = scrollButton
        
        // Hide the status bar with animation
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        textView.text = NSLocalizedString("Get Inspired! Everything we create, we create so photographers like you can get out there and take fantastic photographs. Why not take a couple of minutes to check out the awesome photographs by our users on Flickr, or images tagged #triggertrap on Instagram? We also have our Twitter and Facebook feeds full of our favourite images, brilliant techniques and the latest Triggertrap news.\n\nWe love seeing photographs that have been Powered by Triggertrap - and we’d love to see what you create, so don’t forget to tag your photos @triggertrap, or use #triggertrap!\n\nMany thanks to:\nImage 1 - Lurking by Tim Gamble\nImage 2 - Windmill and Thunder by Riku Kupainen\nImage 3 - by David Hopley\nImage 4 - Northern Lights by Kolbein Svensson ", comment: "Get Inspired! Everything we create, we create so photographers like you can get out there and take fantastic photographs. Why not take a couple of minutes to check out the awesome photographs by our users on Flickr, or images tagged #triggertrap on Instagram? We also have our Twitter and Facebook feeds full of our favourite images, brilliant techniques and the latest Triggertrap news.\n\nWe love seeing photographs that have been Powered by Triggertrap - and we’d love to see what you create, so don’t forget to tag your photos @triggertrap, or use #triggertrap!\n\nMany thanks to:\nImage 1 - Lurking by Tim Gamble\nImage 2 - Windmill and Thunder by Riku Kupainen\nImage 3 - by David Hopley\nImage 4 - Northern Lights by Kolbein Svensson ")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.flashScrollIndicators()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Override theme gray scale by assigning a custom one
        
        topGradientOverlayView.grayScale = 1.0
        bottomGradientOverlayView.grayScale = 1.0
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        // Hide the status bar with animation
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.view.bounds.height > self.view.bounds.width {
            scrollButton.hidden = true
            shimmeringView.shimmering = false
            carouselHeightConstraint.constant = self.view.bounds.height / 2
            textViewHeightConstraint.constant = (self.view.bounds.height / 2) - (2 * padding + buttonHeight)
        } else {
            scrollButton.hidden = false
            shimmeringView.shimmering = true
            carouselHeightConstraint.constant = self.view.bounds.height
            textViewHeightConstraint.constant = SizeForText(textView.text, withFont: textView.font!, constrainedToSize: CGSize(width: textView.frame.width, height: 1000)).height + 2 * padding
        } 
        
        self.view.layoutSubviews()
    }
    
    private func showActionSheet(rect: CGRect) {
        
        var openLinkTitle = ""
        
        if let actionSheetType = actionSheetType {
            switch actionSheetType {
            case ActionSheetType.Flickr:
                openLinkTitle = NSLocalizedString("Open in Flickr", comment: "Open in Flickr")
                break
                
            case ActionSheetType.Instagram:
                openLinkTitle = NSLocalizedString("Open in Instagram", comment: "Open in Instagram")
                break
                
            case ActionSheetType.Twitter:
                openLinkTitle = NSLocalizedString("Open in Twitter", comment: "Open in Twitter")
                break
                
            case ActionSheetType.Facebook:
                openLinkTitle = NSLocalizedString("Open in Facebook", comment: "Open in Facebook")
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

    // MARK: - Actions
    
    // Call this function to dismiss the view controller from a storyboard vc button
    @IBAction func dismissViewController(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func scrollButtonTapped(button: UIButton) {
        scrollButton.hidden = true
        
        if scrollView.contentSize.height > (self.view.bounds.height * 2) {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: self.view.bounds.height), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: scrollView.contentSize.height - self.view.bounds.height), animated: true)
        } 
    }
    
    @IBAction func flickrButtonTapped(button: UIButton) {
        actionSheetType = .Flickr
        showActionSheet(button.frame)
    }
    
    @IBAction func instagramButtonTapped(button: UIButton) {
        actionSheetType = .Instagram
        showActionSheet(button.frame)
    }
    
    @IBAction func twitterButtonTapped(button: UIButton) {
        actionSheetType = .Twitter
        showActionSheet(button.frame)
    }
    
    @IBAction func facebookButtonTapped(button: UIButton) {
        actionSheetType = .Facebook
        showActionSheet(button.frame)
    }
}

extension InspirationViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // User has scrolled to the top of the page and device is in landscape
        if scrollView.contentOffset.y == 0 && self.view.bounds.height < self.view.bounds.width {
            scrollButton.hidden = false
        } else {
            scrollButton.hidden = true
        }
    }
}

extension InspirationViewController: UIActionSheetDelegate {
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if let actionSheetType = actionSheetType {
            
            switch actionSheetType {
                
            case ActionSheetType.Flickr:
                if buttonIndex == 1 {
                    let flickrURL = NSURL(string: "flickr://groups/triggertrap/")!
                    let backupURL = NSURL(string: "http://flickr.com/groups/triggertrap/")!
                    
                    openURL(flickrURL, withBackupURL: backupURL)
                }
                break
                
            case ActionSheetType.Instagram:
                if buttonIndex == 1 {
                    let instagramURL = NSURL(string: "instagram://tag?name=triggertrap")!
                    let backupURL = NSURL(string: "https://instagram.com/explore/tags/triggertrap/")!
                    
                    openURL(instagramURL, withBackupURL: backupURL)
                }
                break
                
            case ActionSheetType.Twitter:
                if buttonIndex == 1 {
                    let twitterURL = NSURL(string: "twitter://user?screen_name=triggertrap/")!
                    let backupURL = NSURL(string: "http://twitter.com/triggertrap/")!
                    
                    openURL(twitterURL, withBackupURL: backupURL)
                }
                break
                
            case ActionSheetType.Facebook:
                if buttonIndex == 1 {
                    let facebookURL = NSURL(string: "fb://profile/166726010056550")!
                    let backupURL = NSURL(string: "https://www.facebook.com/triggertrap/")!
                    
                    openURL(facebookURL, withBackupURL: backupURL)
                }
                break
            }
        }
    }
    
    private func openURL(url: NSURL, withBackupURL backupURL: NSURL) {
        
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        } else if UIApplication.sharedApplication().canOpenURL(backupURL) {
            UIApplication.sharedApplication().openURL(backupURL)
        }
    }
}