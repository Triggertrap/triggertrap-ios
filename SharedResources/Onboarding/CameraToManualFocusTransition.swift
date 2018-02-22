//
//  CameraToManualFocus.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 05/02/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class CameraToManualFocusTransition: CustomTransition {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView
        
        switch state {
        case .push:
            
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! CameraViewController
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ManualFocusViewController
            
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
            
            let plugCenter = fromViewController.cameraCableView.convert(fromViewController.cameraConnectorBodyImageView.center, from: fromViewController.cameraConnectorView)
            let dongleCenter = fromViewController.dongleCoilImageView.convert(fromViewController.dongleCoilImageView.frame.origin, from: fromViewController.dongleCoilImageView)
            
            pathView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + fromViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            pathView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + fromViewController.dongleCoilImageView.frame.size.height - 6)
            pathView.bezierType = DongleCableView.BezierPathType.camera
            
            pathView.addShapeLayer()
            
            // Hide the phone and dongle views while transition is happening
            toViewController.phoneImageView.isHidden = true
            toViewController.dongleCableView.isHidden = true
            toViewController.cameraCableView.isHidden = true
            toViewController.informationView.isHidden = true
            toViewController.cameraView.isHidden = true
            toViewController.popoutShapeView.isHidden = true
            toViewController.dismissButton.isHidden = true
            
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            
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
            
            UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                cameraConnectorSnapshot.frame = self.containerView.convert(plugedInViewFrame, from: fromViewController.pluggedView.superview)
                
                // Update path frame to follow from View controller dongle cable view
                pathView.frame = self.containerView.convert(fromViewController.cameraCableView.frame, from: fromViewController.cameraCableView.superview)
                
                pathView.point1 = CGPoint(x: 22, y: fromViewController.pluggedView.center.y + fromViewController.pluggedView.frame.size.height / 2)
                
                pathView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + fromViewController.dongleCoilImageView.frame.size.height - 6)
                
                pathView.animateShapeLayereWithDuration(self.duration)
                
                }, completion: { (finished) -> Void in
                    
                    // Initial animation has been canceled
                    if (self.transitionContext!.transitionWasCancelled) {
                        
                        pathView.removeFromSuperview()
                        cameraViewSnapshot.removeFromSuperview()
                        phoneSnapshot.removeFromSuperview()
                        dongleCableViewSnapshot.removeFromSuperview()
                        cameraConnectorSnapshot.removeFromSuperview()
                        informationViewSnapshot.removeFromSuperview()
                        separatorLineSnapshot.removeFromSuperview()
                        dongleCoilSnapshot.removeFromSuperview()
                        
                        fromViewController.dongleCoilImageView.isHidden = false
                        fromViewController.phoneImageView.isHidden = false
                        fromViewController.dongleCableView.isHidden = false
                        fromViewController.informationView.isHidden = false
                        fromViewController.separatorLine.isHidden = false
                        fromViewController.cameraView.isHidden = false
                        fromViewController.plugView.isHidden = false
                        fromViewController.cameraConnectorView.isHidden = false
                        
                        toViewController.popoutShapeView.isHidden = false
                        toViewController.phoneImageView.isHidden = false
                        toViewController.dongleCableView.isHidden = false
                        toViewController.cameraCableView.isHidden = false
                        toViewController.informationView.isHidden = false
                        toViewController.cameraView.isHidden = false
                        toViewController.dismissButton.isHidden = false
                        
                        self.transitionContext!.completeTransition(false)
                    } else {
                        UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                            
                            phoneSnapshot.frame = self.containerView.convert(toViewController.phoneImageView.frame, from: toViewController.phoneImageView.superview)
                            dongleCableViewSnapshot.frame = self.containerView.convert(toViewController.dongleCableView.frame, from: toViewController.dongleCableView.superview)
                            cameraViewSnapshot.frame = self.containerView.convert(toViewController.cameraView.frame, from: toViewController.cameraView.superview)
                            cameraConnectorSnapshot.frame = self.containerView.convert(toViewController.cameraConnectorView.frame, from: toViewController.cameraConnectorView.superview)
                            dongleCoilSnapshot.frame = self.containerView.convert(toViewController.dongleCoilImageView.frame, from: toViewController.dongleCoilImageView.superview)
                            informationViewSnapshot.frame = self.containerView.convert(toViewController.informationView.frame, from: toViewController.informationView.superview)
                            separatorLineSnapshot.frame = self.containerView.convert(toViewController.separatorLine.frame, from: toViewController.separatorLine.superview)
                            
                            // Get new frame for the path
                            pathView.frame = self.containerView.convert(toViewController.cameraCableView.frame, from: toViewController.cameraCableView.superview)
                            
                            let plugCenter = toViewController.cameraCableView.convert(toViewController.cameraConnectorBodyImageView.center, from: toViewController.cameraConnectorView)
                            
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
                                
                                fromViewController.dongleCoilImageView.isHidden = false
                                fromViewController.phoneImageView.isHidden = false
                                fromViewController.dongleCableView.isHidden = false
                                fromViewController.informationView.isHidden = false
                                fromViewController.separatorLine.isHidden = false
                                fromViewController.cameraView.isHidden = false
                                fromViewController.plugView.isHidden = false
                                fromViewController.cameraConnectorView.isHidden = false
                                
                                toViewController.dismissButton.isHidden = false
                                toViewController.popoutShapeView.isHidden = false
                                toViewController.phoneImageView.isHidden = false
                                toViewController.dongleCableView.isHidden = false
                                toViewController.cameraCableView.isHidden = false
                                toViewController.informationView.isHidden = false
                                toViewController.cameraView.isHidden = false

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
            
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ManualFocusViewController
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! CameraViewController
            
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
            
            let plugCenter = fromViewController.cameraCableView.convert(fromViewController.cameraConnectorBodyImageView.center, from: fromViewController.cameraConnectorView)
            
            pathView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + fromViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            pathView.point2 = CGPoint(x: fromViewController.dongleCoilImageView.frame.origin.x + 6, y: fromViewController.dongleCoilImageView.frame.origin.y + fromViewController.dongleCoilImageView.frame.size.height - 6)
            
            pathView.bezierType = DongleCableView.BezierPathType.camera
            pathView.addShapeLayer()
            
            // Hide the phone and dongle views while transition is happening
            toViewController.phoneImageView.isHidden = true
            toViewController.dongleCableView.isHidden = true
            toViewController.cameraCableView.isHidden = true
            toViewController.informationView.isHidden = true
            toViewController.cameraView.isHidden = true
            toViewController.dismissButton.isHidden = true
            
            let plugedInViewFrame = toViewController.pluggedView.frame
            let dongleCenter = toViewController.dongleCoilImageView.convert(toViewController.dongleCoilImageView.frame.origin, from: toViewController.dongleCoilImageView)
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            
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
            
            UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                cameraConnectorSnapshot.frame = self.containerView.convert(plugedInViewFrame, from: toViewController.pluggedView.superview)
                phoneSnapshot.frame = self.containerView.convert(toViewController.phoneImageView.frame, from: toViewController.phoneImageView.superview)
                dongleCableViewSnapshot.frame = self.containerView.convert(toViewController.dongleCableView.frame, from: toViewController.dongleCableView.superview)
                cameraViewSnapshot.frame = self.containerView.convert(toViewController.cameraView.frame, from: toViewController.cameraView.superview)
                dongleCoilSnapshot.frame = self.containerView.convert(toViewController.dongleCoilImageView.frame, from: toViewController.dongleCoilImageView.superview)
                informationViewSnapshot.frame = self.containerView.convert(toViewController.informationView.frame, from: toViewController.informationView.superview)
                separatorLineSnapshot.frame = self.containerView.convert(toViewController.separatorLine.frame, from: toViewController.separatorLine.superview)
                
                pathView.frame = self.containerView.convert(toViewController.cameraCableView.frame, from: toViewController.cameraCableView.superview)
                pathView.point1 = CGPoint(x: 22, y: toViewController.pluggedView.center.y + toViewController.pluggedView.frame.size.height / 2)
                pathView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + toViewController.dongleCoilImageView.frame.size.height - 6)
                pathView.animateShapeLayereWithDuration(self.duration)
                
                }, completion: { (finished) -> Void in
                    
                    // Initial animation has been canceled
                    if (self.transitionContext!.transitionWasCancelled) {
                        
                        fromViewController.dongleCoilImageView.isHidden = false
                        fromViewController.phoneImageView.isHidden = false
                        fromViewController.dongleCableView.isHidden = false
                        fromViewController.informationView.isHidden = false
                        fromViewController.separatorLine.isHidden = false
                        fromViewController.cameraView.isHidden = false
                        fromViewController.plugView.isHidden = false
                        fromViewController.cameraConnectorView.isHidden = false
                        
                        toViewController.dismissButton.isHidden = false
                        toViewController.phoneImageView.isHidden = false
                        toViewController.dongleCableView.isHidden = false
                        toViewController.cameraCableView.isHidden = false
                        toViewController.informationView.isHidden = false
                        toViewController.cameraView.isHidden = false
                        
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
                        UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                            
                            // Update path frame to follow from View controller dongle cable view
                            
                            let plugCenter = toViewController.cameraCableView.convert(toViewController.cameraConnectorBodyImageView.center, from: toViewController.cameraConnectorView)
                            let dongleCenter = toViewController.dongleCoilImageView.convert(toViewController.dongleCoilImageView.frame.origin, from: toViewController.dongleCoilImageView)
                            
                            pathView.frame = self.containerView.convert(toViewController.cameraCableView.frame, from: toViewController.cameraCableView.superview)
                            pathView.point1 = CGPoint(x: plugCenter.x + 5, y: plugCenter.y + toViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
                            pathView.point2 = CGPoint(x: dongleCenter.x + 6, y: dongleCenter.y + toViewController.dongleCoilImageView.frame.size.height - 6)
                            pathView.animateShapeLayereWithDuration(self.duration)
                            
                            cameraConnectorSnapshot.frame = self.containerView.convert(toViewController.cameraConnectorView.frame, from: toViewController.cameraConnectorView.superview)
                            
                            self.fadeInSnapshots()
                            self.fadeOutViews()
                            
                            }, completion: { (ended) -> Void in
                                
                                fromViewController.dongleCoilImageView.isHidden = false
                                fromViewController.phoneImageView.isHidden = false
                                fromViewController.dongleCableView.isHidden = false
                                fromViewController.informationView.isHidden = false
                                fromViewController.separatorLine.isHidden = false
                                fromViewController.cameraView.isHidden = false
                                fromViewController.plugView.isHidden = false
                                fromViewController.cameraConnectorView.isHidden = false
                                
                                toViewController.phoneImageView.isHidden = false
                                toViewController.dongleCableView.isHidden = false
                                toViewController.cameraCableView.isHidden = false
                                toViewController.informationView.isHidden = false
                                toViewController.cameraView.isHidden = false
                                toViewController.dismissButton.isHidden = false
                                
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
