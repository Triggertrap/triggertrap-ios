//
//  MCPanGestureRecognizer.m
//  GSX
//
//  Created by Matthew Cheok on 2/10/13.
//  Copyright (c) 2013 Matthew Cheok. All rights reserved.
//

#import "MCPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

const static CGFloat MCPanGestureRecognizerThreshold = 4;

@implementation MCPanGestureRecognizer {
    CGFloat _translationX;
    CGFloat _translationY;
    BOOL _isDragging;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Cancel gesture if it doesn't originate on the screen edge
    CGPoint location = [(UITouch*)[touches anyObject] locationInView:self.view];
    if ( _edge == MCPanGestureRecognizerEdgeLeft
            && !CGRectContainsPoint(CGRectMake(0, 0, 30, self.view.bounds.size.height), location) ) {
        return;
    } else if ( _edge == MCPanGestureRecognizerEdgeRight
            && !CGRectContainsPoint(CGRectMake(self.view.bounds.size.width-30, 0, 30, self.view.bounds.size.height), location) ) {
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (_edge != MCPanGestureRecognizerEdgeNone) return;
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _translationX += prevPoint.x - nowPoint.x;
    _translationY += prevPoint.y - nowPoint.y;
    if (!_isDragging) {
        if (_direction == MCPanGestureRecognizerDirectionHorizontal &&
            fabs(_translationY) > MCPanGestureRecognizerThreshold) {
            self.state = UIGestureRecognizerStateFailed;
        }
        if (_direction == MCPanGestureRecognizerDirectionVertical &&
                 fabs(_translationX) > MCPanGestureRecognizerThreshold) {
            self.state = UIGestureRecognizerStateFailed;
        }
        _isDragging = YES;
    }
}

- (void)reset {
    [super reset];
    _isDragging = NO;
    _translationX = 0;
    _translationY = 0;
}

- (void)setEdge:(MCPanGestureRecognizerEdge)edge {
    _edge = edge;
    
    if ( _edge == MCPanGestureRecognizerEdgeLeft || _edge == MCPanGestureRecognizerEdgeRight ) {
        self.direction = MCPanGestureRecognizerDirectionHorizontal;
    }
}

@end
