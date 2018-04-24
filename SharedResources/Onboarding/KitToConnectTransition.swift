//
//  CircleTransitionAnimator.swift
//  CircleTransition
//
//  Created by Rounak Jain on 23/10/14.
//  Copyright (c) 2014 Rounak Jain. All rights reserved.
//

import UIKit

class KitToConnectTransition: CustomTransition { 
      
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView
        
        switch state {
        case .push:
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! KitSelectorViewController
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ConnectKitViewController
            
            // Create a snapshot of the view, hide it and add it to the snapshotViews array. This also causes the initial image to be added to viewsToShowArray
            snapshotView(fromViewController.kitImageView)
            snapshotView(fromViewController.descriptionLabel)
            snapshotView(fromViewController.whiteViewDescriptionLabel)
            snapshotView(fromViewController.whiteViewTitleLabel)
            snapshotView(fromViewController.notYetButton)
            snapshotView(fromViewController.pageControl)
            
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            toViewController.informationView.isHidden = true
            toViewController.dismissButton.isHidden = true
            
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
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                informationViewSnapshot.frame = self.containerView.convert(fromViewController.informationView.frame, from: fromViewController.informationView.superview)
                self.fadeInSnapshots()
                self.fadeOutViews()
                
                }, completion: { (finished) -> Void in
                    informationViewSnapshot.removeFromSuperview()
                    fromViewController.informationView.isHidden = false
                    toViewController.informationView.isHidden = false
                    toViewController.dismissButton.isHidden = false
                    
                    self.showViews()
                    self.removeSnapshotViews()
                    
                    if (transitionContext.transitionWasCancelled) {
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                    }
            })
            break
            
        case .pop:
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ConnectKitViewController
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! KitSelectorViewController
            toViewController.dismissButton.isHidden = true
            
            snapshotView(fromViewController.phoneImageView)
            snapshotView(fromViewController.dongleCableView)
            snapshotView(fromViewController.dongleCoilImageView)
            snapshotView(fromViewController.separatorLine)
            
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
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
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                informationViewSnapshot.frame = self.containerView.convert(fromViewController.informationView.frame, from: fromViewController.informationView.superview)
                self.fadeInSnapshots()
                self.fadeOutViews()
                
                }, completion: { (finished) -> Void in
                    informationViewSnapshot.removeFromSuperview()
                    fromViewController.informationView.isHidden = false
                    toViewController.informationView.isHidden = false
                    toViewController.dismissButton.isHidden = false
                    
                    self.showViews()
                    self.removeSnapshotViews()
                    
                    if (transitionContext.transitionWasCancelled) {
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                    }
            })

            break
        }
    }
}
