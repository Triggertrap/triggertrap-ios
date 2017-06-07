//
//  AstronomicalCalculator.h
//  KosherCocoa
//
//  Created by Moshe Berman on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AstronomicalCalculator : NSObject


- (double)UTCSunriseForDate:(NSDate *)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation;

- (double)UTCSunsetForDate:(NSDate *)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation;

@end
