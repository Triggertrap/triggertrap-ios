//
//  GradientView.m
//  TTHorizontalPicker
//
//  Created by Valentin Kalchev on 14/08/2014.
//  Copyright (c) 2014 Triggertrap. All rights reserved.
//

#import "GradientView.h"

#define kTriangleSide 20
#define kVerticalLineOffset 10

typedef NS_OPTIONS (NSInteger, GradientDirection) {
    LeftToRight,
    TopToBottom,
};

@implementation GradientView

#pragma mark - Getters

- (float)width {
    return self.frame.size.width;
}

- (float)height {
    return self.frame.size.height;
}

- (UIColor *)leftGradientStartColor {
    return _leftGradientStartColor ? _leftGradientStartColor : [UIColor whiteColor];
}

- (UIColor *)leftGradientEndColor {
    return _leftGradientEndColor ? _leftGradientEndColor : [UIColor colorWithWhite:1 alpha:0];
}

- (UIColor *)rightGradientStartColor {
    return _rightGradientStartColor ? _rightGradientStartColor : [UIColor colorWithWhite:1 alpha:0];
}

- (UIColor *)rightGradientEndColor {
    return _rightGradientEndColor ? _rightGradientEndColor : [UIColor whiteColor];
}

- (UIColor *)verticalLinesColor {
    return _verticalLinesColor ? _verticalLinesColor : [UIColor redColor];
}

- (UIColor *)horizontalLinesColor {
    return _horizontalLinesColor ? _horizontalLinesColor : [UIColor grayColor];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[self horizontalLinesColor] setStroke];
    [[UIColor clearColor] setFill];
    
    UIBezierPath *topPath = [UIBezierPath bezierPath];
    [topPath moveToPoint:CGPointMake(0, 1)];
    [topPath addLineToPoint:CGPointMake([self width], 1)];
    
    topPath.lineWidth = 1;
    [topPath fill];
    [topPath stroke];
    
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    
    [trianglePath moveToPoint:CGPointMake(0, [self height])];
    
    //Begining of triangle
    [trianglePath addLineToPoint:CGPointMake(([self width] / 2) - (kTriangleSide / 2), [self height] - 1)];
    
    //Tip of the triangle
    [trianglePath addLineToPoint:CGPointMake(([self width] / 2), [self height] - (kTriangleSide / 2))];
    
    //End of triangle
    [trianglePath addLineToPoint:CGPointMake(([self width] / 2) + (kTriangleSide / 2), [self height] - 1)];
    
    [trianglePath addLineToPoint:CGPointMake([self width], [self height])];
    
    trianglePath.lineWidth = 1;
    [trianglePath fill];
    [trianglePath stroke];
    
    
    [[self verticalLinesColor] setStroke];
    [[UIColor clearColor] setFill];
    
    UIBezierPath *leftVerticalPath = [UIBezierPath bezierPath];
    
    [leftVerticalPath moveToPoint:CGPointMake([self width] / 3, kVerticalLineOffset)];
    [leftVerticalPath addLineToPoint:CGPointMake([self width] / 3, [self height] - kVerticalLineOffset)];
    
    leftVerticalPath.lineWidth = 1;
    [leftVerticalPath fill];
    [leftVerticalPath stroke];
    
    UIBezierPath *rightVerticalPath = [UIBezierPath bezierPath];
    [rightVerticalPath moveToPoint:CGPointMake([self width] / 3 * 2, kVerticalLineOffset)];
    [rightVerticalPath addLineToPoint:CGPointMake([self width] / 3 * 2, [self height] - kVerticalLineOffset)];
    
    rightVerticalPath.lineWidth = 1;
    [rightVerticalPath fill];
    [rightVerticalPath stroke];
    
    [self drawLinearGradientWithContext:context
                               withRect:CGRectMake(0, 0, [self width] / 3, [self height])
                         withStartColor:[self leftGradientStartColor].CGColor
                           withEndColor:[self leftGradientEndColor].CGColor
                          withDirection:LeftToRight];
    
    [self drawLinearGradientWithContext:context
                               withRect:CGRectMake([self width] / 3 * 2, 0, [self width] / 3, [self height])
                         withStartColor:[self rightGradientStartColor].CGColor
                           withEndColor:[self rightGradientEndColor].CGColor
                          withDirection:LeftToRight];
}

- (void)drawLinearGradientWithContext:(CGContextRef)context
                             withRect:(CGRect)rect
                       withStartColor:(CGColorRef)startColor
                         withEndColor:(CGColorRef)endColor
                        withDirection:(GradientDirection)direction {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    switch (direction) {
        case LeftToRight:
            startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
            endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
            break;
            
        case TopToBottom:
            startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
            endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
            break;
    }
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
