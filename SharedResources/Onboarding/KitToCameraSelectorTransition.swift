//
//  KitToCameraSelectorTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 28/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class KitToCameraSelectorTransition: CustomTransition {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! KitSelectorViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! CameraSelectorViewController
        toViewController.dismissButton.isHidden = true
        
        let kitSnapshot = createSnapshotView(fromViewController.kitImageView)
        
        snapshotView(fromViewController.whiteViewDescriptionLabel)
        snapshotView(fromViewController.whiteViewTitleLabel)
        snapshotView(fromViewController.notYetButton)
        snapshotView(fromViewController.separatorLine)
        
        let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.kitImageView.isHidden = true
        
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
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            kitSnapshot.frame = self.containerView.convert(toViewController.kitImageView.frame, from: toViewController.kitImageView.superview)
            
            informationViewSnapshot.frame = self.containerView.convert(fromViewController.informationView.frame, from: fromViewController.informationView.superview)
            self.fadeInSnapshots()
            self.fadeOutViews()
            
            }, completion: { (finished) -> Void in
                
                self.showViews()
                self.removeSnapshotViews()
                
                kitSnapshot.removeFromSuperview()
                informationViewSnapshot.removeFromSuperview()
                
                toViewController.dismissButton.isHidden = false
                fromViewController.informationView.isHidden = false
                toViewController.informationView.isHidden = false
                toViewController.kitImageView.isHidden = false
                
                if (transitionContext.transitionWasCancelled) {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
        })
    } 
}
