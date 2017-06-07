//
//  AstronomicalCalendar.h
//  KosherCocoa
//
//  Created by Moshe Berman on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GeoLocation.h"
#import "AstronomicalCalculator.h"
#import "SunriseAndSunset.h"

@interface AstronomicalCalendar : NSObject

@property (nonatomic, retain) GeoLocation *geoLocation;
@property (nonatomic, retain) SunriseAndSunset *astronomicalCalculator;
@property (nonatomic, retain) NSDate *workingDate;

//
//  Designated Initializer
//

- (id) initWithLocation:(GeoLocation *)AGeoLocation;

- (NSDate *) sunrise;

- (NSDate *) seaLevelSunrise;

- (NSDate *) beginCivilTwilight;

- (NSDate *) beginNauticalTwilight;

- (NSDate *) beginAstronomicalTwilight;

- (NSDate *) sunset;

- (NSDate *) seaLevelSunset;

- (NSDate *) adjustedSunsetDateWithSunset:(NSDate *)sunset andSunrise:(NSDate *)sunrise;

- (NSDate *) endCivilTwilight;

- (NSDate *) endNauticalTwilight;

- (NSDate *) endAstronomicalTwilight;

- (NSDate *) sunriseOffsetByDegrees:(double)offsetZenith;

- (NSDate *) sunsetOffsetByDegrees:(double)offsetZenith;

- (double) UTCSunrise:(double)zenith;

- (double) UTCSeaLevelSunrise:(double)zenith;

- (double) UTCSunset:(double)zenith;

- (double) UTCSeaLevelSunset:(double)zenith;

- (double) temporalHourFromSunrise:(NSDate *)sunrise toSunset:(NSDate *)sunset;

- (NSDate *) sunTransit;

//
//  A method that returns the calculated time
//  as an NSDate object based on the user's time zone
//  and today's date.
//  

- (NSDate *)dateFromTime:(double)time;

//
//  A method that returns the calculated time
//  as an NSDate object based on a given time
//  zone and a given date. 
//
//  Returns nil if the time passed in is NAN.
//  

- (NSDate *)dateFromTime:(double)time inTimeZone:(NSTimeZone *)tz onDate:(NSDate *)date;

//
//
//
- (NSString *)stringFromDate:(NSDate *)date forTimeZone:(NSTimeZone *)tz withSeconds:(BOOL)shouldShowSeconds;
- (NSString *)stringFromDate:(NSDate *)date forTimeZone:(NSTimeZone *)tz;

@end
