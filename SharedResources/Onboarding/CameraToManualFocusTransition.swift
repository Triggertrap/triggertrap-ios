//
//  CameraToManualFocus.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 05/02/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class CameraToManualFocusTransition: CustomTransition {
    
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView()
        
        switch state {
        case .Push:
            
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! CameraViewController
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ManualFocusViewController
            
            let phoneSnapshot = createSnapshotView(fromViewController.phoneImageView)
            let dongleCableViewSnapshot = createSnapshotView(fromViewController.dongleCableView)
            let cameraViewSnapshot = createSnapshotView(fromViewController.cameraView)
            let cameraConnectorSnapshot = createSnapshotView(fromViewController.cameraConnectorView)
            let dongleCoilSnapshot = createSnapshotView(fromViewController.dongleCoilImageView)
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            let separatorLineSnapshot = createSnapshotView(fromViewController.separatorLine)
            
            // Camera cable bezier path
            let plugedInViewFrame = fromViewController.pluggedView.frame
            
            let pathView: DongleCableView = DongleCableView()
            pathView.frame = fromViewController.cameraCableView.frame
            
            let plugCenter = fromViewController.cameraCableView.convertPoint(fromViewController.cameraConnectorBodyImageView.center, fromView: fromViewController.cameraConnectorView)
            let dongleCenter = fromViewController.dongleCoilImageView.convertPoint(fromViewController.dongleCoilImageView.frame.origin, fromView: fromViewController.dongleCoilImageView)
            
            pathView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + fromViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            pathView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + fromViewController.dongleCoilImageView.frame.size.height - 6)
            pathView.bezierType = DongleCableView.BezierPathType.Camera
            
            pathView.addShapeLayer()
            
            // Hide the phone and dongle views while transition is happening
            toViewController.phoneImageView.hidden = true
            toViewController.dongleCableView.hidden = true
            toViewController.cameraCableView.hidden = true
            toViewController.informationView.hidden = true
            toViewController.cameraView.hidden = true
            toViewController.popoutShapeView.hidden = true
            toViewController.dismissButton.hidden = true
            
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            
            containerView.addSubview(toViewController.view)
            containerView.addSubview(pathView)
            containerView.addSubview(cameraConnectorSnapshot)
            containerView.addSubview(dongleCableViewSnapshot)
            containerView.addSubview(dongleCoilSnapshot)
            containerView.addSubview(phoneSnapshot)
            containerView.addSubview(cameraViewSnapshot)
            containerView.addSubview(informationViewSnapshot)
            containerView.addSubview(separatorLineSnapshot)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            
            toViewController.view.layoutIfNeeded()
            
            UIView.animateWithDuration(self.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                cameraConnectorSnapshot.frame = self.containerView.convertRect(plugedInViewFrame, fromView: fromViewController.pluggedView.superview)
                
                // Update path frame to follow from View controller dongle cable view
                pathView.frame = self.containerView.convertRect(fromViewController.cameraCableView.frame, fromView: fromViewController.cameraCableView.superview)
                
                pathView.point1 = CGPoint(x: 22, y: fromViewController.pluggedView.center.y + fromViewController.pluggedView.frame.size.height / 2)
                
                pathView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + fromViewController.dongleCoilImageView.frame.size.height - 6)
                
                pathView.animateShapeLayereWithDuration(self.duration)
                
                }, completion: { (finished) -> Void in
                    
                    // Initial animation has been canceled
                    if (self.transitionContext!.transitionWasCancelled()) {
                        
                        pathView.removeFromSuperview()
                        cameraViewSnapshot.removeFromSuperview()
                        phoneSnapshot.removeFromSuperview()
                        dongleCableViewSnapshot.removeFromSuperview()
                        cameraConnectorSnapshot.removeFromSuperview()
                        informationViewSnapshot.removeFromSuperview()
                        separatorLineSnapshot.removeFromSuperview()
                        dongleCoilSnapshot.removeFromSuperview()
                        
                        fromViewController.dongleCoilImageView.hidden = false
                        fromViewController.phoneImageView.hidden = false
                        fromViewController.dongleCableView.hidden = false
                        fromViewController.informationView.hidden = false
                        fromViewController.separatorLine.hidden = false
                        fromViewController.cameraView.hidden = false
                        fromViewController.plugView.hidden = false
                        fromViewController.cameraConnectorView.hidden = false
                        
                        toViewController.popoutShapeView.hidden = false
                        toViewController.phoneImageView.hidden = false
                        toViewController.dongleCableView.hidden = false
                        toViewController.cameraCableView.hidden = false
                        toViewController.informationView.hidden = false
                        toViewController.cameraView.hidden = false
                        toViewController.dismissButton.hidden = false
                        
                        self.transitionContext!.completeTransition(false)
                    } else {
                        UIView.animateWithDuration(self.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                            
                            phoneSnapshot.frame = self.containerView.convertRect(toViewController.phoneImageView.frame, fromView: toViewController.phoneImageView.superview)
                            dongleCableViewSnapshot.frame = self.containerView.convertRect(toViewController.dongleCableView.frame, fromView: toViewController.dongleCableView.superview)
                            cameraViewSnapshot.frame = self.containerView.convertRect(toViewController.cameraView.frame, fromView: toViewController.cameraView.superview)
                            cameraConnectorSnapshot.frame = self.containerView.convertRect(toViewController.cameraConnectorView.frame, fromView: toViewController.cameraConnectorView.superview)
                            dongleCoilSnapshot.frame = self.containerView.convertRect(toViewController.dongleCoilImageView.frame, fromView: toViewController.dongleCoilImageView.superview)
                            informationViewSnapshot.frame = self.containerView.convertRect(toViewController.informationView.frame, fromView: toViewController.informationView.superview)
                            separatorLineSnapshot.frame = self.containerView.convertRect(toViewController.separatorLine.frame, fromView: toViewController.separatorLine.superview)
                            
                            // Get new frame for the path
                            pathView.frame = self.containerView.convertRect(toViewController.cameraCableView.frame, fromView: toViewController.cameraCableView.superview)
                            
                            let plugCenter = toViewController.cameraCableView.convertPoint(toViewController.cameraConnectorBodyImageView.center, fromView: toViewController.cameraConnectorView)
                            
                            pathView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + toViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
                            pathView.point2 = CGPoint(x: toViewController.dongleCoilImageView.frame.origin.x + 6, y: toViewController.dongleCoilImageView.frame.origin.y + toViewController.dongleCoilImageView.frame.size.height - 6)
                            
                            // Animate the shape layer of the path again to
                            pathView.animateShapeLayereWithDuration(self.duration)
                            
                            self.fadeInSnapshots()
                            self.fadeOutViews()
                            
                            }, completion: { (ended) -> Void in

                                pathView.removeFromSuperview()
                                phoneSnapshot.removeFromSuperview()
                                dongleCableViewSnapshot.removeFromSuperview()
                                cameraViewSnapshot.removeFromSuperview()
                                cameraConnectorSnapshot.removeFromSuperview()
                                informationViewSnapshot.removeFromSuperview()
                                separatorLineSnapshot.removeFromSuperview()
                                dongleCoilSnapshot.removeFromSuperview()
                                
                                fromViewController.dongleCoilImageView.hidden = false
                                fromViewController.phoneImageView.hidden = false
                                fromViewController.dongleCableView.hidden = false
                                fromViewController.informationView.hidden = false
                                fromViewController.separatorLine.hidden = false
                                fromViewController.cameraView.hidden = false
                                fromViewController.plugView.hidden = false
                                fromViewController.cameraConnectorView.hidden = false
                                
                                toViewController.dismissButton.hidden = false
                                toViewController.popoutShapeView.hidden = false
                                toViewController.phoneImageView.hidden = false
                                toViewController.dongleCableView.hidden = false
                                toViewController.cameraCableView.hidden = false
                                toViewController.informationView.hidden = false
                                toViewController.cameraView.hidden = false

                                self.showViews()
                                self.removeSnapshotViews()
                                
                                if (self.transitionContext!.transitionWasCancelled()) {
                                    self.transitionContext!.completeTransition(false)
                                } else {
                                    self.transitionContext!.completeTransition(true)
                                }
                        })
                    }
            })

            break
            
        case .Pop:
            
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! ManualFocusViewController
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! CameraViewController
            
            let phoneSnapshot = createSnapshotView(fromViewController.phoneImageView)
            let dongleCableViewSnapshot = createSnapshotView(fromViewController.dongleCableView)
            let cameraViewSnapshot = createSnapshotView(fromViewController.cameraView)
            let cameraConnectorSnapshot = createSnapshotView(fromViewController.cameraConnectorView)
            let dongleCoilSnapshot = createSnapshotView(fromViewController.dongleCoilImageView)
            let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
            let separatorLineSnapshot = createSnapshotView(fromViewController.separatorLine)
            
            // Camera cable bezier path
            
            let pathView: DongleCableView = DongleCableView()
            pathView.frame = fromViewController.cameraCableView.frame
            
            let plugCenter = fromViewController.cameraCableView.convertPoint(fromViewController.cameraConnectorBodyImageView.center, fromView: fromViewController.cameraConnectorView)
            
            pathView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + fromViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            pathView.point2 = CGPoint(x: fromViewController.dongleCoilImageView.frame.origin.x + 6, y: fromViewController.dongleCoilImageView.frame.origin.y + fromViewController.dongleCoilImageView.frame.size.height - 6)
            
            pathView.bezierType = DongleCableView.BezierPathType.Camera
            pathView.addShapeLayer()
            
            // Hide the phone and dongle views while transition is happening
            toViewController.phoneImageView.hidden = true
            toViewController.dongleCableView.hidden = true
            toViewController.cameraCableView.hidden = true
            toViewController.informationView.hidden = true
            toViewController.cameraView.hidden = true
            toViewController.dismissButton.hidden = true
            
            let plugedInViewFrame = toViewController.pluggedView.frame
            let dongleCenter = toViewController.dongleCoilImageView.convertPoint(toViewController.dongleCoilImageView.frame.origin, fromView: toViewController.dongleCoilImageView)
            toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
            
            containerView.addSubview(toViewController.view)
            containerView.addSubview(pathView)
            containerView.addSubview(cameraConnectorSnapshot)
            containerView.addSubview(dongleCableViewSnapshot)
            containerView.addSubview(dongleCoilSnapshot)
            containerView.addSubview(phoneSnapshot)
            containerView.addSubview(cameraViewSnapshot)
            containerView.addSubview(informationViewSnapshot)
            containerView.addSubview(separatorLineSnapshot)
            
            for view: UIView in snapshotViews {
                containerView.addSubview(view)
            }
            
            toViewController.view.layoutIfNeeded()
            
            UIView.animateWithDuration(self.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                cameraConnectorSnapshot.frame = self.containerView.convertRect(plugedInViewFrame, fromView: toViewController.pluggedView.superview)
                phoneSnapshot.frame = self.containerView.convertRect(toViewController.phoneImageView.frame, fromView: toViewController.phoneImageView.superview)
                dongleCableViewSnapshot.frame = self.containerView.convertRect(toViewController.dongleCableView.frame, fromView: toViewController.dongleCableView.superview)
                cameraViewSnapshot.frame = self.containerView.convertRect(toViewController.cameraView.frame, fromView: toViewController.cameraView.superview)
                dongleCoilSnapshot.frame = self.containerView.convertRect(toViewController.dongleCoilImageView.frame, fromView: toViewController.dongleCoilImageView.superview)
                informationViewSnapshot.frame = self.containerView.convertRect(toViewController.informationView.frame, fromView: toViewController.informationView.superview)
                separatorLineSnapshot.frame = self.containerView.convertRect(toViewController.separatorLine.frame, fromView: toViewController.separatorLine.superview)
                
                pathView.frame = self.containerView.convertRect(toViewController.cameraCableView.frame, fromView: toViewController.cameraCableView.superview)
                pathView.point1 = CGPoint(x: 22, y: toViewController.pluggedView.center.y + toViewController.pluggedView.frame.size.height / 2)
                pathView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + toViewController.dongleCoilImageView.frame.size.height - 6)
                pathView.animateShapeLayereWithDuration(self.duration)
                
                }, completion: { (finished) -> Void in
                    
                    // Initial animation has been canceled
                    if (self.transitionContext!.transitionWasCancelled()) {
                        
                        fromViewController.dongleCoilImageView.hidden = false
                        fromViewController.phoneImageView.hidden = false
                        fromViewController.dongleCableView.hidden = false
                        fromViewController.informationView.hidden = false
                        fromViewController.separatorLine.hidden = false
                        fromViewController.cameraView.hidden = false
                        fromViewController.plugView.hidden = false
                        fromViewController.cameraConnectorView.hidden = false
                        
                        toViewController.dismissButton.hidden = false
                        toViewController.phoneImageView.hidden = false
                        toViewController.dongleCableView.hidden = false
                        toViewController.cameraCableView.hidden = false
                        toViewController.informationView.hidden = false
                        toViewController.cameraView.hidden = false
                        
                        pathView.removeFromSuperview()
                        cameraViewSnapshot.removeFromSuperview()
                        phoneSnapshot.removeFromSuperview()
                        dongleCableViewSnapshot.removeFromSuperview()
                        cameraConnectorSnapshot.removeFromSuperview()
                        informationViewSnapshot.removeFromSuperview()
                        separatorLineSnapshot.removeFromSuperview()
                        dongleCoilSnapshot.removeFromSuperview()
                        
                        self.transitionContext!.completeTransition(false)
                    } else {
                        UIView.animateWithDuration(self.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                            
                            // Update path frame to follow from View controller dongle cable view
                            
                            let plugCenter = toViewController.cameraCableView.convertPoint(toViewController.cameraConnectorBodyImageView.center, fromView: toViewController.cameraConnectorView)
                            let dongleCenter = toViewController.dongleCoilImageView.convertPoint(toViewController.dongleCoilImageView.frame.origin, fromView: toViewController.dongleCoilImageView)
                            
                            pathView.frame = self.containerView.convertRect(toViewController.cameraCableView.frame, fromView: toViewController.cameraCableView.superview)
                            pathView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + toViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
                            pathView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + toViewController.dongleCoilImageView.frame.size.height - 6)
                            pathView.animateShapeLayereWithDuration(self.duration)
                            
                            cameraConnectorSnapshot.frame = self.containerView.convertRect(toViewController.cameraConnectorView.frame, fromView: toViewController.cameraConnectorView.superview)
                            
                            self.fadeInSnapshots()
                            self.fadeOutViews()
                            
                            }, completion: { (ended) -> Void in
                                
                                fromViewController.dongleCoilImageView.hidden = false
                                fromViewController.phoneImageView.hidden = false
                                fromViewController.dongleCableView.hidden = false
                                fromViewController.informationView.hidden = false
                                fromViewController.separatorLine.hidden = false
                                fromViewController.cameraView.hidden = false
                                fromViewController.plugView.hidden = false
                                fromViewController.cameraConnectorView.hidden = false
                                
                                toViewController.phoneImageView.hidden = false
                                toViewController.dongleCableView.hidden = false
                                toViewController.cameraCableView.hidden = false
                                toViewController.informationView.hidden = false
                                toViewController.cameraView.hidden = false
                                toViewController.dismissButton.hidden = false
                                
                                pathView.removeFromSuperview()
                                phoneSnapshot.removeFromSuperview()
                                dongleCableViewSnapshot.removeFromSuperview()
                                cameraViewSnapshot.removeFromSuperview()
                                cameraConnectorSnapshot.removeFromSuperview()
                                informationViewSnapshot.removeFromSuperview()
                                separatorLineSnapshot.removeFromSuperview()
                                dongleCoilSnapshot.removeFromSuperview()
                                
                                self.showViews()
                                self.removeSnapshotViews()
                                
                                if (self.transitionContext!.transitionWasCancelled()) {
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
