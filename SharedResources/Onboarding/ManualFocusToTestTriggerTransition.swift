//
//  ManualFocusToTestTriggerTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 06/02/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class ManualFocusToTestTriggerTransition: CustomTransition {
    
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView()
        
        switch state {
        case .Push:
            
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! ManualFocusViewController
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! TestTriggertViewController
            
            snapshotView(fromViewController.phoneImageView)
            snapshotView(fromViewController.dongleCableView)
            snapshotView(fromViewController.cameraCableView)
            snapshotView(fromViewController.cameraView)
            snapshotView(fromViewController.popoutShapeView)
            snapshotView(fromViewController.greyViewInformationLabel)
            snapshotView(fromViewController.greyViewPraiseLabel)
            
            fromViewController.informationView.hidden = true
            
            let redView: UIView = UIView(frame: CGRect(x: 0, y: -toViewController.triggertrapView.frame.height, width: fromViewController.view.frame.width, height: toViewController.triggertrapView.frame.height))
            redView.backgroundColor = UIColor(hex: 0xE2231A, alpha: 1.0)
            
            let triggertrapLabel = UILabel()
            triggertrapLabel.font = UIFont.triggertrap_metric_light(24)
            triggertrapLabel.textAlignment = NSTextAlignment.Center
            triggertrapLabel.textColor = UIColor.whiteColor()
            triggertrapLabel.text = "Triggertrap"
            triggertrapLabel.alpha = 0
            redView.addSubview(triggertrapLabel)
            
            triggertrapLabel.translatesAutoresizingMaskIntoConstraints = false
            
            redView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[triggertrapLabel(42)]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["triggertrapLabel": triggertrapLabel]))
            
            redView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(8)-[triggertrapLabel]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["triggertrapLabel": triggertrapLabel]))
            
            let informationViewSnapshot: UIView = UIView(frame: fromViewController.informationView.frame)
            informationViewSnapshot.backgroundColor = fromViewController.informationView.backgroundColor
            
            let separatorLineSnapshot = createSnapshotView(fromViewController.separatorLine)
            let pageControlSnapshot = createSnapshotView(fromViewController.pageControl)
//            let labelsOffset = toViewController.bottomRightView.frame.origin.y - fromViewController.informationView.frame.origin.y
            
            fadeInView(toViewController.topLeftView)
            
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            toViewController.bottomRightView.hidden = true
            toViewController.separatorLine.hidden = true
            toViewController.triggertrapView.hidden = true
            
            containerView.addSubview(toViewController.view)
            
            containerView.addSubview(informationViewSnapshot)
            containerView.addSubview(pageControlSnapshot)
            containerView.addSubview(separatorLineSnapshot)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            
            containerView.addSubview(redView)
            
            toViewController.view.layoutIfNeeded()
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                
                informationViewSnapshot.frame = self.containerView.convertRect(toViewController.bottomRightView.frame, fromView: toViewController.bottomRightView.superview)
                
                separatorLineSnapshot.frame = self.containerView.convertRect(toViewController.separatorLine.frame, fromView: toViewController.separatorLine.superview)
                
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
                
                triggertrapLabel.alpha = 1
                
                redView.frame = CGRect(x: 0, y: 0, width: toViewController.triggertrapView.frame.width, height: toViewController.triggertrapView.frame.height)
                
                self.fadeInSnapshots()
                self.fadeOutViews()
                
                }, completion: { (finished) -> Void in
                    
                    fromViewController.separatorLine.hidden = false
                    fromViewController.pageControl.hidden = false
                    fromViewController.informationView.hidden = false
                    
                    toViewController.bottomRightView.hidden = false
                    toViewController.triggertrapView.hidden = false
                    toViewController.separatorLine.hidden = false
                    
                    redView.removeFromSuperview()
                    informationViewSnapshot.removeFromSuperview()
                    separatorLineSnapshot.removeFromSuperview()
                    pageControlSnapshot.removeFromSuperview()
                    
                    self.showViews()
                    self.removeSnapshotViews()
                    
                    if (transitionContext.transitionWasCancelled()) {
                        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                    }
            })

            break
            
        case .Pop:
            
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! TestTriggertViewController
            snapshotView(fromViewController.topLeftView)
            
            let informationViewSnapshot = UIView(frame:containerView.convertRect(fromViewController.bottomRightView.frame, fromView: fromViewController.bottomRightView.superview))
            
            informationViewSnapshot.backgroundColor = fromViewController.bottomRightView.backgroundColor
            fromViewController.bottomRightView.hidden = true
            
            let redView = createSnapshotView(fromViewController.triggertrapView)
            fromViewController.triggertrapView.hidden = true
            
            let pageControlSnapshot = createSnapshotView(fromViewController.pageControl)
            
            let separatorLine = createSnapshotView(fromViewController.separatorLine)
            
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ManualFocusViewController
            
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            
            fadeInView(toViewController.phoneImageView)
            fadeInView(toViewController.dongleCableView)
            fadeInView(toViewController.cameraCableView)
            fadeInView(toViewController.cameraView)
            fadeInView(toViewController.popoutShapeView)
            fadeInView(toViewController.greyViewInformationLabel)
            fadeInView(toViewController.greyViewPraiseLabel)
            
            containerView.addSubview(toViewController.view)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            
            containerView.addSubview(informationViewSnapshot)
            containerView.addSubview(pageControlSnapshot)
            containerView.addSubview(separatorLine)
            
            containerView.addSubview(redView)
            
            toViewController.view.layoutIfNeeded()
            toViewController.navigationItem.setHidesBackButton(true, animated: false)
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                
                informationViewSnapshot.frame = self.containerView.convertRect(toViewController.informationView.frame, fromView: toViewController.informationView.superview)
                
                separatorLine.frame = self.containerView.convertRect(toViewController.separatorLine.frame, fromView: toViewController.separatorLine.superview)
                
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
                
                redView.frame = CGRect(x: 0, y: -64, width: redView.frame.width, height: redView.frame.height)
                
                self.fadeInSnapshots()
                self.fadeOutViews()
                
                }, completion: { (finished) -> Void in
                    
                    fromViewController.bottomRightView.hidden = false
                    fromViewController.triggertrapView.hidden = false
                    fromViewController.separatorLine.hidden = false
                    fromViewController.pageControl.hidden = false
                    
                    toViewController.informationView.hidden = false
                    toViewController.separatorLine.hidden = false
                    
                    informationViewSnapshot.removeFromSuperview()
                    separatorLine.removeFromSuperview()
                    pageControlSnapshot.removeFromSuperview()
                    redView.removeFromSuperview()
                    
                    self.showViews()
                    self.removeSnapshotViews()
                    
                    if (transitionContext.transitionWasCancelled()) {
                        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                    }
            })
            
            break 
        }
    }
}
