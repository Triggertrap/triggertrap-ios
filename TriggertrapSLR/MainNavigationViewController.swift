//
//  MainNavigationViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 05/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class MainNavigationViewController: RotationNavigationViewController {
    
    // MARK: - Computed properties
    
    private var sidePanelSize: CGSize {
        get {
            // Calculate the width of the side bar depening on the device, 280px for iPhones, 480px for iPads
            return CGSizeMake(UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 280.0 : 420.0, 0.0)
        }
    }
    
    private var leftPanelViewController: MCPanelViewController!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the iOS 7.0 interactive pop gesture recognizer on the navigation
        // controller, as this gets in the way of the sidebar interactions.
        if self.respondsToSelector(Selector("interactivePopGestureRecognizer")) {
            self.interactivePopGestureRecognizer!.enabled = false
        }
        
        let storyboard : UIStoryboard = UIStoryboard(name: ConstStoryboardIdentifierMain, bundle: nil);
        
        // Configure the left view controller
        let leftNavigationViewController = storyboard.instantiateViewControllerWithIdentifier(ConstStoryboardIdentifierLeftPanel) as! UINavigationController
        leftNavigationViewController.preferredContentSize = sidePanelSize
        leftPanelViewController = leftNavigationViewController.viewControllerInPanelViewController()
        leftPanelViewController.backgroundStyle = .None
    }
    
    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainNavigationViewController.dismissLeftPanel(_:)), name: "DismissLeftPanel", object: nil)
        
        self.addGestureRecognizerToViewForScreenEdgeGestureWithPanelViewController(leftPanelViewController, withDirection: MCPanelAnimationDirection.Left)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeGestureRecognizersFromViewForScreenEdgeGestureWithPanelViewController(leftPanelViewController)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DismissLeftPanel", object: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ context in
            
            
            }, completion: { context in
                
                for vc in self.viewControllers {
                    let viewController = vc
                    
                    if viewController is TTViewController {
                        self.popToViewController(viewController, animated: false)
                    }
                }
        })
    }
    
    // MARK: - Actions
    func menuButtonTapped(sender: UIBarButtonItem) {
        dispatch_async(dispatch_get_main_queue(), {
            self.presentPanelViewController(self.leftPanelViewController, withDirection: MCPanelAnimationDirection.Left)
        })
    }
    
    func optionsButtonTapped(sender: UIBarButtonItem) {
        
        // Inform the active view controller that it will loose focus - Quick Release and Press and Hold modes 
        NSNotificationCenter.defaultCenter().postNotificationName("ActiveViewControllerLostFocus", object: nil)
        
        let storyboard = UIStoryboard(name: ConstStoryboardIdentifierOptions, bundle: NSBundle.mainBundle())
        let viewController = storyboard.instantiateInitialViewController()!
        
        // Present the options view controller in full screen
        viewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        
        self.presentViewController(viewController, animated: true, completion: nil)
    } 
    
    // MARK: - Observers
    
    func dismissLeftPanel(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            self.leftPanelViewController.dismiss()
        })
    }
}
