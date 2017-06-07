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
        case Push,
        Pop
    }
    
    var containerView: UIView!
    var state: State = State.Push
    
    var viewsToShow: [UIView] = []
    var snapshotViews: [UIView] = []
    var fadedViews: [UIView] = []
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    // Apply animation duration
    let duration = 0.5
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        containerView = transitionContext.containerView()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled())
        self.transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
    }
    
    // Creates a snapshot of the view and hides it
    func createSnapshotView(view: UIView) -> UIView {
        let snapshot = view.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = containerView.convertRect(view.frame, fromView: view.superview)
        
        // Hide the view before transition happens
        view.hidden = true
        return snapshot
    }
    
    // Remove all snapshot views from its superview
    func removeSnapshotViews() {
        for view: UIView in snapshotViews {
            view.removeFromSuperview()
        }
    }
    
    // Create a snapshot of a view
    func snapshotView(view: UIView) {
        let snapshot = view.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = containerView.convertRect(view.frame, fromView: view.superview)
        
        // Hide the view before transition happens
        view.hidden = true
        
        // Add the view to views that need to be shown
        viewsToShow.append(view)
        
        // Add the snapshot to snapshotViews
        snapshotViews.append(snapshot)
    }
    
    // Alpha out all the snapshots
    func fadeInSnapshots() {
        for view: UIView in snapshotViews {
            view.alpha = 0
        }
    }
    
    // Alpha out the view and add it to faded views array
    func fadeInView(view: UIView) {
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
            view.hidden = false
        }
    }
}
