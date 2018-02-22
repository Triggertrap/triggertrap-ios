//
//  VolumeToCameraTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 04/02/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit 

class VolumeToCameraTransition: CustomTransition {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView
        
        switch state {
        case .push:
            
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! VolumeViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! CameraViewController
        
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
        
        let fromPlugCenter = fromViewController.dongleCableView.convert(fromViewController.donglePlugImageView.center, from: fromViewController.plugView)
        
        let fromDongleCenter = fromViewController.dongleCableView.convert(fromViewController.dongleBodyTopImageView.center, from: fromViewController.dongleView)
        
        dongleCableView.point1 = CGPoint(x: fromPlugCenter.x, y: fromPlugCenter.y + fromViewController.donglePlugImageView.frame.size.height / 2 + 2)
        dongleCableView.point2 = CGPoint(x: fromDongleCenter.x, y: fromDongleCenter.y - fromViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
        
        dongleCableView.addShapeLayer()
        
        // Camera coil cable to camera connector view
        
        let cameraCableView = DongleCableView()
        cameraCableView.frame = fromViewController.cameraCableView.frame
        cameraCableView.bezierType = DongleCableView.BezierPathType.camera
        
        let cameraConnectorCenter = fromViewController.cameraCableView.convert(fromViewController.cameraConnectorBodyImageView.center, from: fromViewController.cameraConnectorView)
        
        let cameraCoilCenter = fromViewController.cameraCoilImageView.convert(fromViewController.cameraCoilImageView.frame.origin, from: fromViewController.cameraCoilImageView)
        
        cameraCableView.point1 = CGPoint(x: cameraConnectorCenter.x + 5, y: cameraConnectorCenter.y + fromViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
        cameraCableView.point2 = CGPoint(x: cameraCoilCenter.x + 6, y: cameraCoilCenter.y + fromViewController.cameraCoilImageView.frame.size.height - 6)
        cameraCableView.addShapeLayer()
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.informationView.isHidden = true
        toViewController.phoneImageView.isHidden = true
        toViewController.cameraView.isHidden = true
        toViewController.dongleView.isHidden = true
        toViewController.plugView.isHidden = true
        toViewController.dongleCableView.isHidden = true
        toViewController.cameraCableView.isHidden = true
        toViewController.dismissButton.isHidden = true
        
        let toPlugCenter = toViewController.dongleCableView.convert(toViewController.plugImageView.center, from: toViewController.plugView)
        
        let toDongleCenter = toViewController.dongleCableView.convert(toViewController.dongleBodyTopImageView.center, from: toViewController.dongleView)
        
        let toCameraConnectorCenter = toViewController.cameraCableView.convert(toViewController.cameraConnectorBodyImageView.center, from: toViewController.cameraConnectorView)
        
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
        
        UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            
            cameraCoilSnapshot.frame = self.containerView.convert(toViewController.dongleCoilImageView.frame, from:toViewController.dongleCoilImageView.superview)
            
            plugViewSnapshot.frame = self.containerView.convert(toViewController.plugView.frame, from: toViewController.plugView.superview)
            
            dongleSnapshot.frame = self.containerView.convert(toViewController.dongleView.frame, from: toViewController.dongleView.superview)
            
            cameraSnapshot.frame = self.containerView.convert(toViewController.cameraView.frame, from: toViewController.cameraView.superview)
            
            cameraConnectorSnapshot.frame = self.containerView.convert(toViewController.cameraConnectorView.frame, from: toViewController.cameraConnectorView.superview)
            
            phoneSnapshot.frame = self.containerView.convert(toViewController.phoneImageView.frame, from: toViewController.phoneImageView.superview)
            
            informationViewSnapshot.frame = self.containerView.convert(fromViewController.informationView.frame, from: fromViewController.informationView.superview)
            
            // Update path frame to follow from View controller dongle cable view
            dongleCableView.frame = self.containerView.convert(toViewController.dongleCableView.frame, from: toViewController.dongleCableView.superview)
            
            dongleCableView.point1 = CGPoint(x: toPlugCenter.x, y: toPlugCenter.y + toViewController.plugImageView.frame.size.height / 2 + 2)
            dongleCableView.point2 = CGPoint(x: toDongleCenter.x, y: toDongleCenter.y - toViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
            dongleCableView.animateShapeLayereWithDuration(self.duration)

            // Update path frame and change path to match new view controller
            cameraCableView.frame = self.containerView.convert(toViewController.cameraCableView.frame, from: toViewController.cameraCableView.superview)
            
            cameraCableView.point1 = CGPoint(x: toCameraConnectorCenter.x + 5, y: toCameraConnectorCenter.y + toViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            cameraCableView.point2 = CGPoint(x: toViewController.dongleCoilImageView.frame.origin.x + 6, y: toViewController.dongleCoilImageView.frame.origin.y + toViewController.dongleCoilImageView.frame.size.height - 6)
            
            cameraCableView.animateShapeLayereWithDuration(self.duration)
            
            self.fadeInSnapshots()
            self.fadeOutViews()
            
            }, completion: { (finished) -> Void in
                
                fromViewController.cameraCoilImageView.isHidden = false
                fromViewController.plugView.isHidden = false
                fromViewController.informationView.isHidden = false
                fromViewController.phoneImageView.isHidden = false
                fromViewController.cameraView.isHidden = false
                fromViewController.dongleView.isHidden = false
                fromViewController.dongleCableView.isHidden = false
                fromViewController.cameraCableView.isHidden = false
                fromViewController.cameraConnectorView.isHidden = false
                fromViewController.separatorLine.isHidden = false
                
                toViewController.dismissButton.isHidden = false
                toViewController.dongleCoilImageView.isHidden = false
                toViewController.plugView.isHidden = false
                toViewController.informationView.isHidden = false
                toViewController.phoneImageView.isHidden = false
                toViewController.cameraView.isHidden = false
                toViewController.dongleView.isHidden = false
                toViewController.dongleCableView.isHidden = false
                toViewController.cameraCableView.isHidden = false
                
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
                
                if (transitionContext.transitionWasCancelled) {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
        })
        break
            
        case .pop:
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! CameraViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! VolumeViewController
        
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
            
        let fromPlugCenter = fromViewController.dongleCableView.convert(fromViewController.plugImageView.center, from: fromViewController.plugView)
        
        let fromDongleCenter = fromViewController.dongleCableView.convert(fromViewController.dongleBodyTopImageView.center, from: fromViewController.dongleView)
        
        dongleCableView.point1 = CGPoint(x: fromPlugCenter.x, y: fromPlugCenter.y + fromViewController.plugImageView.frame.size.height / 2 + 2)
            
        dongleCableView.point2 = CGPoint(x: fromDongleCenter.x, y: fromDongleCenter.y - fromViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
        
        dongleCableView.addShapeLayer()
        
        // Camera coil cable to camera connector view
        
        let cameraCableView = DongleCableView()
        cameraCableView.frame = fromViewController.cameraCableView.frame
        cameraCableView.bezierType = DongleCableView.BezierPathType.camera
            
        let cameraConnectorCenter = fromViewController.cameraCableView.convert(fromViewController.cameraConnectorBodyImageView.center, from: fromViewController.cameraConnectorView)
        
        let cameraCoilCenter = fromViewController.dongleCoilImageView.convert(fromViewController.dongleCoilImageView.frame.origin, from: fromViewController.dongleCoilImageView)
        
        cameraCableView.point1 = CGPoint(x: cameraConnectorCenter.x + 5, y: cameraConnectorCenter.y + fromViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            
        cameraCableView.point2 = CGPoint(x: cameraCoilCenter.x + 6, y: cameraCoilCenter.y + fromViewController.dongleCoilImageView.frame.size.height - 6)
            
        cameraCableView.addShapeLayer()
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.informationView.isHidden = true
        toViewController.phoneImageView.isHidden = true
        toViewController.cameraView.isHidden = true
        toViewController.dongleView.isHidden = true
        toViewController.plugView.isHidden = true
        toViewController.dongleCableView.isHidden = true
        toViewController.cameraCableView.isHidden = true
        toViewController.dismissButton.isHidden = true
        
        let toPlugCenter = toViewController.dongleCableView.convert(toViewController.donglePlugImageView.center, from: toViewController.plugView)
            
        let toDongleCenter = toViewController.dongleCableView.convert(toViewController.dongleBodyTopImageView.center, from: toViewController.dongleView)
            
        let toCameraConnectorCenter = toViewController.cameraCableView.convert(toViewController.cameraConnectorBodyImageView.center, from: toViewController.cameraConnectorView)
            
        let toCameraCoilCenter = toViewController.cameraCoilImageView.convert(toViewController.cameraCoilImageView.frame.origin, from: toViewController.cameraCoilImageView)
            
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
        
        UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            
            cameraCoilSnapshot.frame = self.containerView.convert(toViewController.cameraCoilImageView.frame, from:toViewController.cameraCoilImageView.superview)
            
            plugViewSnapshot.frame = self.containerView.convert(toViewController.plugView.frame, from: toViewController.plugView.superview)
            
            dongleSnapshot.frame = self.containerView.convert(toViewController.dongleView.frame, from: toViewController.dongleView.superview)
            
            cameraSnapshot.frame = self.containerView.convert(toViewController.cameraView.frame, from: toViewController.cameraView.superview)
            
            cameraConnectorSnapshot.frame = self.containerView.convert(toViewController.cameraConnectorView.frame, from: toViewController.cameraConnectorView.superview)
            
            phoneSnapshot.frame = self.containerView.convert(toViewController.phoneImageView.frame, from: toViewController.phoneImageView.superview)
            
            informationViewSnapshot.frame = self.containerView.convert(fromViewController.informationView.frame, from: fromViewController.informationView.superview)
            
            // Update path frame to follow from View controller dongle cable view
            dongleCableView.frame = self.containerView.convert(toViewController.dongleCableView.frame, from: toViewController.dongleCableView.superview)
            
            dongleCableView.point1 = CGPoint(x: toPlugCenter.x, y: toPlugCenter.y + toViewController.donglePlugImageView.frame.size.height / 2 + 2)
            
            dongleCableView.point2 = CGPoint(x: toDongleCenter.x, y: toDongleCenter.y - toViewController.dongleBodyTopImageView.frame.size.height / 2 - 2)
            
            dongleCableView.animateShapeLayereWithDuration(self.duration)

            // Update path frame and change path to match new view controller
            cameraCableView.frame = self.containerView.convert(toViewController.cameraCableView.frame, from: toViewController.cameraCableView.superview)
            
            cameraCableView.point1 = CGPoint(x: toCameraConnectorCenter.x + 5, y: toCameraConnectorCenter.y + toViewController.cameraConnectorBodyImageView.frame.size.height / 2 + 2)
            
            cameraCableView.point2 = CGPoint(x: toCameraCoilCenter.x + 6, y: toCameraCoilCenter.y + toViewController.cameraCoilImageView.frame.size.height - 6)
            
            cameraCableView.animateShapeLayereWithDuration(self.duration)
            
            self.fadeInSnapshots()
            self.fadeOutViews()
            
            }, completion: { (finished) -> Void in
                
                fromViewController.dongleCoilImageView.isHidden = false
                fromViewController.plugView.isHidden = false
                fromViewController.informationView.isHidden = false
                fromViewController.phoneImageView.isHidden = false
                fromViewController.cameraView.isHidden = false
                fromViewController.dongleView.isHidden = false
                fromViewController.dongleCableView.isHidden = false
                fromViewController.cameraCableView.isHidden = false
                fromViewController.cameraConnectorView.isHidden = false
                fromViewController.separatorLine.isHidden = false
                
                toViewController.dismissButton.isHidden = false
                toViewController.dongleCoilImageView.isHidden = false
                toViewController.plugView.isHidden = false
                toViewController.informationView.isHidden = false
                toViewController.phoneImageView.isHidden = false
                toViewController.cameraView.isHidden = false
                toViewController.dongleView.isHidden = false
                toViewController.dongleCableView.isHidden = false
                toViewController.cameraCableView.isHidden = false
                
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
                
                if (transitionContext.transitionWasCancelled) {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
        })
        }
    }
}
