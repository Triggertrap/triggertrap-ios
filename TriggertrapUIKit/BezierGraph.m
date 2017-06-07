//
//  BezierGraph.m
//  Triggertrap
//
//  Created by Valentin Kalchev on 03/06/2014.
//
//

#import "BezierGraph.h"
//#import "UIButton+Extensions.h"
#import "UIColor+branding.h"
#import "ControlPoint.h"

#define CLAMP(x, low, high) ({\
__typeof__(x) __x = (x); \
__typeof__(low) __low = (low);\
__typeof__(high) __high = (high);\
__x > __high ? __high : (__x < __low ? __low : __x);\
})

#define kViewToGraphOffset 12
#define kControlPointDiameter 20
#define degreesToRadians(degrees) ((degrees) / 180.0 * M_PI)

@interface BezierGraph () {
    
    //Start and end of the bezier curve
    CGPoint point1;
    CGPoint point2;
    
    //Buttons for control point 1 and 2
    ControlPoint *controlPoint1Button;
    ControlPoint *controlPoint2Button;
    
    //View location e.g 200, 300
    CGPoint controlPoint1ViewLocation;
    CGPoint controlPoint2ViewLocation;
    
    //Graph location e.g 0.35f, 0.56f (0 - 1 range)
    CGPoint controlPoint1GraphLocation;
    CGPoint controlPoint2GraphLocation;
    
    //Only draw overlapping exposures when user releases the control points
    BOOL drawOverlappingExposures;
    
    //Stores circles to be drawn for overlapping exposures
    NSMutableArray *overlappingExposures;
    
    NSUserDefaults *defaults;
    
    UIColor *curveColor;
    UIColor *overlappingExposuresColor;
    UIColor *pointFillColor;
    UIColor *pointBorderColor;
}
@end

typedef NS_OPTIONS (NSInteger, ControlPointType){
    ControlPoint1,
    ControlPoint2
};

@implementation BezierGraph

#pragma mark - Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializeGraphView];
    }
    return self;
}

- (void)initializeGraphView {

    drawOverlappingExposures = NO;
    defaults = [NSUserDefaults standardUserDefaults];
    
    //Control Point 1 Button
    controlPoint1Button = [[ControlPoint alloc] initWithFrame:CGRectMake(0, 0, kControlPointDiameter, kControlPointDiameter)];
    [self createControlPoint:controlPoint1Button withKey:kBezierGraphControlPoint1];
    
    //Control Point 2 Button
    controlPoint2Button = [[ControlPoint alloc] initWithFrame:CGRectMake(0, 0, kControlPointDiameter, kControlPointDiameter)];
    [self createControlPoint:controlPoint2Button withKey:kBezierGraphControlPoint2];
    
    //Calculate point1 and point2 locations using the 0, 0 and 1, 1 coordinates from the graph
    point1 = [self graphToViewPoint:CGPointMake(0, 0)];
    point2 = [self graphToViewPoint:CGPointMake(1, 1)];
    
    curveColor = [UIColor TTRedColour];
    overlappingExposuresColor = [UIColor TTRedColour];
    pointFillColor = [UIColor TTLightGreyColour];
    pointBorderColor = [UIColor grayColor];
}

