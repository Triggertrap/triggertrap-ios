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
    
    fileprivate let buttonHeight: CGFloat = 44.0
    fileprivate let padding: CGFloat = 8
    
    fileprivate enum ActionSheetType {
        case tellMeMore,
        viewInAppStore
    }
    
    fileprivate var actionSheetType: ActionSheetType?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        shimmeringView.contentView = scrollButton
        textView.text = NSLocalizedString("Triggertrap Timelapse Pro is a new approach to creating awesome timelapses. Connect your device to your camera with a Triggertrap Mobile kit, and you're set to get creative!\n\nTimelapse Pro has a modular approach to timelapse creation, letting you create sequences using the building blocks of timelapses - intervalometers and delays. With these blocks you can create timelapses of all shapes and sizes. Timelapse Pro's intervalometers allow you to set your interval between shots, as well as when you'd like the intervalometer to stop; either by the number of shots or after a set amount of time has passed.", comment: "Triggertrap Timelapse Pro is a new approach to creating awesome timelapses. Connect your device to your camera with a Triggertrap Mobile kit, and you're set to get creative!\n\nTimelapse Pro has a modular approach to timelapse creation, letting you create sequences using the building blocks of timelapses - intervalometers and delays. With these blocks you can create timelapses of all shapes and sizes. Timelapse Pro's intervalometers allow you to set your interval between shots, as well as when you'd like the intervalometer to stop; either by the number of shots or after a set amount of time has passed.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        performThemeUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimelapseProViewController.performThemeUpdate), name: NSNotification.Name(rawValue: ConstThemeHasBeenUpdated), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.flashScrollIndicators()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.view.bounds.height > self.view.bounds.width {
            scrollButton.isHidden = true
            shimmeringView.isShimmering = false
            previewHeightConstraint.constant = self.view.bounds.height / 2
            textViewHeightConstraint.constant = (self.view.frame.height / 2) - (3 * padding + 2 * buttonHeight)
        } else {
            scrollButton.isHidden = false
            shimmeringView.isShimmering = true
            previewHeightConstraint.constant = self.view.bounds.height
            textViewHeightConstraint.constant = SizeForText(textView.text! as NSString, withFont: textView.font!, constrainedToSize: CGSize(width: textView.frame.width, height: 1000)).height + 2 * padding
        } 
        
        self.view.layoutSubviews()
        
        textView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    
    fileprivate func showActionSheet(_ rect: CGRect) {
        
        var openLinkTitle = ""
        
        if let actionSheetType = actionSheetType {
            switch actionSheetType {
            case ActionSheetType.tellMeMore:
                openLinkTitle = NSLocalizedString("Open in Safari", comment: "Open in Safari")
                break
                
            case ActionSheetType.viewInAppStore:
                openLinkTitle = NSLocalizedString("Open in App Store", comment: "Open in App Store")
                break
            }
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let openLinkAction = UIAlertAction(title: openLinkTitle, style: .default) { (action) in
                if actionSheetType == ActionSheetType.tellMeMore{
                    UIApplication.shared.openURL(URL(string: constTellMeMoreLink)!)
                } else {
                    UIApplication.shared.openURL(URL(string: constViewInAppStoreLink)!)
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
            
            alertController.addAction(openLinkAction)
            alertController.addAction(cancelAction)
            
            if let popoverController = alertController.popoverPresentationController {
                let sourceView = actionSheetType == .tellMeMore ? tellMeMoreButton : viewInAppStoreButton
                popoverController.sourceView = sourceView
                popoverController.sourceRect = CGRect(x: (sourceView?.bounds.midX)!, y: (sourceView?.bounds.minY)!, width: 0, height: 0)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Notifications
    
    @objc func performThemeUpdate() {
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.triggertrap_metric_regular(23.0), NSAttributedStringKey.foregroundColor: UIColor.triggertrap_iconColor(1.0)]
        
        self.leftButton?.setBackgroundImage(#imageLiteral(resourceName: "MenuIcon"), for: .normal)
        
        self.rightButton?.setBackgroundImage(#imageLiteral(resourceName: "OptionsIcon"), for: .normal)
        
        scrollView.backgroundColor = UIColor.triggertrap_fillColor()
        textView.backgroundColor = UIColor.triggertrap_fillColor()
        textView.textColor = UIColor.triggertrap_accentColor()
        
        tellMeMoreButton.fillColor = UIColor.triggertrap_primaryColor()
        tellMeMoreButton.borderColor = UIColor.triggertrap_primaryColor()
        tellMeMoreButton.setTitleColor(UIColor.triggertrap_fillColor(), for: UIControlState())
        
        viewInAppStoreButton.fillColor = UIColor.triggertrap_primaryColor()
        viewInAppStoreButton.borderColor = UIColor.triggertrap_primaryColor()
        viewInAppStoreButton.setTitleColor(UIColor.triggertrap_fillColor(), for: UIControlState())
        
        bottomBackgroundView.backgroundColor = UIColor.triggertrap_naturalColor()
        topGradientView.color = UIColor.triggertrap_fillColor()
        bottomGradientView.color = UIColor.triggertrap_fillColor()
        separatorView.backgroundColor = UIColor.triggertrap_accentColor()
    }
    
    // MARK: - Actions
    
    @IBAction func scrollButtonTapped(_ button: UIButton) {
        scrollButton.isHidden = true
        
        if scrollView.contentSize.height > (self.view.bounds.height * 2) {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: self.view.bounds.height), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: scrollView.contentSize.height - self.view.bounds.height), animated: true)
        }
    }
    
    @IBAction func tellMeMoreButtonTapped(_ button: BorderButton) {
        actionSheetType = ActionSheetType.tellMeMore
        showActionSheet(button.frame)
    }
    
    @IBAction func viewInAppStoreButtonTapped(_ button: BorderButton) {
        actionSheetType = ActionSheetType.viewInAppStore
        showActionSheet(button.frame)
    }
}

extension TimelapseProViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // User has scrolled to the top of the page and device is in landscape
        if scrollView.contentOffset.y == 0 && self.view.bounds.height < self.view.bounds.width {
            scrollButton.isHidden = false
        } else {
            scrollButton.isHidden = true
        }
    }
}
