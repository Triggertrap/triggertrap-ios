//
//  CubicBezierInterpolator.m
//  Triggertrap
//
//  Created by Ross Gibson on 01/04/2014.
//
//

#import "CubicBezierInterpolator.h"

@interface CubicBezierInterpolator () {
    NSMutableArray *overlapIndicies;
    NSMutableArray *adjustedPauses;
}
@end

@implementation CubicBezierInterpolator

// Algorithm loses accuracy above these levels.
float const MAX_VALUE = 0.98f;
float const MIN_VALUE = 0.02f;

float mX1, mY1, mX2, mY2;

#pragma mark - Public

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (NSMutableArray *)overlapIndicies {
    return overlapIndicies;
}

- (NSMutableArray *)adjustedPauses {
    return adjustedPauses;
}

- (NSArray *)pausesForExposures:(int)expCount sequenceDuration:(long)duration pulseLength:(long)pulse minimumGapBetweenPulses:(long)gap {
    if (overlapIndicies) {
        overlapIndicies = nil;
    }
    
    if (adjustedPauses) {
        adjustedPauses = nil;
    }
    
    overlapIndicies = [NSMutableArray new];
    adjustedPauses = [NSMutableArray new];
    
    NSMutableArray *pauses = [NSMutableArray arrayWithCapacity:expCount];
    NSArray *timeIntervals = [self timeIntervalsForExposures:expCount sequenceDuration:duration pulseLength:pulse minimumGapBetweenPulses:gap];
    
    [self logArray:timeIntervals];
    
    BOOL inNegativeSequence = NO;
    
    for (int i = 0; i < expCount; i++) {
        if (i == (expCount - 1)) {
            [pauses insertObject:[NSNumber numberWithLong:0] atIndex:i];
        } else {
            [pauses insertObject:[NSNumber numberWithLong:([[timeIntervals objectAtIndex:(i + 1)] longValue] - [[timeIntervals objectAtIndex:i] longValue] - pulse)] atIndex:i];
            
            // Track where we have overlaps so we can correct by dropping shots.
            if (([[pauses objectAtIndex:i] longValue] < gap || [[pauses objectAtIndex:i] longValue] > ULONG_MAX) && !inNegativeSequence) { // gap was  <=0
                [overlapIndicies addObject:[NSNumber numberWithInt:i]];
                inNegativeSequence = YES;
            } else if ([[pauses objectAtIndex:i] longValue] > 0 && inNegativeSequence) {
                [overlapIndicies addObject:[NSNumber numberWithInt:i]];
                inNegativeSequence = NO;
            }
        }
    }
    
    [self logArray:overlapIndicies];
    
    for (int i = 0 ; i < expCount; i++) {
        if ([[pauses objectAtIndex:i] longValue] > gap && [[pauses objectAtIndex:i] longValue] < ULONG_MAX) {
            [adjustedPauses addObject:[pauses objectAtIndex:i]];
        } else {
            [adjustedPauses addObject:[NSNumber numberWithLong:gap]];
        }
    }
    
    [self logArray:adjustedPauses];
    
    return adjustedPauses;
}

#pragma mark - Setters

- (void)setControlPoints_x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 {
    [self setControlsInRange_x1:x1 y1:y1 x2:x2 y2:y2];
}

#pragma mark - Private

- (void)setControlsInRange_x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 {
    if (x1 > MAX_VALUE) {
        mX1 = MAX_VALUE;
    } else if (x1 < MIN_VALUE) {
        mX1 = MIN_VALUE;
    } else {
        mX1 = x1;
    }
    
    if (y1 > MAX_VALUE) {
        mY1 = MAX_VALUE;
    } else if (y1 < MIN_VALUE) {
        mY1 = MIN_VALUE;
    } else {
        mY1 = y1;
    }
    
    if (x2 > MAX_VALUE) {
        mX2 = MAX_VALUE;
    } else if (x2 < MIN_VALUE) {
        mX2 = MIN_VALUE;
    } else {
        mX2 = x2;
    }
    
    if (y2 > MAX_VALUE) {
        mY2 = MAX_VALUE;
    } else if (y2 < MIN_VALUE) {
        mY2 = MIN_VALUE;
    } else {
        mY2 = y2;
    }
}

- (float)interpolation:(float)input {
    if ((mX1 == mY1) && (mX2 == mY2)) {
        // Linear.
        return input;
    } else {
        return [self calcBezier_aT:[self tForX:input] aA1:mY1 aA2:mY2];
    }
}

- (NSArray *)timeIntervalsForExposures:(int)expCount sequenceDuration:(long)duration pulseLength:(long)pulse minimumGapBetweenPulses:(long)gap {
    NSMutableArray *timeIntervals = [NSMutableArray arrayWithCapacity:expCount];
    
    for (int i = 0; i < expCount; i++) {
        float fraction = ((float)i / ((float)expCount - 1.0));
        
        [timeIntervals insertObject:[NSNumber numberWithLong:([self interpolation:fraction] * duration)] atIndex:i];
    }
    
    return timeIntervals;
}

- (float)calcBezier_aT:(float)aT aA1:(float)aA1 aA2:(float)aA2 {
    float A = [self aaA1:aA1 aA2:aA2];
    float B = [self baA1:aA1 aA2:aA2];
    float C = [self caA1:aA1];
    
    return ((((A * aT) + B) * aT) + C) * aT;
}

- (float)slopeForT:(float)aT aA1:(float)aA1 aA2:(float)aA2 {
    float A = [self aaA1:aA1 aA2:aA2];
    float B = [self baA1:aA1 aA2:aA2];
    float C = [self caA1:aA1];
    
    return 3.0f * A * aT * aT + 2.0f * B * aT + C;
}

- (float)tForX:(float)aX {
    // Newton Raphson iteration.
    float aGuessT = aX;
    
    for (int i = 0; i < 4; ++i) {
        float currentSlope = [self slopeForT:aGuessT aA1:mX1 aA2:mX2];
        
        if (currentSlope == 0.0) {
            return aGuessT;
        } else {
            float currentX = ([self calcBezier_aT:aGuessT aA1:mX1 aA2:mX2] - aX);
            aGuessT -= currentX / currentSlope;
        }
    }
    
    return aGuessT;
}

#pragma mark - Helpers

- (float)aaA1:(float)aA1 aA2:(float)aA2 {
    return 1.0f - 3.0f * aA2 + 3.0f * aA1;
}

- (float)baA1:(float)aA1 aA2:(float)aA2 {
    return 3.0f * aA2 - 6.0f * aA1;
}

- (float)caA1:(float)aA1 {
    return 3.0f * aA1;
}

- (void)logArray:(NSArray *)array {
#if DEBUG
    NSMutableString *str = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < array.count; i++) {
        [str appendString:[NSString stringWithFormat:@"%ld ", [[array objectAtIndex:i] longValue]]];
    } 
#else
    return;
#endif
}

@end
