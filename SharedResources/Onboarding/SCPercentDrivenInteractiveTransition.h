//
//  SCPercentDrivenInteractiveTransition.h
//  InteractiveTransition
//
//  Created by Michal Inger on 05/04/2014.
//  Copyright (c) 2014 StringCode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SCTranstionDirection) {
    kSCTransitionForwards,
    kSCTransitionBackwards,
};

/**
 SCPercentDrivenInteractiveTransition is alternative implementation to UIPercentDrivenInteractiveTransition.
 SCPercentDrivenInteractiveTransition will work work both (unlike UIPercentDrivenInteractiveTransition) UIView 
 and CoreAnimation animtions from the get go. Only methods that need to be overriden are animateTransition:
 and transitionDuration. Animations are going to be interpolated based on gesture passed in handleGesture:
 */

@interface SCPercentDrivenInteractiveTransition : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

/*
 @abstract Muss overide this method and perform your animations.
 @param transitionContext transitioning context passed by system
 @warning Muss check wether animation was caneled in completeTransition:
 for interactive transition to work correctly
 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

/**
 @abstract Call this method with recognizer. Transition progress is calculated
 based on recognizers position in view.
 @param recognizer Idealy UIScreenEdgePanGestureRecognizer, will work with Pan 
 and swipe as well
 */
- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)recognizer;

/**
 @abstract Overide to change transition duraiton
 @return Transtion duration, defaults to 1.0
 @param transitionContext transitioning context passed by system
 */
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

///Transition direction, defaultkSCTransitionForwards
@property (nonatomic) SCTranstionDirection transitionDirection;

/**
 Optional value to keep track of wether animation should be interactive,
 always set to no at the UIGestureRecognizerStateEnded. Setting this
 property to NO will not stop intrective transition from begining.
 */
@property (nonatomic) BOOL shouldBeginInteractiveTransition;

@end
