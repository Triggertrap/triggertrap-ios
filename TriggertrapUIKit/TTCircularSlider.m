//
//  TTCircularSlider.m
//  Triggertrap
//
//  Created by Ross Gibson on 29/07/2013.
//
//

#import "TTCircularSlider.h"
#import "UIColor+branding.h"

@interface TTCircularSlider()

@property (nonatomic) CGPoint thumbCenterPoint;

@property (strong, nonatomic) UIImageView *sliderThumb;

- (void)setup;
- (BOOL)isPointInThumb:(CGPoint)point;
- (CGFloat)sliderRadius;
- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint;
- (CGPoint)drawCircularTrack:(float)track atPoint:(CGPoint)point withRadius:(CGFloat)radius inContext:(CGContextRef)context;

@end

@implementation TTCircularSlider

#define kThumbRadius 15.0
#define kCircularSliderArc 1.6

@synthesize lineWidth = _lineWidth;
- (void)setLineWidth:(float)lineWidth {
	if (lineWidth != _lineWidth) {
		_lineWidth = lineWidth;
	}
}

@synthesize thumbImage = _thumbImage;
- (void)setThumbImage:(NSString *)thumbImage {
    if (![thumbImage isEqualToString:_thumbImage]) {
        _thumbImage = thumbImage;
        
        if (_sliderThumb != nil) {
            _sliderThumb.image = [UIImage imageNamed:_thumbImage];
        }
        
        [self setNeedsDisplay];
    }
}

@synthesize value = _value;

- (void)setValue:(float)value {
	if (value != _value) {
		if (value > self.maximumValue) { value = self.maximumValue; }
		if (value < self.minimumValue) { value = self.minimumValue; }
		_value = value;
		[self setNeedsDisplay];
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

@synthesize minimumValue = _minimumValue;
- (void)setMinimumValue:(float)minimumValue {
	if (minimumValue != _minimumValue) {
		_minimumValue = minimumValue;
        
		if (self.maximumValue < self.minimumValue) {
            self.maximumValue = self.minimumValue;
        }
        
		if (self.value < self.minimumValue) {
            self.value = self.minimumValue;
        }
	}
}

@synthesize maximumValue = _maximumValue;
- (void)setMaximumValue:(float)maximumValue {
	if (maximumValue != _maximumValue) {
		_maximumValue = maximumValue;
        
		if (self.minimumValue > self.maximumValue) {
            self.minimumValue = self.maximumValue;
        }
        
		if (self.value > self.maximumValue) {
            self.value = self.maximumValue;
        }
	}
}

@synthesize minimumTrackTintColor = _minimumTrackTintColor;
- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
	if (![minimumTrackTintColor isEqual:_minimumTrackTintColor]) {
		_minimumTrackTintColor = minimumTrackTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize maximumTrackTintColor = _maximumTrackTintColor;
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
	if (![maximumTrackTintColor isEqual:_maximumTrackTintColor]) {
		_maximumTrackTintColor = maximumTrackTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize continuous = _continuous;

@synthesize thumbCenterPoint = _thumbCenterPoint;


#pragma mark - Init and Setup methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
	[self setup];
}

- (void)setup {
	self.value = 0.0;
	self.minimumValue = 0.0;
	self.maximumValue = 1.0;
    self.lineWidth = 2.0;
	self.minimumTrackTintColor = [UIColor TTRedColour];
	self.maximumTrackTintColor = [UIColor TTMediumGreyColour];
	self.continuous = YES;
	self.thumbCenterPoint = CGPointZero;
    self.thumbImage = @"slider-thumb";
    self.backgroundColor = [UIColor clearColor];
	
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHappened:)];
	[self addGestureRecognizer:tapGestureRecognizer];
	
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHappened:)];
	panGestureRecognizer.maximumNumberOfTouches = panGestureRecognizer.minimumNumberOfTouches;
	[self addGestureRecognizer:panGestureRecognizer];
    
    // Rotate the control to make the starting point at the bottom
    self.transform = CGAffineTransformMakeRotation(M_PI + (((2 * M_PI) - (kCircularSliderArc * M_PI)) / 2));
}

#pragma mark - Drawing methods

- (CGFloat)sliderRadius {
	CGFloat radius = MIN(self.bounds.size.width / 2, self.bounds.size.height / 2);
	radius -= MAX(self.lineWidth, kThumbRadius);
	return radius;
}

- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint {
    if (!_sliderThumb) {
        if (self.thumbImage != nil) {
            self.sliderThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.thumbImage]];
            [self addSubview:_sliderThumb];
        }
    }
    
    _sliderThumb.center = sliderButtonCenterPoint;
}

