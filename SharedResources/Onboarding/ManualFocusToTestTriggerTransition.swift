//
//  ManualFocusToTestTriggerTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 06/02/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class ManualFocusToTestTriggerTransition: CustomTransition {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView
        
        switch state {
        case .push:
            
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ManualFocusViewController
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! TestTriggertViewController
            
            snapshotView(fromViewController.phoneImageView)
            snapshotView(fromViewController.dongleCableView)
            snapshotView(fromViewController.cameraCableView)
            snapshotView(fromViewController.cameraView)
            snapshotView(fromViewController.popoutShapeView)
            snapshotView(fromViewController.greyViewInformationLabel)
            snapshotView(fromViewController.greyViewPraiseLabel)
            
            fromViewController.informationView.isHidden = true
            
            let redView: UIView = UIView(frame: CGRect(x: 0, y: -toViewController.triggertrapView.frame.height, width: fromViewController.view.frame.width, height: toViewController.triggertrapView.frame.height))
            redView.backgroundColor = UIColor(hex: 0xE2231A, alpha: 1.0)
            
            let triggertrapLabel = UILabel()
            triggertrapLabel.font = UIFont.triggertrap_metric_light(24)
            triggertrapLabel.textAlignment = NSTextAlignment.center
            triggertrapLabel.textColor = UIColor.white
            triggertrapLabel.text = "Triggertrap"
            triggertrapLabel.alpha = 0
            redView.addSubview(triggertrapLabel)
            
            triggertrapLabel.translatesAutoresizingMaskIntoConstraints = false
            
            redView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[triggertrapLabel(42)]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["triggertrapLabel": triggertrapLabel]))
            
            redView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(8)-[triggertrapLabel]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["triggertrapLabel": triggertrapLabel]))
            
            let informationViewSnapshot: UIView = UIView(frame: fromViewController.informationView.frame)
            informationViewSnapshot.backgroundColor = fromViewController.informationView.backgroundColor
            
            let separatorLineSnapshot = createSnapshotView(fromViewController.separatorLine)
            let pageControlSnapshot = createSnapshotView(fromViewController.pageControl)
//            let labelsOffset = toViewController.bottomRightView.frame.origin.y - fromViewController.informationView.frame.origin.y
            
            fadeInView(toViewController.topLeftView)
            
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            toViewController.bottomRightView.isHidden = true
            toViewController.separatorLine.isHidden = true
            toViewController.triggertrapView.isHidden = true
            
            containerView.addSubview(toViewController.view)
            
            containerView.addSubview(informationViewSnapshot)
            containerView.addSubview(pageControlSnapshot)
            containerView.addSubview(separatorLineSnapshot)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            
            containerView.addSubview(redView)
            
            toViewController.view.layoutIfNeeded()
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                
                informationViewSnapshot.frame = self.containerView.convert(toViewController.bottomRightView.frame, from: toViewController.bottomRightView.superview)
                
                separatorLineSnapshot.frame = self.containerView.convert(toViewController.separatorLine.frame, from: toViewController.separatorLine.superview)
                
                triggertrapLabel.alpha = 1
                
                redView.frame = CGRect(x: 0, y: 0, width: toViewController.triggertrapView.frame.width, height: toViewController.triggertrapView.frame.height)
                
                self.fadeInSnapshots()
                self.fadeOutViews()
                
                }, completion: { (finished) -> Void in
                    
                    fromViewController.separatorLine.isHidden = false
                    fromViewController.pageControl.isHidden = false
                    fromViewController.informationView.isHidden = false
                    
                    toViewController.bottomRightView.isHidden = false
                    toViewController.triggertrapView.isHidden = false
                    toViewController.separatorLine.isHidden = false
                    
                    redView.removeFromSuperview()
                    informationViewSnapshot.removeFromSuperview()
                    separatorLineSnapshot.removeFromSuperview()
                    pageControlSnapshot.removeFromSuperview()
                    
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
            
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! TestTriggertViewController
            snapshotView(fromViewController.topLeftView)
            
            let informationViewSnapshot = UIView(frame:containerView.convert(fromViewController.bottomRightView.frame, from: fromViewController.bottomRightView.superview))
            
            informationViewSnapshot.backgroundColor = fromViewController.bottomRightView.backgroundColor
            fromViewController.bottomRightView.isHidden = true
            
            let redView = createSnapshotView(fromViewController.triggertrapView)
            fromViewController.triggertrapView.isHidden = true
            
            let pageControlSnapshot = createSnapshotView(fromViewController.pageControl)
            
            let separatorLine = createSnapshotView(fromViewController.separatorLine)
            
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ManualFocusViewController
            
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            
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
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                
                informationViewSnapshot.frame = self.containerView.convert(toViewController.informationView.frame, from: toViewController.informationView.superview)
                
                separatorLine.frame = self.containerView.convert(toViewController.separatorLine.frame, from: toViewController.separatorLine.superview)
                
                
                redView.frame = CGRect(x: 0, y: -64, width: redView.frame.width, height: redView.frame.height)
                
                self.fadeInSnapshots()
                self.fadeOutViews()
                
                }, completion: { (finished) -> Void in
                    
                    fromViewController.bottomRightView.isHidden = false
                    fromViewController.triggertrapView.isHidden = false
                    fromViewController.separatorLine.isHidden = false
                    fromViewController.pageControl.isHidden = false
                    
                    toViewController.informationView.isHidden = false
                    toViewController.separatorLine.isHidden = false
                    
                    informationViewSnapshot.removeFromSuperview()
                    separatorLine.removeFromSuperview()
                    pageControlSnapshot.removeFromSuperview()
                    redView.removeFromSuperview()
                    
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
