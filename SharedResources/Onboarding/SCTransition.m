//
//  SCTransition.m
//  InteractiveTransition
//
//  Created by Michal Inger on 04/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import "SCTransition.h"


@interface SCTransition ()
@end

@implementation SCTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.transitionDirection == kSCTransitionForwards) {
        UIView *view = [fromViewController valueForKeyPath:@"squareView"];
        
        [containerView insertSubview:toViewController.view atIndex:0];
        [self animateLayer:view.layer withCompletion:^{
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
        
    } else if (self.transitionDirection == kSCTransitionBackwards) {
        
        [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
        UIView *view = [toViewController valueForKeyPath:@"squareView"];
            [self animateLayer:view.layer withCompletion:^{
                if ([transitionContext transitionWasCancelled]) {
                    [containerView addSubview:fromViewController.view];
                    fromViewController.view.alpha = 1.0;
                    [toViewController.view removeFromSuperview];
                }
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
    }
}

- (void)animateLayer:(CALayer *)layer withCompletion:(void(^)())block {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.fromValue = @0.0;
    animation.toValue = [NSNumber numberWithFloat:M_PI];
    animation.duration = [self transitionDuration:nil];
    animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = YES;
    animation.delegate = self;
    [animation setValue:block forKeyPath:@"block"];
    [layer addAnimation:animation forKey:@"transform.rotation.y"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    void(^block)() = [anim valueForKeyPath:@"block"];
    if (block){
        block();
    }
}

@end
