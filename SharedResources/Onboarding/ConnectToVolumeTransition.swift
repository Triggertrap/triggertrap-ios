//
//  ConnectToVolumeTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 30/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class ConnectToVolumeTransition: CustomTransition {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView
        
        switch state {
        case .push:
            
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ConnectKitViewController
            snapshotView(fromViewController.pageControl)
            
            // Create snapshots of the views that are going to change between the two view controllers
            
            let phoneSnapshot = createSnapshotView(fromViewController.phoneImageView)
            let plugedInViewFrame = fromViewController.plugedInView.frame
            let plugSnapshot = createSnapshotView(fromViewController.plugView)
            let dongleViewSnapshot = createSnapshotView(fromViewController.dongleView)
            let dongleCoilViewSnapshot = createSnapshotView(fromViewController.dongleCoilImageView)
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            let separatorLineSnapshot = createSnapshotView(fromViewController.separatorLine)
            
            // Create the cable using bezier path
            
            let pathView: DongleCableView = DongleCableView()
             pathView.bezierType = DongleCableView.BezierPathType.dongle
            pathView.frame = fromViewController.dongleCableView.frame
            
            let plugCenter = fromViewController.dongleCableView.convert(fromViewController.donglePlugImageView.center, from: fromViewController.plugView)
            let dongleCenter = fromViewController.dongleCableView.convert(fromViewController.dongleBodyTopImageView.center, from: fromViewController.dongleView)
            
            pathView.point1 = CGPoint(x: plugCenter.x, y: plugCenter.y + fromViewController.donglePlugImageView.frame.size.height / 2 + 2)
            pathView.point2 = CGPoint(x: dongleCenter.x, y: dongleCenter.y - fromViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
            pathView.addShapeLayer()
            
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! VolumeViewController
            
            // Alpha out the grey view controls
            
            fadeInView(toViewController.greyViewInformationLabel)
            fadeInView(toViewController.greyViewPraiseLabel)
            fadeInView(toViewController.pageControl)
            
            // Hide the phone and dongle views while transition is happening
            toViewController.phoneImageView.isHidden = true
            toViewController.dongleCableView.isHidden = true
            toViewController.informationView.isHidden = true
            toViewController.dongleCoilImageView.isHidden = true
            toViewController.dismissButton.isHidden = true
            toViewController.whiteViewDescriptionLabel.isHidden = true
            toViewController.whiteViewTitleLabel.isHidden = true
            
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            
            containerView.addSubview(toViewController.view)
            containerView.addSubview(pathView)
            containerView.addSubview(dongleViewSnapshot)
            containerView.addSubview(dongleCoilViewSnapshot)
            containerView.addSubview(plugSnapshot)
            containerView.addSubview(phoneSnapshot)
            containerView.addSubview(informationViewSnapshot)
            containerView.addSubview(separatorLineSnapshot)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            
            toViewController.view.layoutIfNeeded()
            
            /*
            UIView.animateKeyframesWithDuration(duration, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: { () -> Void in
                
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                    phoneSnapshot.frame = self.containerView.convertRect(fromViewController.phoneImageView.frame, fromView: fromViewController.phoneImageView.superview)
                    dongleViewSnapshot.frame = self.containerView.convertRect(fromViewController.dongleView.frame, fromView: fromViewController.dongleView.superview)
                    dongleCoilViewSnapshot.frame = self.containerView.convertRect(fromViewController.dongleCoilImageView.frame, fromView: fromViewController.dongleCoilImageView.superview)
                    plugSnapshot.frame = self.containerView.convertRect(plugedInViewFrame, fromView: fromViewController.plugedInView.superview)
                    informationViewSnapshot.frame = self.containerView.convertRect(fromViewController.informationView.frame, fromView: fromViewController.informationView.superview)
                    separatorLineSnapshot.frame = self.containerView.convertRect(fromViewController.separatorLine.frame, fromView: fromViewController.separatorLine.superview)
                    // Update path frame to follow from View controller dongle cable view

                    // Update path frame to follow from View controller dongle cable view
                    pathView.frame = self.containerView.convertRect(fromViewController.dongleCableView.frame, fromView: fromViewController.dongleCableView.superview)
                    
                    pathView.point1 = CGPoint(x: fromViewController.plugedInView.center.x, y: 52)
                    pathView.point2 = CGPoint(x: dongleCenter.x, y: dongleCenter.y - fromViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
                    pathView.animateShapeLayereWithDuration(self.duration)
                })
                
                UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                    
                    plugSnapshot.frame = self.containerView.convertRect(toViewController.plugView.frame, fromView: toViewController.plugView.superview)
                    dongleViewSnapshot.frame = self.containerView.convertRect(CGRect(x: toViewController.dongleView.frame.origin.x, y: toViewController.dongleView.frame.origin.y, width: dongleViewSnapshot.frame.size.width, height: dongleViewSnapshot.frame.size.height), fromView: toViewController.dongleView.superview)
                    phoneSnapshot.frame = self.containerView.convertRect(toViewController.phoneImageView.frame, fromView: toViewController.phoneImageView.superview)
                    informationViewSnapshot.frame = self.containerView.convertRect(toViewController.informationView.frame, fromView: toViewController.informationView.superview)
                    separatorLineSnapshot.frame = self.containerView.convertRect(toViewController.separatorLine.frame, fromView: toViewController.separatorLine.superview)
                    
                    dongleCoilViewSnapshot.frame = self.containerView.convertRect(toViewController.dongleCoilImageView.frame, fromView: toViewController.dongleCoilImageView.superview)
                    
                    // Get new frame for the path
                    pathView.frame = self.containerView.convertRect(toViewController.dongleCableView.frame, fromView: toViewController.dongleCableView.superview)
                    
                    // Update points to the new position
                    pathView.point1 = CGPoint(x: toViewController.plugView.center.x, y: 52)
                    pathView.point2 = CGPoint(x: toViewController.dongleView.frame.origin.x + toViewController.dongleView.frame.size.width - toViewController.donglePlugImageView.frame.size.width / 2 - 5 , y: toViewController.dongleView.frame.origin.y - 2)
                    
                    // Animate the shape layer of the path again to
                    pathView.animateShapeLayereWithDuration(self.duration)
                        
                    self.fadeInSnapshots()
                    self.fadeOutViews()

                })
                
                }, completion: { (finished) -> Void in
                    
                    fromViewController.dongleCoilImageView.hidden = false
                    fromViewController.phoneImageView.hidden = false
                    fromViewController.dongleCableView.hidden = false
                    fromViewController.informationView.hidden = false
                    fromViewController.separatorLine.hidden = false
                    fromViewController.dongleView.hidden = false
                    fromViewController.plugView.hidden = false
                    
                    toViewController.dongleCoilImageView.hidden = false
                    toViewController.phoneImageView.hidden = false
                    toViewController.dongleCableView.hidden = false
                    toViewController.informationView.hidden = false
                    toViewController.dismissButton.hidden = false
                    toViewController.whiteViewDescriptionLabel.hidden = false
                    toViewController.whiteViewTitleLabel.hidden = false
                    
                    dongleCoilViewSnapshot.removeFromSuperview()
                    dongleViewSnapshot.removeFromSuperview()
                    plugSnapshot.removeFromSuperview()
                    phoneSnapshot.removeFromSuperview()
                    plugSnapshot.removeFromSuperview()
                    informationViewSnapshot.removeFromSuperview()
                    separatorLineSnapshot.removeFromSuperview()
                    pathView.removeFromSuperview()
                    
                    self.showViews()
                    self.removeSnapshotViews()
                    
                    if (transitionContext.transitionWasCancelled()) {
                        transitionContext.completeTransition(false)
                    } else {
                        transitionContext.completeTransition(true)
                    }
            })
            */
            UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                phoneSnapshot.frame = self.containerView.convert(fromViewController.phoneImageView.frame, from: fromViewController.phoneImageView.superview)
                dongleViewSnapshot.frame = self.containerView.convert(fromViewController.dongleView.frame, from: fromViewController.dongleView.superview)
                dongleCoilViewSnapshot.frame = self.containerView.convert(fromViewController.dongleCoilImageView.frame, from: fromViewController.dongleCoilImageView.superview)
                plugSnapshot.frame = self.containerView.convert(plugedInViewFrame, from: fromViewController.plugedInView.superview)
                informationViewSnapshot.frame = self.containerView.convert(fromViewController.informationView.frame, from: fromViewController.informationView.superview)
                separatorLineSnapshot.frame = self.containerView.convert(fromViewController.separatorLine.frame, from: fromViewController.separatorLine.superview)
                
                // Update path frame to follow from View controller dongle cable view
                pathView.frame = self.containerView.convert(fromViewController.dongleCableView.frame, from: fromViewController.dongleCableView.superview)
                
                pathView.point1 = CGPoint(x: fromViewController.plugedInView.center.x, y: 52)
                pathView.point2 = CGPoint(x: dongleCenter.x, y: dongleCenter.y - fromViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
                pathView.animateShapeLayereWithDuration(self.duration)
                
            }, completion: { (finished) -> Void in
                
                // Initial animation has been canceled
                if (self.transitionContext!.transitionWasCancelled) {
                    
                    fromViewController.dongleCoilImageView.isHidden = false
                    fromViewController.phoneImageView.isHidden = false
                    fromViewController.dongleCableView.isHidden = false
                    fromViewController.informationView.isHidden = false
                    fromViewController.separatorLine.isHidden = false
                    fromViewController.dongleView.isHidden = false
                    fromViewController.plugView.isHidden = false
                    
                    toViewController.dongleCoilImageView.isHidden = false
                    toViewController.phoneImageView.isHidden = false
                    toViewController.dongleCableView.isHidden = false
                    toViewController.informationView.isHidden = false
                    toViewController.dismissButton.isHidden = false
                    toViewController.whiteViewDescriptionLabel.isHidden = false
                    toViewController.whiteViewTitleLabel.isHidden = false
                    
                    dongleCoilViewSnapshot.removeFromSuperview()
                    dongleViewSnapshot.removeFromSuperview()
                    plugSnapshot.removeFromSuperview()
                    phoneSnapshot.removeFromSuperview()
                    plugSnapshot.removeFromSuperview()
                    informationViewSnapshot.removeFromSuperview()
                    separatorLineSnapshot.removeFromSuperview()
                    pathView.removeFromSuperview()
                    
                    self.showViews()
                    self.removeSnapshotViews()
                    
                    self.transitionContext!.completeTransition(false)
                } else {
                    UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                        
                        plugSnapshot.frame = self.containerView.convert(toViewController.plugView.frame, from: toViewController.plugView.superview)
                        dongleViewSnapshot.frame = self.containerView.convert(CGRect(x: toViewController.dongleView.frame.origin.x, y: toViewController.dongleView.frame.origin.y, width: dongleViewSnapshot.frame.size.width, height: dongleViewSnapshot.frame.size.height), from: toViewController.dongleView.superview)
                        phoneSnapshot.frame = self.containerView.convert(toViewController.phoneImageView.frame, from: toViewController.phoneImageView.superview)
                        informationViewSnapshot.frame = self.containerView.convert(toViewController.informationView.frame, from: toViewController.informationView.superview)
                        separatorLineSnapshot.frame = self.containerView.convert(toViewController.separatorLine.frame, from: toViewController.separatorLine.superview)
                        
                        dongleCoilViewSnapshot.frame = self.containerView.convert(toViewController.dongleCoilImageView.frame, from: toViewController.dongleCoilImageView.superview)
                        
                        // Get new frame for the path
                        pathView.frame = self.containerView.convert(toViewController.dongleCableView.frame, from: toViewController.dongleCableView.superview)
                        
                        // Update points to the new position
                        pathView.point1 = CGPoint(x: toViewController.plugView.center.x, y: 52)
                        pathView.point2 = CGPoint(x: toViewController.dongleView.frame.origin.x + toViewController.dongleView.frame.size.width - toViewController.donglePlugImageView.frame.size.width / 2 - 5 , y: toViewController.dongleView.frame.origin.y - 2)
                        
                        // Animate the shape layer of the path again to
                        pathView.animateShapeLayereWithDuration(self.duration)
                        
                        self.fadeInSnapshots()
                        self.fadeOutViews()
                        
                        }, completion: { (ended) -> Void in
                            
                            fromViewController.dongleCoilImageView.isHidden = false
                            fromViewController.phoneImageView.isHidden = false
                            fromViewController.dongleCableView.isHidden = false
                            fromViewController.informationView.isHidden = false
                            fromViewController.separatorLine.isHidden = false
                            fromViewController.dongleView.isHidden = false
                            fromViewController.plugView.isHidden = false
                            
                            toViewController.dismissButton.isHidden = false
                            toViewController.dongleCoilImageView.isHidden = false
                            toViewController.phoneImageView.isHidden = false
                            toViewController.dongleCableView.isHidden = false
                            toViewController.informationView.isHidden = false
                            toViewController.whiteViewDescriptionLabel.isHidden = false
                            toViewController.whiteViewTitleLabel.isHidden = false
                            
                            dongleCoilViewSnapshot.removeFromSuperview()
                            dongleViewSnapshot.removeFromSuperview()
                            plugSnapshot.removeFromSuperview()
                            phoneSnapshot.removeFromSuperview()
                            plugSnapshot.removeFromSuperview()
                            informationViewSnapshot.removeFromSuperview()
                            separatorLineSnapshot.removeFromSuperview()
                            pathView.removeFromSuperview()
                            
                            self.showViews()
                            self.removeSnapshotViews()
                            
                            if (self.transitionContext!.transitionWasCancelled) {
                                self.transitionContext!.completeTransition(false)
                            } else {
                                self.transitionContext!.completeTransition(true)
                            }
                    })
                }
             })

            break
            
        case .pop:
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! VolumeViewController
            
            // Snapshots
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            let phoneImageSnapshot = createSnapshotView(fromViewController.phoneImageView)
            let plugViewSnapshot = createSnapshotView(fromViewController.plugView)
            let dongleViewSnapshot = createSnapshotView(fromViewController.dongleView)
            let dongleCoilViewSnapshot = createSnapshotView(fromViewController.dongleCoilImageView)
            let separatorLineSnapshot = createSnapshotView(fromViewController.separatorLine)
            
            let pathView: DongleCableView = DongleCableView(frame: fromViewController.dongleCableView.frame)
            pathView.bezierType = DongleCableView.BezierPathType.dongle
            
            let plugCenter = fromViewController.dongleCableView.convert(fromViewController.donglePlugImageView.center, from: fromViewController.plugView)
            let dongleCenter = fromViewController.dongleCableView.convert(fromViewController.dongleBodyTopImageView.center, from: fromViewController.dongleView)
            
            pathView.point1 = CGPoint(x: plugCenter.x, y: plugCenter.y + fromViewController.donglePlugImageView.frame.size.height / 2 + 2)
            pathView.point2 = CGPoint(x: dongleCenter.x, y: dongleCenter.y - fromViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
            pathView.addShapeLayer()
            
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ConnectKitViewController
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            
            toViewController.dismissButton.isHidden = true
            toViewController.phoneImageView.isHidden = true
            toViewController.dongleView.isHidden = true
            toViewController.plugView.isHidden = true
            toViewController.informationView.isHidden = true
            toViewController.dongleCableView.isHidden = true
            toViewController.dongleCoilImageView.isHidden = true
            
            containerView.addSubview(toViewController.view)
            containerView.addSubview(pathView)
            containerView.addSubview(plugViewSnapshot)
            containerView.addSubview(dongleViewSnapshot)
            containerView.addSubview(dongleCoilViewSnapshot)
            containerView.addSubview(phoneImageSnapshot)
            containerView.addSubview(informationViewSnapshot)
            containerView.addSubview(separatorLineSnapshot)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            
            toViewController.view.layoutIfNeeded()
            
            UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                
                // Move plug and phone to the top of the screen
                
                phoneImageSnapshot.frame = self.containerView.convert(toViewController.phoneImageView.frame, from: toViewController.phoneImageView.superview)
                dongleViewSnapshot.frame = self.containerView.convert(toViewController.dongleView.frame, from: toViewController.dongleView.superview)
                dongleCoilViewSnapshot.frame = self.containerView.convert(toViewController.dongleCoilImageView.frame, from: toViewController.dongleCoilImageView.superview)
                plugViewSnapshot.frame = self.containerView.convert(toViewController.plugedInView.frame, from: toViewController.plugedInView.superview)
                informationViewSnapshot.frame = self.containerView.convert(toViewController.informationView.frame, from: toViewController.informationView.superview)
                separatorLineSnapshot.frame = self.containerView.convert(toViewController.separatorLine.frame, from: toViewController.separatorLine.superview)
                
                // Update path frame to follow from View controller dongle cable view
                
                pathView.frame = self.containerView.convert(toViewController.dongleCableView.frame, from: toViewController.dongleCableView.superview)
                
                pathView.point1 = CGPoint(x: toViewController.plugedInView.center.x, y: 52)
                pathView.point2 = CGPoint(x: toViewController.dongleCableView.convert(toViewController.dongleBodyTopImageView.center, from: toViewController.dongleView).x, y: toViewController.dongleCableView.convert(toViewController.dongleBodyTopImageView.center, from: toViewController.dongleView).y - toViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
                
                pathView.animateShapeLayereWithDuration(self.duration)
                
                }, completion: { (finished) -> Void in
                    // Initial animation has been canceled
                    if (self.transitionContext!.transitionWasCancelled) {
                        
                        fromViewController.dongleCoilImageView.isHidden = false
                        fromViewController.phoneImageView.isHidden = false
                        fromViewController.dongleCableView.isHidden = false
                        fromViewController.informationView.isHidden = false
                        fromViewController.separatorLine.isHidden = false
                        fromViewController.dongleView.isHidden = false
                        fromViewController.plugView.isHidden = false
                        
                        toViewController.dismissButton.isHidden = false
                        toViewController.dongleCoilImageView.isHidden = false
                        toViewController.phoneImageView.isHidden = false
                        toViewController.dongleView.isHidden = false
                        toViewController.plugView.isHidden = false
                        toViewController.informationView.isHidden = false
                        toViewController.dongleCableView.isHidden = false
                        
                        dongleCoilViewSnapshot.removeFromSuperview()
                        informationViewSnapshot.removeFromSuperview()
                        phoneImageSnapshot.removeFromSuperview()
                        plugViewSnapshot.removeFromSuperview()
                        dongleViewSnapshot.removeFromSuperview()
                        informationViewSnapshot.removeFromSuperview()
                        separatorLineSnapshot.removeFromSuperview()
                        pathView.removeFromSuperview()
                        
                        self.showViews()
                        self.removeSnapshotViews()
                        
                        self.transitionContext!.completeTransition(false)
                    } else {
                        
                        UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                            
                            // Unplug dongle from phone
                            plugViewSnapshot.frame = self.containerView.convert(toViewController.plugView.frame, from: toViewController.plugView.superview)
                            
                            pathView.frame = self.containerView.convert(toViewController.dongleCableView.frame, from: fromViewController.dongleCableView.superview)
                            
                            pathView.point1 = CGPoint(x: toViewController.plugView.center.x, y: toViewController.plugView.frame.origin.y + toViewController.plugView.frame.size.height + 2)
                            pathView.point2 = CGPoint(x: toViewController.dongleCableView.convert(toViewController.dongleBodyTopImageView.center, from: toViewController.dongleView).x, y: toViewController.dongleCableView.convert(toViewController.dongleBodyTopImageView.center, from: toViewController.dongleView).y - toViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
                            
                            pathView.animateShapeLayereWithDuration(self.duration)
                            
                            self.fadeInSnapshots()
                            self.fadeOutViews()
                            
                            }, completion: { (ended) -> Void in
                                
                                fromViewController.dongleCoilImageView.isHidden = false
                                fromViewController.phoneImageView.isHidden = false
                                fromViewController.dongleCableView.isHidden = false
                                fromViewController.informationView.isHidden = false
                                fromViewController.separatorLine.isHidden = false
                                fromViewController.dongleView.isHidden = false
                                fromViewController.plugView.isHidden = false
                                
                                toViewController.dismissButton.isHidden = false
                                toViewController.dongleCoilImageView.isHidden = false
                                toViewController.phoneImageView.isHidden = false
                                toViewController.dongleView.isHidden = false
                                toViewController.plugView.isHidden = false
                                toViewController.informationView.isHidden = false
                                toViewController.dongleCableView.isHidden = false
                                
                                dongleCoilViewSnapshot.removeFromSuperview()
                                informationViewSnapshot.removeFromSuperview()
                                phoneImageSnapshot.removeFromSuperview()
                                plugViewSnapshot.removeFromSuperview()
                                dongleViewSnapshot.removeFromSuperview()
                                informationViewSnapshot.removeFromSuperview()
                                separatorLineSnapshot.removeFromSuperview()
                                pathView.removeFromSuperview()
                                
                                
                                self.showViews()
                                self.removeSnapshotViews()
                                
                                if (self.transitionContext!.transitionWasCancelled) {
                                    self.transitionContext!.completeTransition(false)
                                } else {
                                    self.transitionContext!.completeTransition(true)
                                }
                        })
                    }
            })
            break
        }
    }
}
