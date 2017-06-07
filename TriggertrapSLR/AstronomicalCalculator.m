//
//  AstronomicalCalculator.m
//  KosherCocoa
//
//  Created by Moshe Berman on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AstronomicalCalculator.h"

@implementation AstronomicalCalculator

- (double)UTCSunriseForDate:(NSDate *)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation {
    NSAssert(0==1, @"This method must be overridden in a subclass.");
    return 0;
}

- (double)UTCSunsetForDate:(NSDate *)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation {
    NSAssert(0==1, @"This method must be overridden in a subclass.");    
    return 0;
}
@end
