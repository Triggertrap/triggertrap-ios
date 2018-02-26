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
        case flickr,
        instagram,
        twitter,
        facebook
    }
    
    var actionSheetType: ActionSheetType?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        shimmeringView.contentView = scrollButton
        
        // Hide the status bar with animation
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.slide)
        textView.text = NSLocalizedString("Get Inspired! Everything we create, we create so photographers like you can get out there and take fantastic photographs. Why not take a couple of minutes to check out the awesome photographs by our users on Flickr, or images tagged #triggertrap on Instagram? We also have our Twitter and Facebook feeds full of our favourite images, brilliant techniques and the latest Triggertrap news.\n\nWe love seeing photographs that have been Powered by Triggertrap - and we’d love to see what you create, so don’t forget to tag your photos @triggertrap, or use #triggertrap!\n\nMany thanks to:\nImage 1 - Lurking by Tim Gamble\nImage 2 - Windmill and Thunder by Riku Kupainen\nImage 3 - by David Hopley\nImage 4 - Northern Lights by Kolbein Svensson ", comment: "Get Inspired! Everything we create, we create so photographers like you can get out there and take fantastic photographs. Why not take a couple of minutes to check out the awesome photographs by our users on Flickr, or images tagged #triggertrap on Instagram? We also have our Twitter and Facebook feeds full of our favourite images, brilliant techniques and the latest Triggertrap news.\n\nWe love seeing photographs that have been Powered by Triggertrap - and we’d love to see what you create, so don’t forget to tag your photos @triggertrap, or use #triggertrap!\n\nMany thanks to:\nImage 1 - Lurking by Tim Gamble\nImage 2 - Windmill and Thunder by Riku Kupainen\nImage 3 - by David Hopley\nImage 4 - Northern Lights by Kolbein Svensson ")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.flashScrollIndicators()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Override theme gray scale by assigning a custom one
        
        topGradientOverlayView.grayScale = 1.0
        bottomGradientOverlayView.grayScale = 1.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        // Hide the status bar with animation
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.slide)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.view.bounds.height > self.view.bounds.width {
            scrollButton.isHidden = true
            shimmeringView.isShimmering = false
            carouselHeightConstraint.constant = self.view.bounds.height / 2
            textViewHeightConstraint.constant = (self.view.bounds.height / 2) - (2 * padding + buttonHeight)
        } else {
            scrollButton.isHidden = false
            shimmeringView.isShimmering = true
            carouselHeightConstraint.constant = self.view.bounds.height
            textViewHeightConstraint.constant = SizeForText(textView.text! as NSString, withFont: textView.font!, constrainedToSize: CGSize(width: textView.frame.width, height: 1000)).height + 2 * padding
        } 
        
        self.view.layoutSubviews()
    }
    
    fileprivate func showActionSheet(_ rect: CGRect) {
        
        var openLinkTitle = ""
        
        if let actionSheetType = actionSheetType {
            switch actionSheetType {
            case ActionSheetType.flickr:
                openLinkTitle = NSLocalizedString("Open in Flickr", comment: "Open in Flickr")
                break
                
            case ActionSheetType.instagram:
                openLinkTitle = NSLocalizedString("Open in Instagram", comment: "Open in Instagram")
                break
                
            case ActionSheetType.twitter:
                openLinkTitle = NSLocalizedString("Open in Twitter", comment: "Open in Twitter")
                break
                
            case ActionSheetType.facebook:
                openLinkTitle = NSLocalizedString("Open in Facebook", comment: "Open in Facebook")
                break
            }
            
            // TODO: - l18n - iss#2
            let actionSheet: UIActionSheet = UIActionSheet(title: nil,
                delegate: self,
                cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"),
                destructiveButtonTitle: nil,
                otherButtonTitles: openLinkTitle)
            
            actionSheet.actionSheetStyle = UIActionSheetStyle.blackOpaque
            
            if UIDevice.current.model == "iPhone" {
                actionSheet.show(in: scrollView)
            } else {
                // iPad
                actionSheet.show(from: rect, in: scrollView, animated: true)
            }
        }
    }

    // MARK: - Actions
    
    // Call this function to dismiss the view controller from a storyboard vc button
    @IBAction func dismissViewController(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scrollButtonTapped(_ button: UIButton) {
        scrollButton.isHidden = true
        
        if scrollView.contentSize.height > (self.view.bounds.height * 2) {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: self.view.bounds.height), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: scrollView.contentSize.height - self.view.bounds.height), animated: true)
        } 
    }
    
    @IBAction func flickrButtonTapped(_ button: UIButton) {
        actionSheetType = .flickr
        showActionSheet(button.frame)
    }
    
    @IBAction func instagramButtonTapped(_ button: UIButton) {
        actionSheetType = .instagram
        showActionSheet(button.frame)
    }
    
    @IBAction func twitterButtonTapped(_ button: UIButton) {
        actionSheetType = .twitter
        showActionSheet(button.frame)
    }
    
    @IBAction func facebookButtonTapped(_ button: UIButton) {
        actionSheetType = .facebook
        showActionSheet(button.frame)
    }
}

extension InspirationViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // User has scrolled to the top of the page and device is in landscape
        if scrollView.contentOffset.y == 0 && self.view.bounds.height < self.view.bounds.width {
            scrollButton.isHidden = false
        } else {
            scrollButton.isHidden = true
        }
    }
}

extension InspirationViewController: UIActionSheetDelegate {
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        if let actionSheetType = actionSheetType {
            
            switch actionSheetType {
                
            case ActionSheetType.flickr:
                if buttonIndex == 1 {
                    let flickrURL = URL(string: "flickr://groups/triggertrap/")!
                    let backupURL = URL(string: "http://flickr.com/groups/triggertrap/")!
                    
                    openURL(flickrURL, withBackupURL: backupURL)
                }
                break
                
            case ActionSheetType.instagram:
                if buttonIndex == 1 {
                    let instagramURL = URL(string: "instagram://tag?name=triggertrap")!
                    let backupURL = URL(string: "https://instagram.com/explore/tags/triggertrap/")!
                    
                    openURL(instagramURL, withBackupURL: backupURL)
                }
                break
                
            case ActionSheetType.twitter:
                if buttonIndex == 1 {
                    let twitterURL = URL(string: "twitter://user?screen_name=triggertrap/")!
                    let backupURL = URL(string: "http://twitter.com/triggertrap/")!
                    
                    openURL(twitterURL, withBackupURL: backupURL)
                }
                break
                
            case ActionSheetType.facebook:
                if buttonIndex == 1 {
                    let facebookURL = URL(string: "fb://profile/166726010056550")!
                    let backupURL = URL(string: "https://www.facebook.com/triggertrap/")!
                    
                    openURL(facebookURL, withBackupURL: backupURL)
                }
                break
            }
        }
    }
    
    fileprivate func openURL(_ url: URL, withBackupURL backupURL: URL) {
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        } else if UIApplication.shared.canOpenURL(backupURL) {
            UIApplication.shared.openURL(backupURL)
        }
    }
}