- (void)createControlPoint:(ControlPoint *)controlPoint withKey:(NSString *)key {
    
    [controlPoint setBackgroundImage:[UIImage imageNamed:@"timeWarpControlPoint"] forState:UIControlStateNormal];
    
    //When user drags the button
	[controlPoint addTarget:self action:@selector(controlPointWasMoved:withEvent:)
                  forControlEvents:UIControlEventTouchDragInside];
    
    //When user drags outside the UIView and releases their finger
	[controlPoint addTarget:self action:@selector(buttonWasReleased)
                  forControlEvents:UIControlEventTouchDragExit];
    
    //When user drags inside the UIView and releases their finger
	[controlPoint addTarget:self action:@selector(buttonWasReleased)
                  forControlEvents:UIControlEventTouchUpInside];
    
    //Check if default for that key exists and get its value or create default value
    if (![defaults objectForKey:key]) {
        
        CGPoint viewPoint = [key isEqualToString:kBezierGraphControlPoint1] ? [self graphToViewPoint:CGPointMake(0.5f, 0)] : [self graphToViewPoint:CGPointMake(0.5f, 1)];
        
        controlPoint.center = CGPointMake(viewPoint.x, viewPoint.y);
        
        CGPoint viewToGraphPoint = [self viewToGraphPoint:CGPointMake(controlPoint.frame.origin.x, controlPoint.frame.origin.y)];
        NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:viewToGraphPoint.x], [NSNumber numberWithFloat:viewToGraphPoint.y], nil];
        [defaults setObject:array forKey:key];
        [defaults synchronize];
    } else {
        NSArray *array = [defaults objectForKey:key];
        CGPoint point = [self graphToViewPoint:CGPointMake([array[0] floatValue], [array[1] floatValue])];
        controlPoint.center = CGPointMake(point.x, point.y);
    }
    
    controlPoint.userInteractionEnabled = YES;
    
    //Increase the array that the user can tap the button
    [controlPoint setHitTestEdgeInsets:UIEdgeInsetsMake(-kControlPointDiameter, -kControlPointDiameter, -kControlPointDiameter, -kControlPointDiameter)];
    
    [self addSubview:controlPoint];
    
    //Calculate controlPoint1 and controlPoint2 locations using button1 and button2
    controlPoint1ViewLocation = CGPointMake(controlPoint1Button.center.x, controlPoint1Button.center.y);
    controlPoint2ViewLocation = CGPointMake(controlPoint2Button.center.x, controlPoint2Button.center.y);
    
    //Assign the view location value from the control point 1 & 2 to graph value (0 - 1)
    controlPoint1GraphLocation = [self viewToGraphPoint:controlPoint1Button.center];
    controlPoint2GraphLocation = [self viewToGraphPoint:controlPoint2Button.center];
}

//User rotates the device
- (void)updateViewComponentsAfterRotation {
    
    //Update point 1 and 2 with the new graph coordinates after rotation
    point1 = [self graphToViewPoint:CGPointMake(0, 0)];
    point2 = [self graphToViewPoint:CGPointMake(1, 1)];
    
    controlPoint1ViewLocation = [self graphToViewPoint:controlPoint1GraphLocation];
    controlPoint2ViewLocation = [self graphToViewPoint:controlPoint2GraphLocation];
    
    controlPoint1Button.center = controlPoint1ViewLocation;
    controlPoint2Button.center = controlPoint2ViewLocation;
}

#pragma mark - View & Graph calculators

//E.g. change 0.35 to 230 (UIView width/height)
- (CGPoint)graphToViewPoint:(CGPoint)point {
    
    float viewPointX = kViewToGraphOffset + point.x * (self.frame.size.width - 2 * kViewToGraphOffset);
    float viewPointY = (1 - point.y) * (self.frame.size.height - 2 * kViewToGraphOffset) + kViewToGraphOffset;
    
    return CGPointMake(viewPointX, viewPointY);
}

//E.g. change 230 to 0.35 (0-1 range)
- (CGPoint)viewToGraphPoint:(CGPoint)point {
    
    float graphPointX = (point.x - kViewToGraphOffset) / (self.frame.size.width - 2 * kViewToGraphOffset);
    float graphPointY = 1 - (point.y - kViewToGraphOffset) / (self.frame.size.height - 2 * kViewToGraphOffset);
    
    return CGPointMake(graphPointX, graphPointY);
}

- (void)setCurveColor:(UIColor *)color {
    curveColor = color;
    [self setNeedsDisplay];
}

- (void)setPointFillColor:(UIColor *)color {
    pointFillColor = color;
    [self setNeedsDisplay];
}

- (void)setPointBorderColor:(UIColor *)color {
    pointBorderColor = color;
    [self setNeedsDisplay];
}

- (void)setOverlappingExposuresColor:(UIColor *)color {
    overlappingExposuresColor = color;
    [self setNeedsDisplay];
}

#pragma mark - Action

- (void)controlPointWasMoved:(UIButton *)button withEvent:(UIEvent *)event {
    
	// get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
    
    CGPoint location = [touch locationInView:self];
    
    int controlX = CLAMP(location.x, kViewToGraphOffset, self.frame.size.width - kViewToGraphOffset);
    int controlY = CLAMP(location.y, kViewToGraphOffset, self.frame.size.height - kViewToGraphOffset);
    
    if ([touch view] == controlPoint1Button) {
        [self buttonMoved:controlPoint1Button withLocation:CGPointMake(controlX, controlY) withType:ControlPoint1];
        [self setNeedsDisplay];
        
        return;
        
    } else if ([touch view] == controlPoint2Button) {
        [self buttonMoved:controlPoint2Button withLocation:CGPointMake(controlX, controlY) withType:ControlPoint2];
        [self setNeedsDisplay];
        
        return;
    }
}