- (CGPoint)drawCircularTrack:(float)track atPoint:(CGPoint)center withRadius:(CGFloat)radius inContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
	CGContextBeginPath(context);
	
	float angleFromTrack = translateValueFromSourceIntervalToDestinationInterval(track, self.minimumValue, self.maximumValue, 0, kCircularSliderArc * M_PI);
	
	CGFloat startAngle = -M_PI_2;
	CGFloat endAngle = startAngle + angleFromTrack;
	CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, NO);
	
	CGPoint arcEndPoint = CGContextGetPathCurrentPoint(context);
	
	CGContextStrokePath(context);
	UIGraphicsPopContext();
	
	return arcEndPoint;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGPoint middlePoint;
	middlePoint.x = self.bounds.origin.x + self.bounds.size.width / 2;
	middlePoint.y = self.bounds.origin.y + self.bounds.size.height / 2;
	
	CGContextSetLineWidth(context, self.lineWidth);
	
	CGFloat radius = [self sliderRadius];
    
	[self.maximumTrackTintColor setStroke];
    [self drawCircularTrack:self.maximumValue atPoint:middlePoint withRadius:radius inContext:context];
    [self.minimumTrackTintColor setStroke];
    self.thumbCenterPoint = [self drawCircularTrack:self.value atPoint:middlePoint withRadius:radius inContext:context];
	
	[self drawThumbAtPoint:self.thumbCenterPoint];
}


#pragma mark - Thumb management methods

- (BOOL)isPointInThumb:(CGPoint)point {
	CGRect thumbTouchRect = CGRectMake(self.thumbCenterPoint.x - kThumbRadius, self.thumbCenterPoint.y - kThumbRadius, kThumbRadius * 2, kThumbRadius * 2);
	return CGRectContainsPoint(thumbTouchRect, point);
}


#pragma mark - UIGestureRecognizer management methods

- (void)panGestureHappened:(UIPanGestureRecognizer *)panGestureRecognizer {
	CGPoint tapLocation = [panGestureRecognizer locationInView:self];
    
	switch (panGestureRecognizer.state) {
		case UIGestureRecognizerStateChanged: {
			CGFloat radius = [self sliderRadius];
			CGPoint sliderCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
			CGPoint sliderStartPoint = CGPointMake(sliderCenter.x, sliderCenter.y - radius);
			CGFloat angle = angleBetweenThreePoints(sliderCenter, sliderStartPoint, tapLocation);
			
			if (angle < 0) {
				angle = -angle;
			} else {
				angle = 2 * M_PI - angle;
			}
            
            // Prevent the slider from 'jumping the gap' between 0 and 1 at the ends on the arc.
            float val = translateValueFromSourceIntervalToDestinationInterval(angle, 0, kCircularSliderArc * M_PI, self.minimumValue, self.maximumValue);
            
            if (val >= self.minimumValue && val <= self.maximumValue) {
                self.value = val;
                
                if (_delegate && [_delegate respondsToSelector:@selector(circularSliderValueChanged:)]) {
                    [_delegate performSelector:@selector(circularSliderValueChanged:) withObject:[NSNumber numberWithFloat:self.value]];
                }
            } else {
                return;
            }
			
			break;
		}
		default:
			break;
	}
}

- (void)tapGestureHappened:(UITapGestureRecognizer *)tapGestureRecognizer {
	if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		CGPoint tapLocation = [tapGestureRecognizer locationInView:self];
        
		if ([self isPointInThumb:tapLocation]) {
            
		} else {
            
		}
	}
}

@end


#pragma mark - Utility Functions

float translateValueFromSourceIntervalToDestinationInterval(float sourceValue, float sourceIntervalMinimum, float sourceIntervalMaximum, float destinationIntervalMinimum, float destinationIntervalMaximum) {
	float a, b, destinationValue;
	
	a = (destinationIntervalMaximum - destinationIntervalMinimum) / (sourceIntervalMaximum - sourceIntervalMinimum);
	b = destinationIntervalMaximum - (a * sourceIntervalMaximum);
	
	destinationValue = (a * sourceValue) + b;
	
	return destinationValue;
}

CGFloat angleBetweenThreePoints(CGPoint centerPoint, CGPoint p1, CGPoint p2) {
	CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
	CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
	
	CGFloat angle = atan2f(v2.x * v1.y - v1.x * v2.y, v1.x * v2.x + v1.y * v2.y);
	
	return angle;
}
