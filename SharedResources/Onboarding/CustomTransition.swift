//
//  KitToCameraSelectorTransition.swift
//  TriggertrapSLR
//
//  Created by Valentin Kalchev on 28/01/2015.
//  Copyright (c) 2015 Triggertrap Ltd. All rights reserved.
//

import UIKit

class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum State {
        case push,
        pop
    }
    
    var containerView: UIView!
    var state: State = State.push
    
    var viewsToShow: [UIView] = []
    var snapshotViews: [UIView] = []
    var fadedViews: [UIView] = []
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    // Apply animation duration
    let duration = 0.5
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        containerView = transitionContext.containerView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled)
        self.transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.from)?.view.layer.mask = nil
    }
    
    // Creates a snapshot of the view and hides it
    func createSnapshotView(_ view: UIView) -> UIView {
        let snapshot = view.snapshotView(afterScreenUpdates: false)
        snapshot?.frame = containerView.convert(view.frame, from: view.superview)
        
        // Hide the view before transition happens
        view.isHidden = true
        return snapshot!
    }
    
    // Remove all snapshot views from its superview
    func removeSnapshotViews() {
        for view: UIView in snapshotViews {
            view.removeFromSuperview()
        }
    }
    
    // Create a snapshot of a view
    func snapshotView(_ view: UIView) {
        let snapshot = view.snapshotView(afterScreenUpdates: false)
        snapshot?.frame = containerView.convert(view.frame, from: view.superview)
        
        // Hide the view before transition happens
        view.isHidden = true
        
        // Add the view to views that need to be shown
        viewsToShow.append(view)
        
        // Add the snapshot to snapshotViews
        snapshotViews.append(snapshot!)
    }
    
    // Alpha out all the snapshots
    func fadeInSnapshots() {
        for view: UIView in snapshotViews {
            view.alpha = 0
        }
    }
    
    // Alpha out the view and add it to faded views array
    func fadeInView(_ view: UIView) {
        view.alpha = 0
        fadedViews.append(view)
    }
    
    // Iterate through the faded views array and alpha in all the views
    func fadeOutViews() {
        for view: UIView in fadedViews {
            view.alpha = 1.0
        }
    }
    
    // Iterate through the views to show array and show all views
    func showViews() {
        for view: UIView in viewsToShow {
            view.isHidden = false
        }
    }
}
