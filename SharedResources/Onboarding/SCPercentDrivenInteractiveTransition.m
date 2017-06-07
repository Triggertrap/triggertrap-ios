//
//  SCPercentDrivenInteractiveTransition.m
//  InteractiveTransition
//
//  Created by Michal Inger on 05/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import "SCPercentDrivenInteractiveTransition.h"

@implementation SCPercentDrivenInteractiveTransition {
    CGFloat _pausedTime;
    CGFloat _completionSpeed;
    __weak id <UIViewControllerContextTransitioning> _transitionContext;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    // Must be implemented by inheriting class
    [self doesNotRecognizeSelector:_cmd];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (CGFloat)completionSpeed {
    return _completionSpeed;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    [self animateTransition:_transitionContext];
    [self pauseLayer:[transitionContext containerView].layer];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [_transitionContext updateInteractiveTransition:percentComplete];
    [_transitionContext containerView].layer.timeOffset =  _pausedTime + [self transitionDuration:_transitionContext]*percentComplete;
}

- (void)cancelInteractiveTransition {
    [_transitionContext cancelInteractiveTransition];
    CALayer *containerLayer =[_transitionContext containerView].layer;
    containerLayer.speed = -1.0;
    containerLayer.beginTime = CACurrentMediaTime();
    CGFloat delay = ((1.0-self.completionSpeed)*[self transitionDuration:_transitionContext])+0.05;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        containerLayer.speed = 1.0;
    });
}

- (void)finishInteractiveTransition {
    [_transitionContext finishInteractiveTransition];
    [self resumeLayer:[_transitionContext containerView].layer];
}

- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:recognizer.view].x / (recognizer.view.bounds.size.width * 1.0);
    progress = fabs(progress);
    progress = MIN(1.0, MAX(0.0, progress));

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            [self updateInteractiveTransition:progress];
            break;
        case UIGestureRecognizerStateEnded:{
            if (progress < 0.5){
                _completionSpeed = (1.0-progress);
                [self cancelInteractiveTransition];
            }else{
                _completionSpeed = progress;
                [self finishInteractiveTransition];
            }
            self.shouldBeginInteractiveTransition = NO;
            break;
        }
        default:
            break;
    }
}

- (void)pauseLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
    _pausedTime = pausedTime;
}

- (void)resumeLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

@end
