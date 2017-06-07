//
//  KitToCameraSelectorTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 28/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class KitToCameraSelectorTransition: CustomTransition {
    
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView()
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! KitSelectorViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! CameraSelectorViewController
        toViewController.dismissButton.hidden = true
        
        let kitSnapshot = createSnapshotView(fromViewController.kitImageView)
        
        snapshotView(fromViewController.whiteViewDescriptionLabel)
        snapshotView(fromViewController.whiteViewTitleLabel)
        snapshotView(fromViewController.notYetButton)
        snapshotView(fromViewController.separatorLine)
        
        let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
        
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.kitImageView.hidden = true
        
        fadeInView(toViewController.whiteView)
        fadeInView(toViewController.greyViewInformationLabel)
        fadeInView(toViewController.greyViewPraiseLabel)
        fadeInView(toViewController.kitImageView)
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(kitSnapshot)
        
        for view: UIView in snapshotViews {
            containerView.addSubview(view)
        }
        
        containerView.addSubview(informationViewSnapshot)
        
        toViewController.view.layoutIfNeeded()
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            kitSnapshot.frame = self.containerView.convertRect(toViewController.kitImageView.frame, fromView: toViewController.kitImageView.superview)
            
            informationViewSnapshot.frame = self.containerView.convertRect(fromViewController.informationView.frame, fromView: fromViewController.informationView.superview)
            self.fadeInSnapshots()
            self.fadeOutViews()
            
            }, completion: { (finished) -> Void in
                
                self.showViews()
                self.removeSnapshotViews()
                
                kitSnapshot.removeFromSuperview()
                informationViewSnapshot.removeFromSuperview()
                
                toViewController.dismissButton.hidden = false
                fromViewController.informationView.hidden = false
                toViewController.informationView.hidden = false
                toViewController.kitImageView.hidden = false
                
                if (transitionContext.transitionWasCancelled()) {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
        })
    } 
}
