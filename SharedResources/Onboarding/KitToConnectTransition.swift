//
//  CircleTransitionAnimator.swift
//  CircleTransition
//
//  Created by Rounak Jain on 23/10/14.
//  Copyright (c) 2014 Rounak Jain. All rights reserved.
//

import UIKit

class KitToConnectTransition: CustomTransition { 
      
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView()
        
        switch state {
        case .Push:
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! KitSelectorViewController
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ConnectKitViewController
            
            // Create a snapshot of the view, hide it and add it to the snapshotViews array. This also causes the initial image to be added to viewsToShowArray
            snapshotView(fromViewController.kitImageView)
            snapshotView(fromViewController.descriptionLabel)
            snapshotView(fromViewController.whiteViewDescriptionLabel)
            snapshotView(fromViewController.whiteViewTitleLabel)
            snapshotView(fromViewController.notYetButton)
            snapshotView(fromViewController.pageControl)
            
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            
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
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! KitSelectorViewController
            toViewController.dismissButton.hidden = true
            
            snapshotView(fromViewController.phoneImageView)
            snapshotView(fromViewController.dongleCableView)
            snapshotView(fromViewController.dongleCoilImageView)
            snapshotView(fromViewController.separatorLine)
            
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            fadeInView(toViewController.kitImageView)
            fadeInView(toViewController.whiteViewDescriptionLabel)
            fadeInView(toViewController.whiteViewTitleLabel)
            fadeInView(toViewController.notYetButton)
            fadeInView(toViewController.greyViewInformationLabel)
            fadeInView(toViewController.greyViewPraiseLabel)
            fadeInView(toViewController.descriptionLabel)

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
