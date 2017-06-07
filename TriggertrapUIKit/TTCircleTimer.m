//
//  TTCircleTimer.m
//  Triggertrap
//
//  Created by Ross Gibson on 21/08/2013.
//
//

#import "TTCircleTimer.h"

@interface TTCircleTimer () {
    
}

@property (strong, nonatomic) NSTimer *clockTimer;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) double startTime;

@end

@implementation TTCircleTimer

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    // Initialization code
    DACircularProgressView *circularProgressViewAppearance = [DACircularProgressView appearance];
    [circularProgressViewAppearance setTrackTintColor:[UIColor colorWithRed:165.0f / 255.0f green:22.0f / 255.0f blue:16.0f / 255.0f alpha:1.0f]];
    [circularProgressViewAppearance setProgressTintColor:[UIColor whiteColor]];
    [circularProgressViewAppearance setBackgroundColor:[UIColor clearColor]];
    [circularProgressViewAppearance setThicknessRatio:0.02f];
    [circularProgressViewAppearance setRoundedCorners:YES];
    [circularProgressViewAppearance setClockwiseProgress:YES];
    [circularProgressViewAppearance setIndeterminateDuration:1.0f];
    
    self.cycleDuration = 1; // Default to use 1 second
    self.progressDirection = kProgressDirectionClockwise;
    self.continuous = YES;
}

#pragma mark - Private

- (void)clockDidTick:(NSTimer *)timer {
    double currentTime = CFAbsoluteTimeGetCurrent();
    double elapsedTime = currentTime - self.startTime;
    double cycle = self.cycleDuration;
    
    if (self.progressDirection == kProgressDirectionAntiClockwise) {
        CGFloat progress = 1.0f - (CGFloat)(elapsedTime / cycle);
        [self setProgress:progress animated:YES];
        
        if (self.continuous && progress <= 0.0f) {
            [self repeat];
        } else if (progress <= 0.0f && self.delegate && [self.delegate respondsToSelector:@selector(progressComplete)]) {
            [self.delegate performSelector:@selector(progressComplete)];
        }
    } else {
        CGFloat progress = (CGFloat)(elapsedTime / cycle);
        [self setProgress:progress animated:YES];
        
        if (self.continuous && progress >= 1.0f) {
            [self repeat];
        } else if (progress >= 1.0f && self.delegate && [self.delegate respondsToSelector:@selector(progressComplete)]) {
            [self.delegate performSelector:@selector(progressComplete)];
        }
    }
}

#pragma mark - Public

- (void)start {
    if (self.running) return;
    
    if (![super indeterminate]) {
        if (self.progressDirection == kProgressDirectionAntiClockwise) {
            [self setProgress:1.0f animated:NO];
        } else {
            [self setProgress:0.0f animated:NO];
        }
        
        self.startTime = CFAbsoluteTimeGetCurrent();
        
        self.clockTimer = [NSTimer timerWithTimeInterval:0.02
                                                  target:self
                                                selector:@selector(clockDidTick:)
                                                userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.clockTimer forMode:NSRunLoopCommonModes];
    }
    
    self.running = YES;
    self.isRunning = YES;
}

- (void)stop {
    if (![self indeterminate]) {
        if (self.clockTimer) {
            [self.clockTimer invalidate];
            self.clockTimer = nil;
        }
        
        if (self.progressDirection == kProgressDirectionAntiClockwise) {
            [self setProgress:1.0f animated:NO];
        } else {
            [self setProgress:0.0f animated:NO];
        }
    }
    
    self.running = NO;
    self.isRunning = NO;
    self.progress = 0.0;
    
//    self.indeterminate = NO;
    
//    DACircularProgressView *circularProgressViewAppearance = [DACircularProgressView appearance];
//    [circularProgressViewAppearance setIndeterminate:NO];
}

- (void)repeat {
    if (![self indeterminate]) {
        if (self.progressDirection == kProgressDirectionAntiClockwise) {
            [self setProgress:1.0f animated:NO];
        } else {
            [self setProgress:0.0f animated:NO];
        }
        
        self.startTime = CFAbsoluteTimeGetCurrent();
    }
}

@end
