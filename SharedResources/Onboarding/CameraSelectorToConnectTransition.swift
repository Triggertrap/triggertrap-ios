//
//  CameraSelectorToConnectTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 28/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class CameraSelectorToConnectTransition: CustomTransition {  
    
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView()
        
        switch state {
        case .Push:
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! CameraSelectorViewController
            snapshotView(fromViewController.greyViewInformationLabel)
            snapshotView(fromViewController.greyViewPraiseLabel)
            snapshotView(fromViewController.whiteView)
            snapshotView(fromViewController.separatorLine)
            snapshotView(fromViewController.pageControl)
            
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ConnectKitViewController
            
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            toViewController.informationView.hidden = true
            toViewController.dismissButton.hidden = true
            
            fadeInView(toViewController.greyViewInformationLabel)
            fadeInView(toViewController.greyViewPraiseLabel)
            fadeInView(toViewController.phoneImageView)
            fadeInView(toViewController.dongleCableView)
            fadeInView(toViewController.dongleCoilImageView)
            
            containerView.addSubview(toViewController.view)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            containerView.addSubview(informationViewSnapshot)
            
            toViewController.view.layoutIfNeeded()
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                informationViewSnapshot.frame = self.containerView.convertRect(fromViewController.informationView.frame, fromView: fromViewController.informationView.superview)
                self.fadeInSnapshots()
                self.fadeOutViews()
                
                }, completion: { (finished) -> Void in
                    informationViewSnapshot.removeFromSuperview()
                    fromViewController.informationView.hidden = false
                    toViewController.informationView.hidden = false
                    toViewController.dismissButton.hidden = false
                    
                    self.showViews()
                    self.removeSnapshotViews()
                    
                    if (transitionContext.transitionWasCancelled()) {
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                    }
            })

            break
            
        case .Pop:
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! ConnectKitViewController
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! CameraSelectorViewController
            toViewController.dismissButton.hidden = true
            
            snapshotView(fromViewController.phoneImageView)
            snapshotView(fromViewController.dongleCableView)
            snapshotView(fromViewController.dongleCoilImageView)
            snapshotView(fromViewController.separatorLine)
            snapshotView(fromViewController.informationView)
            
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            fadeInView(toViewController.whiteView)
            fadeInView(toViewController.greyViewInformationLabel)
            fadeInView(toViewController.greyViewPraiseLabel)
            
            containerView.addSubview(toViewController.view)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            
            containerView.addSubview(informationViewSnapshot)
            
            toViewController.view.layoutIfNeeded()
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                informationViewSnapshot.frame = self.containerView.convertRect(fromViewController.informationView.frame, fromView: fromViewController.informationView.superview)
                self.fadeInSnapshots()
                self.fadeOutViews()
                
                }, completion: { (finished) -> Void in
                    informationViewSnapshot.removeFromSuperview()
                    fromViewController.informationView.hidden = false
                    toViewController.informationView.hidden = false
                    toViewController.dismissButton.hidden = false
                    
                    self.showViews()
                    self.removeSnapshotViews()
                    
                    if (transitionContext.transitionWasCancelled()) {
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                    }
            })

            break
        }
    }
}
