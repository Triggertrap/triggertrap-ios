//
//  CubicBezierInterpolator.h
//  Triggertrap
//
//  Created by Ross Gibson on 01/04/2014.
//
//

#import <Foundation/Foundation.h>

@interface CubicBezierInterpolator : NSObject

- (instancetype)init;

- (NSArray *)pausesForExposures:(int)expCount sequenceDuration:(long)duration pulseLength:(long)pulse minimumGapBetweenPulses:(long)gap;

- (void)setControlPoints_x1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;

- (NSMutableArray *)overlapIndicies;
- (NSMutableArray *)adjustedPauses;

- (float)interpolation:(float)input;

- (NSArray *)timeIntervalsForExposures:(int)expCount sequenceDuration:(long)duration pulseLength:(long)pulse minimumGapBetweenPulses:(long)gap;

@end
