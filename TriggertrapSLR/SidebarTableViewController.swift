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
    
    private var vcPointer: UIViewController!
    
    /*!
    * The storyboard identifer for the view controller visible on the screen. This property is only set when prepareForSegue is called.
    */
    
    private var visibleModeIdentifier: String? 
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SidebarTableViewController.sidebarDidSelectCellWithIdentifier(_:)), name: "SidebarDidSelectCellWithIdentifier", object: nil)
        
        if let lastSelectedViewControllerIdentifier = NSUserDefaults.standardUserDefaults().objectForKey(ConstDefaultLastSelectedMode) as? String, let storyboardName = StoryboardNameForViewControllerIdentifier(lastSelectedViewControllerIdentifier) {
            
            // Launch on the last selected mode, if we have one
            let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle.mainBundle())
            let viewController = storyboard.instantiateViewControllerWithIdentifier(lastSelectedViewControllerIdentifier)
            
            visibleModeIdentifier = lastSelectedViewControllerIdentifier
            
            createUserActivityWithIdentifier(lastSelectedViewControllerIdentifier)
            
            CachedPushNoAnimationStoryboardSegue(identifier: lastSelectedViewControllerIdentifier, source: self, destination: viewController).perform()
            
        } else {
            
            // Push Simple Cable Release mode
            let storyboard = UIStoryboard(name: ConstStoryboardIdentifierCableReleaseModes, bundle: NSBundle.mainBundle())
            let viewController = storyboard.instantiateViewControllerWithIdentifier(ConstSimpleCableReleaseModeIdentifier)
            visibleModeIdentifier = ConstSimpleCableReleaseModeIdentifier
            
            createUserActivityWithIdentifier(ConstSimpleCableReleaseModeIdentifier)
            
            CachedPushNoAnimationStoryboardSegue(identifier: ConstSimpleCableReleaseModeIdentifier, source: self, destination: viewController).perform()
        }
    } 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SidebarDidSelectCellWithIdentifier", object: nil)
    }

    // MARK: NSUserActivity
    
    private func createUserActivityWithIdentifier(identifier: String) {
            
        for userActivity in UserActivityManager.sharedInstance.activities {
            if userActivity.identifier == identifier {
                
                let activity = NSUserActivity(activityType: "com.triggertrap.Triggertrap")
                activity.title = identifier
                activity.keywords = Set<String>(ConstUserActivityKeywords)
                activity.delegate = self
                activity.eligibleForSearch = true
                activity.eligibleForPublicIndexing = true
                activity.eligibleForHandoff = false
                activity.contentAttributeSet = userActivity.searchableAttributeSet()
                    
                UserActivityManager.sharedInstance.userActivity = activity
                UserActivityManager.sharedInstance.userActivity?.delegate = self
                UserActivityManager.sharedInstance.userActivity?.becomeCurrent()
            }
        }
    }
      
    // MARK: - Observers
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
        if ((vcPointer) != nil) {
            if vcPointer.respondsToSelector(#selector(UIViewController.viewWillDisappear(_:))) {
                vcPointer.viewWillDisappear(animated)
            }
        }
        
        vcPointer = viewController
    }
    
    func sidebarDidSelectCellWithIdentifier(sender: NSNotification) {
        
        let identifier = sender.object as! String
        
        if identifier == visibleModeIdentifier {
            // Return to the running mode
            NSNotificationCenter.defaultCenter().postNotificationName("DismissLeftPanel", object:self)
            return
        }
        
        self.navigationController?.popToRootViewControllerAnimated(false)
        
        if let storyboardName = StoryboardNameForViewControllerIdentifier(identifier) {
            
            // Store the identifier
            visibleModeIdentifier = identifier
            
            // Save the identifer to the user defaults for the last selected mode
            NSUserDefaults.standardUserDefaults().setObject(visibleModeIdentifier, forKey: ConstDefaultLastSelectedMode)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            NSNotificationCenter.defaultCenter().postNotificationName("DismissLeftPanel", object:self)
            
            // Launch on the last selected mode, if we have one
            let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle.mainBundle())
            let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier)
            
            createUserActivityWithIdentifier(identifier)
            
            CachedPushNoAnimationStoryboardSegue(identifier: identifier, source: self, destination: viewController).perform()
        }
    }

    @available(iOS 8.0, *)
    func userActivityWillSave(userActivity: NSUserActivity) {
        userActivity.addUserInfoEntriesFromDictionary(["mode": userActivity.title!])
    }
}
