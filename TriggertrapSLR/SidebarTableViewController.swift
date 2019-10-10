//
//  SidebarTableViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 05/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit
import Foundation
import CoreSpotlight

class SidebarTableViewController: UITableViewController, UINavigationControllerDelegate, NSUserActivityDelegate {
    
    // MARK: - Properties
    
    fileprivate var vcPointer: UIViewController!
    
    /*!
    * The storyboard identifer for the view controller visible on the screen. This property is only set when prepareForSegue is called.
    */
    
    fileprivate var visibleModeIdentifier: String? 
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SidebarTableViewController.sidebarDidSelectCellWithIdentifier(_:)), name: NSNotification.Name(rawValue: "SidebarDidSelectCellWithIdentifier"), object: nil)
        
        if let lastSelectedViewControllerIdentifier = UserDefaults.standard.object(forKey: ConstDefaultLastSelectedMode) as? String, let storyboardName = StoryboardNameForViewControllerIdentifier(lastSelectedViewControllerIdentifier) {
            
            // Launch on the last selected mode, if we have one
            let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
            let viewController = storyboard.instantiateViewController(withIdentifier: lastSelectedViewControllerIdentifier)
            
            visibleModeIdentifier = lastSelectedViewControllerIdentifier
            
            createUserActivityWithIdentifier(lastSelectedViewControllerIdentifier)
            
            CachedPushNoAnimationStoryboardSegue(identifier: lastSelectedViewControllerIdentifier, source: self, destination: viewController).perform()
            
        } else {
            
            // Push Simple Cable Release mode
            let storyboard = UIStoryboard(name: ConstStoryboardIdentifierCableReleaseModes, bundle: Bundle.main)
            let viewController = storyboard.instantiateViewController(withIdentifier: ConstSimpleCableReleaseModeIdentifier)
            visibleModeIdentifier = ConstSimpleCableReleaseModeIdentifier
            
            createUserActivityWithIdentifier(ConstSimpleCableReleaseModeIdentifier)
            
            CachedPushNoAnimationStoryboardSegue(identifier: ConstSimpleCableReleaseModeIdentifier, source: self, destination: viewController).perform()
        }
    } 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "SidebarDidSelectCellWithIdentifier"), object: nil)
    }

    

    // MARK: NSUserActivity
    
    fileprivate func createUserActivityWithIdentifier(_ identifier: String) {
            
        for userActivity in UserActivityManager.sharedInstance.activities {
            if userActivity.identifier == identifier {
                
                let activity = NSUserActivity(activityType: "com.triggertrap.Triggertrap")
                activity.title = identifier
                activity.keywords = Set<String>(ConstUserActivityKeywords)
                activity.delegate = self
                activity.isEligibleForSearch = true
                activity.isEligibleForPublicIndexing = true
                activity.isEligibleForHandoff = false
                activity.contentAttributeSet = userActivity.searchableAttributeSet()
                    
                UserActivityManager.sharedInstance.userActivity = activity
                UserActivityManager.sharedInstance.userActivity?.delegate = self
                UserActivityManager.sharedInstance.userActivity?.becomeCurrent()
            }
        }
    }
      
    // MARK: - Observers
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if ((vcPointer) != nil) {
            if vcPointer.responds(to: #selector(UIViewController.viewWillDisappear(_:))) {
                vcPointer.viewWillDisappear(animated)
            }
        }
        
        vcPointer = viewController
    }
    
    @objc func sidebarDidSelectCellWithIdentifier(_ sender: Notification) {
        
        let identifier = sender.object as! String
        
        if identifier == visibleModeIdentifier {
            // Return to the running mode
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DismissLeftPanel"), object:self)
            return
        }
        
        self.navigationController?.popToRootViewController(animated: false)
        
        if let storyboardName = StoryboardNameForViewControllerIdentifier(identifier) {
            
            // Store the identifier
            visibleModeIdentifier = identifier
            
            // Save the identifer to the user defaults for the last selected mode
            UserDefaults.standard.set(visibleModeIdentifier, forKey: ConstDefaultLastSelectedMode)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DismissLeftPanel"), object:self)
            
            // Launch on the last selected mode, if we have one
            let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
            let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
            
            createUserActivityWithIdentifier(identifier)
            
            CachedPushNoAnimationStoryboardSegue(identifier: identifier, source: self, destination: viewController).perform()
        }
    }

    @available(iOS 8.0, *)
    func userActivityWillSave(_ userActivity: NSUserActivity) {
        userActivity.addUserInfoEntries(from: ["mode": userActivity.title!])
    }
}
