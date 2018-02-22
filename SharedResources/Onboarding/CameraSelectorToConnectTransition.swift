//
//  CameraSelectorToConnectTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 28/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class CameraSelectorToConnectTransition: CustomTransition {  
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView
        
        switch state {
        case .push:
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! CameraSelectorViewController
            snapshotView(fromViewController.greyViewInformationLabel)
            snapshotView(fromViewController.greyViewPraiseLabel)
            snapshotView(fromViewController.whiteView)
            snapshotView(fromViewController.separatorLine)
            snapshotView(fromViewController.pageControl)
            
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ConnectKitViewController
            
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
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! CameraSelectorViewController
            toViewController.dismissButton.isHidden = true
            
            snapshotView(fromViewController.phoneImageView)
            snapshotView(fromViewController.dongleCableView)
            snapshotView(fromViewController.dongleCoilImageView)
            snapshotView(fromViewController.separatorLine)
            snapshotView(fromViewController.informationView)
            
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            fadeInView(toViewController.whiteView)
            fadeInView(toViewController.greyViewInformationLabel)
            fadeInView(toViewController.greyViewPraiseLabel)
            
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
