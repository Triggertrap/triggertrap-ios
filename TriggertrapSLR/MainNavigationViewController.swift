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
    
    fileprivate var sidePanelSize: CGSize {
        get {
            // Calculate the width of the side bar depening on the device, 280px for iPhones, 480px for iPads
            return CGSize(width: UIDevice.current.userInterfaceIdiom == .phone ? 280.0 : 420.0, height: 0.0)
        }
    }
    
    fileprivate var leftPanelViewController: MCPanelViewController!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the iOS 7.0 interactive pop gesture recognizer on the navigation
        // controller, as this gets in the way of the sidebar interactions.
        if self.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer!.isEnabled = false
        }
        
        let storyboard : UIStoryboard = UIStoryboard(name: ConstStoryboardIdentifierMain, bundle: nil);
        
        // Configure the left view controller
        let leftNavigationViewController = storyboard.instantiateViewController(withIdentifier: ConstStoryboardIdentifierLeftPanel) as! UINavigationController
        leftNavigationViewController.preferredContentSize = sidePanelSize
        leftPanelViewController = leftNavigationViewController.viewControllerInPanelViewController()
        leftPanelViewController.backgroundStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainNavigationViewController.dismissLeftPanel(_:)), name: NSNotification.Name(rawValue: "DismissLeftPanel"), object: nil)
        
        self.addGestureRecognizerToViewForScreenEdgeGesture(with: leftPanelViewController, with: MCPanelAnimationDirection.left)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeGestureRecognizersFromViewForScreenEdgeGesture(with: leftPanelViewController)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DismissLeftPanel"), object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { context in
            
            
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
    @objc func menuButtonTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async(execute: {
            self.present(self.leftPanelViewController, with: MCPanelAnimationDirection.left)
        })
    }
    
    @objc func optionsButtonTapped(_ sender: UIBarButtonItem) {
        
        // Inform the active view controller that it will loose focus - Quick Release and Press and Hold modes 
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ActiveViewControllerLostFocus"), object: nil)
        
        let storyboard = UIStoryboard(name: ConstStoryboardIdentifierOptions, bundle: Bundle.main)
        let viewController = storyboard.instantiateInitialViewController()!
        
        let destinationController = storyboard.instantiateViewController(withIdentifier: "optionsController")
        
        // Present the options view controller in full screen
        viewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        viewController.modalPresentationCapturesStatusBarAppearance = true
        
        destinationController.modalPresentationCapturesStatusBarAppearance = true
        
        self.present(viewController, animated: true, completion: nil)
    } 
    
    // MARK: - Observers
    
    @objc func dismissLeftPanel(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            self.leftPanelViewController.dismiss()
        })
    }
}