- (void)buttonMoved:(UIButton *)button withLocation:(CGPoint)location withType:(ControlPointType)type {
    
    button.center = location;
    
    switch (type) {
        case ControlPoint1:
            controlPoint1ViewLocation = location;
            controlPoint1GraphLocation = [self viewToGraphPoint:location];
            break;
        case ControlPoint2:
            controlPoint2ViewLocation = location;
            controlPoint2GraphLocation = [self viewToGraphPoint:location];
            break;
    }
}

//Called when user releases their finger from the control point they have moved
- (void)buttonWasReleased {
    
    [defaults setObject:[self positionForControlPoint:controlPoint1GraphLocation.x withY:controlPoint1GraphLocation.y] forKey:kBezierGraphControlPoint1];
    [defaults setObject:[self positionForControlPoint:controlPoint2GraphLocation.x withY:controlPoint2GraphLocation.y] forKey:kBezierGraphControlPoint2];
    [defaults synchronize];
    
    if (_controlPointReleasedDelegate) {
        //Call method in TimeWarpViewController which calculates if there are any overlaps
        [_controlPointReleasedDelegate performSelector:@selector(controlPointReleased)];
    }
}

//Create an array from x and y and returns it
- (NSArray *)positionForControlPoint:(float)x withY:(float)y {
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil];
    return array;
}

#pragma mark - Getters

- (CGPoint)controlPoint1GraphLocation {
    return controlPoint1GraphLocation;
}

- (CGPoint)controlPoint2GraphLocation {
    return controlPoint2GraphLocation;
}

#pragma mark - Overlapping Points

- (void)overlappingPointsWithTime:(NSMutableArray *)timeOverlapIndicies withProgression:(NSMutableArray *)progressionOverlapIndicies {
    
    overlappingExposures = [NSMutableArray new];
    
    for (int i = 0; i < timeOverlapIndicies.count; i++) {
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:[self graphToViewPoint:CGPointMake([timeOverlapIndicies[i] floatValue], [progressionOverlapIndicies[i] floatValue])] radius:10 startAngle:degreesToRadians(0) endAngle:degreesToRadians(360) clockwise:YES];
        
        // Adjust the drawing options as needed.
        path.lineWidth = 2;
        
        [overlappingExposures addObject:path];
    }
    
    drawOverlappingExposures = YES;
    
    [self setNeedsDisplay];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    
    [self drawGraphBackground];
    
    [self drawWithPoint:point1 toControlPoint:controlPoint1ViewLocation];
    [self drawWithPoint:point2 toControlPoint:controlPoint2ViewLocation];
    
    [self drawBezierCurve];
    
    [overlappingExposuresColor setStroke];
    [[UIColor clearColor] setFill];
    
    //Circles
    if (drawOverlappingExposures) {
        
        for (UIBezierPath *path in overlappingExposures) {
            [path fill];
            [path stroke];
        }
        drawOverlappingExposures = NO;
    }
}

- (void)drawGraphBackground {
    CALayer *graphBackgroundLayer = [self layer];
    
    [graphBackgroundLayer setMasksToBounds:YES];
    [graphBackgroundLayer setCornerRadius:10.0f];
    [graphBackgroundLayer setBorderWidth:1.0f];
    [graphBackgroundLayer setBorderColor: pointBorderColor.CGColor];
}

- (void)drawWithPoint:(CGPoint)point toControlPoint:(CGPoint)controlPoint {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    [path addLineToPoint:controlPoint];
    
    // Set the render colors.
    [pointBorderColor setStroke];
    [pointFillColor setFill];
    
    path.lineWidth = 2;
    
    [path fill];
    [path stroke];
}

- (void)drawBezierCurve {
    
    //Control point 1 line
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addCurveToPoint:point2 controlPoint1:controlPoint1ViewLocation controlPoint2:controlPoint2ViewLocation];
    
    // Set the render colors.
    [curveColor setStroke];
    
    // Adjust the drawing options as needed.
    path.lineWidth = 3;
    [path stroke];
}

@end