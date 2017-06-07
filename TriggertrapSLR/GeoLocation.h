//
//  GeoLocation.h
//  Zmanim
//
//  Created by Moshe Berman on 3/22/11.
//  Copyright 2011 MosheBerman.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "KosherCocoaConstants.h"

@interface GeoLocation : NSObject {
    
    double latitude;
    double longitude;
    NSString *locationName;
    NSTimeZone *timeZone;
    double altitude;
    
}

@property double latitude;
@property double longitude;
@property double altitude;
@property (nonatomic, retain) NSString *locationName;
@property (nonatomic, retain) NSTimeZone *timeZone;

//
//  Initializers
//

- (id) initWithName:(NSString *)name andLatitude:(double)_latitude andLongitude:(double)_longitude andTimeZone:(NSTimeZone *)timezone;

//
//
//

- (id) initWithName:(NSString *)name andLatitude:(double)_latitude andLongitude:(double)_longitude andElevation:(double)_elevation andTimeZone:(NSTimeZone *)timezone;

//
//
//

- (double) vincentyFormulaForLocation:(GeoLocation *)location withBearing:(int)formula;

//
//
//

- (long) localMeanTimeOffset;

@end
