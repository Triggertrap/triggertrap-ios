//
//  VolumeToCameraTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 04/02/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit 

class VolumeToCameraTransition: CustomTransition {
    
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView()
        
        switch state {
        case .Push:
            
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! VolumeViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! CameraViewController
        
        // Create a snapshot of the view, hide it and add it to the snapshotViews array. This also causes the initial image to be added to viewsToShowArray
        
        // Phone and camera snapshots
        let phoneSnapshot = createSnapshotView(fromViewController.phoneImageView)
        let cameraSnapshot = createSnapshotView(fromViewController.cameraView)
        
        // Dongle body snapshot
        let dongleSnapshot = createSnapshotView(fromViewController.dongleView)
        
        // Plug view connected to the phone
        let plugViewSnapshot = createSnapshotView(fromViewController.plugView)
        
        // Camera coil under the dongle body
        let cameraCoilSnapshot = createSnapshotView(fromViewController.cameraCoilImageView)
        
        let cameraConnectorSnapshot = createSnapshotView(fromViewController.cameraConnectorView)
        let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
        let separatorLine = createSnapshotView(fromViewController.separatorLine)
        
        snapshotView(fromViewController.whiteViewDescriptionLabel)
        snapshotView(fromViewController.whiteViewTitleLabel)
        
        // Dongle to plug cable view 
        
        let dongleCableView = DongleCableView()
        dongleCableView.frame = fromViewController.dongleCableView.frame
        
        let fromPlugCenter = fromViewController.dongleCableView.convertPoint(fromViewController.donglePlugImageView.center, fromView: fromViewController.plugView)
        
        let fromDongleCenter = fromViewController.dongleCableView.convertPoint(fromViewController.dongleBodyTopImageView.center, fromView: fromViewController.dongleView)
        
        dongleCableView.point1 = CGPoint(x: fromPlugCenter.x, y: fromPlugCenter.y + fromViewController.donglePlugImageView.frame.size.height / 2 + 2)
        dongleCableView.point2 = CGPoint(x: fromDongleCenter.x, y: fromDongleCenter.y - fromViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
        
        dongleCableView.addShapeLayer()
        
        // Camera coil cable to camera connector view
        
        let cameraCableView = DongleCableView()
        cameraCableView.frame = fromViewController.cameraCableView.frame
        cameraCableView.bezierType = DongleCableView.BezierPathType.Camera
        
        let cameraConnectorCenter = fromViewController.cameraCableView.convertPoint(fromViewController.cameraConnectorBodyImageView.center, fromView: fromViewController.cameraConnectorView)
        
        let cameraCoilCenter = fromViewController.cameraCoilImageView.convertPoint(fromViewController.cameraCoilImageView.frame.origin, fromView: fromViewController.cameraCoilImageView)
        
        cameraCableView.point1 = CGPoint(x: cameraConnectorCenter.x + 5, y: cameraConnectorCenter.y + fromViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
        cameraCableView.point2 = CGPoint(x: cameraCoilCenter.x + 6, y: cameraCoilCenter.y + fromViewController.cameraCoilImageView.frame.size.height - 6)
        cameraCableView.addShapeLayer()
        
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.informationView.hidden = true
        toViewController.phoneImageView.hidden = true
        toViewController.cameraView.hidden = true
        toViewController.dongleView.hidden = true
        toViewController.plugView.hidden = true
        toViewController.dongleCableView.hidden = true
        toViewController.cameraCableView.hidden = true
        toViewController.dismissButton.hidden = true
        
        let toPlugCenter = toViewController.dongleCableView.convertPoint(toViewController.plugImageView.center, fromView: toViewController.plugView)
        
        let toDongleCenter = toViewController.dongleCableView.convertPoint(toViewController.dongleBodyTopImageView.center, fromView: toViewController.dongleView)
        
        let toCameraConnectorCenter = toViewController.cameraCableView.convertPoint(toViewController.cameraConnectorBodyImageView.center, fromView: toViewController.cameraConnectorView)
        
        containerView.addSubview(toViewController.view)
        
        for view: UIView in snapshotViews {
            containerView.addSubview(view)
        }
        
        containerView.addSubview(plugViewSnapshot)
        containerView.addSubview(dongleSnapshot)
        containerView.addSubview(dongleCableView)
        containerView.addSubview(cameraCoilSnapshot)
        containerView.addSubview(cameraConnectorSnapshot)
        containerView.addSubview(cameraSnapshot)
        containerView.addSubview(cameraCableView)
        containerView.addSubview(phoneSnapshot)
        containerView.addSubview(informationViewSnapshot)
        containerView.addSubview(separatorLine)
        
        toViewController.view.layoutIfNeeded()
        
        UIView.animateWithDuration(self.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            
            cameraCoilSnapshot.frame = self.containerView.convertRect(toViewController.dongleCoilImageView.frame, fromView:toViewController.dongleCoilImageView.superview)
            
            plugViewSnapshot.frame = self.containerView.convertRect(toViewController.plugView.frame, fromView: toViewController.plugView.superview)
            
            dongleSnapshot.frame = self.containerView.convertRect(toViewController.dongleView.frame, fromView: toViewController.dongleView.superview)
            
            cameraSnapshot.frame = self.containerView.convertRect(toViewController.cameraView.frame, fromView: toViewController.cameraView.superview)
            
            cameraConnectorSnapshot.frame = self.containerView.convertRect(toViewController.cameraConnectorView.frame, fromView: toViewController.cameraConnectorView.superview)
            
            phoneSnapshot.frame = self.containerView.convertRect(toViewController.phoneImageView.frame, fromView: toViewController.phoneImageView.superview)
            
            informationViewSnapshot.frame = self.containerView.convertRect(fromViewController.informationView.frame, fromView: fromViewController.informationView.superview)
            
            // Update path frame to follow from View controller dongle cable view
            dongleCableView.frame = self.containerView.convertRect(toViewController.dongleCableView.frame, fromView: toViewController.dongleCableView.superview)
            
            dongleCableView.point1 = CGPoint(x: toPlugCenter.x, y: toPlugCenter.y + toViewController.plugImageView.frame.size.height / 2 + 2)
            dongleCableView.point2 = CGPoint(x: toDongleCenter.x, y: toDongleCenter.y - toViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
            dongleCableView.animateShapeLayereWithDuration(self.duration)

            // Update path frame and change path to match new view controller
            cameraCableView.frame = self.containerView.convertRect(toViewController.cameraCableView.frame, fromView: toViewController.cameraCableView.superview)
            
            cameraCableView.point1 = CGPoint(x: toCameraConnectorCenter.x + 5, y: toCameraConnectorCenter.y + toViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            cameraCableView.point2 = CGPoint(x: toViewController.dongleCoilImageView.frame.origin.x + 6, y: toViewController.dongleCoilImageView.frame.origin.y + toViewController.dongleCoilImageView.frame.size.height - 6)
            
            cameraCableView.animateShapeLayereWithDuration(self.duration)
            
            self.fadeInSnapshots()
            self.fadeOutViews()
            
            }, completion: { (finished) -> Void in
                
                fromViewController.cameraCoilImageView.hidden = false
                fromViewController.plugView.hidden = false
                fromViewController.informationView.hidden = false
                fromViewController.phoneImageView.hidden = false
                fromViewController.cameraView.hidden = false
                fromViewController.dongleView.hidden = false
                fromViewController.dongleCableView.hidden = false
                fromViewController.cameraCableView.hidden = false
                fromViewController.cameraConnectorView.hidden = false
                fromViewController.separatorLine.hidden = false
                
                toViewController.dismissButton.hidden = false
                toViewController.dongleCoilImageView.hidden = false
                toViewController.plugView.hidden = false
                toViewController.informationView.hidden = false
                toViewController.phoneImageView.hidden = false
                toViewController.cameraView.hidden = false
                toViewController.dongleView.hidden = false
                toViewController.dongleCableView.hidden = false
                toViewController.cameraCableView.hidden = false
                
                separatorLine.removeFromSuperview()
                cameraCableView.removeFromSuperview()
                cameraConnectorSnapshot.removeFromSuperview()
                dongleCableView.removeFromSuperview()
                cameraCoilSnapshot.removeFromSuperview()
                plugViewSnapshot.removeFromSuperview()
                dongleSnapshot.removeFromSuperview()
                cameraSnapshot.removeFromSuperview()
                phoneSnapshot.removeFromSuperview()
                informationViewSnapshot.removeFromSuperview()
                
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
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! CameraViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! VolumeViewController
        
        // Create a snapshot of the view, hide it and add it to the snapshotViews array. This also causes the initial image to be added to viewsToShowArray
        
        // Phone and camera snapshots
        let phoneSnapshot = createSnapshotView(fromViewController.phoneImageView)
        let cameraSnapshot = createSnapshotView(fromViewController.cameraView)
            
            // Dongle body snapshot
        let dongleSnapshot = createSnapshotView(fromViewController.dongleView)
        
        // Plug view connected to the phone
        let plugViewSnapshot = createSnapshotView(fromViewController.plugView)
        
        // Camera coil under the dongle body
        let cameraCoilSnapshot = createSnapshotView(fromViewController.dongleCoilImageView)
        
        let cameraConnectorSnapshot = createSnapshotView(fromViewController.cameraConnectorView)
        let informationViewSnapshot = createSnapshotView(fromViewController.informationView)
        let separatorLine = createSnapshotView(fromViewController.separatorLine)
           
        // Dongle to plug cable view
        
        let dongleCableView = DongleCableView()
        dongleCableView.frame = fromViewController.dongleCableView.frame
            
        let fromPlugCenter = fromViewController.dongleCableView.convertPoint(fromViewController.plugImageView.center, fromView: fromViewController.plugView)
        
        let fromDongleCenter = fromViewController.dongleCableView.convertPoint(fromViewController.dongleBodyTopImageView.center, fromView: fromViewController.dongleView)
        
        dongleCableView.point1 = CGPoint(x: fromPlugCenter.x, y: fromPlugCenter.y + fromViewController.plugImageView.frame.size.height / 2 + 2)
            
        dongleCableView.point2 = CGPoint(x: fromDongleCenter.x, y: fromDongleCenter.y - fromViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
        
        dongleCableView.addShapeLayer()
        
        // Camera coil cable to camera connector view
        
        let cameraCableView = DongleCableView()
        cameraCableView.frame = fromViewController.cameraCableView.frame
        cameraCableView.bezierType = DongleCableView.BezierPathType.Camera
            
        let cameraConnectorCenter = fromViewController.cameraCableView.convertPoint(fromViewController.cameraConnectorBodyImageView.center, fromView: fromViewController.cameraConnectorView)
        
        let cameraCoilCenter = fromViewController.dongleCoilImageView.convertPoint(fromViewController.dongleCoilImageView.frame.origin, fromView: fromViewController.dongleCoilImageView)
        
        cameraCableView.point1 = CGPoint(x: cameraConnectorCenter.x + 5, y: cameraConnectorCenter.y + fromViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            
        cameraCableView.point2 = CGPoint(x: cameraCoilCenter.x + 6, y: cameraCoilCenter.y + fromViewController.dongleCoilImageView.frame.size.height - 6)
            
        cameraCableView.addShapeLayer()
        
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.informationView.hidden = true
        toViewController.phoneImageView.hidden = true
        toViewController.cameraView.hidden = true
        toViewController.dongleView.hidden = true
        toViewController.plugView.hidden = true
        toViewController.dongleCableView.hidden = true
        toViewController.cameraCableView.hidden = true
        toViewController.dismissButton.hidden = true
        
        let toPlugCenter = toViewController.dongleCableView.convertPoint(toViewController.donglePlugImageView.center, fromView: toViewController.plugView)
            
        let toDongleCenter = toViewController.dongleCableView.convertPoint(toViewController.dongleBodyTopImageView.center, fromView: toViewController.dongleView)
            
        let toCameraConnectorCenter = toViewController.cameraCableView.convertPoint(toViewController.cameraConnectorBodyImageView.center, fromView: toViewController.cameraConnectorView)
            
        let toCameraCoilCenter = toViewController.cameraCoilImageView.convertPoint(toViewController.cameraCoilImageView.frame.origin, fromView: toViewController.cameraCoilImageView)
            
        containerView.addSubview(toViewController.view)
        
        for view: UIView in snapshotViews {
            containerView.addSubview(view)
        }
        
        containerView.addSubview(plugViewSnapshot)
        containerView.addSubview(dongleSnapshot)
        containerView.addSubview(dongleCableView)
        containerView.addSubview(cameraCoilSnapshot)
        containerView.addSubview(cameraConnectorSnapshot)
        containerView.addSubview(cameraSnapshot)
        containerView.addSubview(cameraCableView)
        containerView.addSubview(phoneSnapshot)
        containerView.addSubview(informationViewSnapshot)
        containerView.addSubview(separatorLine)
        
        toViewController.view.layoutIfNeeded()
        
        UIView.animateWithDuration(self.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            
            cameraCoilSnapshot.frame = self.containerView.convertRect(toViewController.cameraCoilImageView.frame, fromView:toViewController.cameraCoilImageView.superview)
            
            plugViewSnapshot.frame = self.containerView.convertRect(toViewController.plugView.frame, fromView: toViewController.plugView.superview)
            
            dongleSnapshot.frame = self.containerView.convertRect(toViewController.dongleView.frame, fromView: toViewController.dongleView.superview)
            
            cameraSnapshot.frame = self.containerView.convertRect(toViewController.cameraView.frame, fromView: toViewController.cameraView.superview)
            
            cameraConnectorSnapshot.frame = self.containerView.convertRect(toViewController.cameraConnectorView.frame, fromView: toViewController.cameraConnectorView.superview)
            
            phoneSnapshot.frame = self.containerView.convertRect(toViewController.phoneImageView.frame, fromView: toViewController.phoneImageView.superview)
            
            informationViewSnapshot.frame = self.containerView.convertRect(fromViewController.informationView.frame, fromView: fromViewController.informationView.superview)
            
            // Update path frame to follow from View controller dongle cable view
            dongleCableView.frame = self.containerView.convertRect(toViewController.dongleCableView.frame, fromView: toViewController.dongleCableView.superview)
            
            dongleCableView.point1 = CGPoint(x: toPlugCenter.x, y: toPlugCenter.y + toViewController.donglePlugImageView.frame.size.height / 2 + 2)
            
            dongleCableView.point2 = CGPoint(x: toDongleCenter.x, y: toDongleCenter.y - toViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
            
            dongleCableView.animateShapeLayereWithDuration(self.duration)

            // Update path frame and change path to match new view controller
            cameraCableView.frame = self.containerView.convertRect(toViewController.cameraCableView.frame, fromView: toViewController.cameraCableView.superview)
            
            cameraCableView.point1 = CGPoint(x: toCameraConnectorCenter.x + 5, y: toCameraConnectorCenter.y + toViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            
            cameraCableView.point2 = CGPoint(x: toCameraCoilCenter.x + 6, y: toCameraCoilCenter.y + toViewController.cameraCoilImageView.frame.size.height - 6)
            
            cameraCableView.animateShapeLayereWithDuration(self.duration)
            
            self.fadeInSnapshots()
            self.fadeOutViews()
            
            }, completion: { (finished) -> Void in
                
                fromViewController.dongleCoilImageView.hidden = false
                fromViewController.plugView.hidden = false
                fromViewController.informationView.hidden = false
                fromViewController.phoneImageView.hidden = false
                fromViewController.cameraView.hidden = false
                fromViewController.dongleView.hidden = false
                fromViewController.dongleCableView.hidden = false
                fromViewController.cameraCableView.hidden = false
                fromViewController.cameraConnectorView.hidden = false
                fromViewController.separatorLine.hidden = false
                
                toViewController.dismissButton.hidden = false
                toViewController.dongleCoilImageView.hidden = false
                toViewController.plugView.hidden = false
                toViewController.informationView.hidden = false
                toViewController.phoneImageView.hidden = false
                toViewController.cameraView.hidden = false
                toViewController.dongleView.hidden = false
                toViewController.dongleCableView.hidden = false
                toViewController.cameraCableView.hidden = false
                
                separatorLine.removeFromSuperview()
                cameraCableView.removeFromSuperview()
                cameraConnectorSnapshot.removeFromSuperview()
                dongleCableView.removeFromSuperview()
                cameraCoilSnapshot.removeFromSuperview()
                plugViewSnapshot.removeFromSuperview()
                dongleSnapshot.removeFromSuperview()
                cameraSnapshot.removeFromSuperview()
                phoneSnapshot.removeFromSuperview()
                informationViewSnapshot.removeFromSuperview()
                
                self.showViews()
                self.removeSnapshotViews()
                
                if (transitionContext.transitionWasCancelled()) {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
        })
        }
    }
}