//
//  SunriseAndSunset.h
//  Zmanim
//
//  Created by Moshe Berman on 3/29/11.
//  Copyright 2011 MosheBerman.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathAdditions.h"
#import "GeoLocation.h"
#import "KosherCocoaConstants.h"
#import "AstronomicalCalculator.h"

//
//  The class interface
//

@interface SunriseAndSunset : AstronomicalCalculator {
    
    NSString *calculatorName;
    GeoLocation *geoLocation;
}

//
//  A string representing the name of the calculator
//

@property (nonatomic, retain) NSString *calculatorName;
@property (nonatomic, retain) GeoLocation *geoLocation;

//
//
//

- (id)initWithGeoLocation:(GeoLocation *)aGeoLocation;


//
//  A method returning the sunrise in UTC as a double. If an error was
//  encountered in the calculation (as expected in some locations, such
//  as near the poles) NAN will be returned.
//
//  - Year: a 4 digit year
//
//  - Month: month of the year 1-12
//
//  - Day: day of the month, 1-31
//
//  - Longitude: in degrees, longitudes west of Meridian are negative
//
//  - Latitude: in degrees, longitudes south of Equator are negative
//
//  - Type:  type of calculation to carry out. kCalcTypeSunrise or kCalcTypeSunset (int 0 or 1)
//
//

- (double) sunriseOrSunsetForYear:(int)year andMonth:(int)month andDay:(int)day atLongitude:(double)longitude andLatitude:(double)latitude withZenith:(double)zenith andType:(int)type;

//
//  Calculate the local mean time of rising or setting.
//  By `local' is meant the
//  exact time at the location, assuming that there were no time zone. That
//  is, the time difference between the location and the Meridian depended
//  entirely on the longitude. We can't do anything with this time directly;
//  we must convert it to UTC and then to a local time. The result is
//  expressed as a fractional number of hours since midnight
//

- (double) localMeanTimeForHour:(double)localHour andAscension:(double)sunRightAscensionHours andApproxTimeDays:(double)approxTimeDays;

//
//  Gets the cosine of the Sun's local hour angle
//

- (double) cosLocalHourAngleForAngle:(double)sunTrueLongitude andLatitude:(double)latitude andZenith:(double)zenith;

//
//  Calculates the Sun's right ascension in hours, given the Sun's true
//  longitude in degrees. Input and output are angles greater than 0 and
//  less than 360.
//

- (double)sunRightAscensionHoursForLongitude:(double)sunTrueLongitude;

//
//  Calculates the Sun's true longitude in degrees. The result is an angle
//  greater than 0 and less than 360. Requires the Sun's mean anomaly, also
//  in degrees.
//

- (double) sunTrueLongitudeFromAnomaly:(double)sunMeanAnomaly;

//
// Calculate the Sun's mean anomaly in degrees, at sunrise or sunset, given
// the longitude in degrees.
//


- (double)meanAnomalyForDayOfYear:(int)dayOfYear atLongitude:(double)longitude forCalculationType:(int)type;

//
// Gets the approximate time of sunset or sunrise In DAYS since midnight
// Jan 1st, assuming 6am and 6pm events. We need this figure to derive the
// Sun's mean anomaly.
//

- (double) approxTimeDaysForDayOfYear:(int)dayOfYear withHoursFromMeridian:(double)hoursFromMeridian forCalculationType:(int)type;


//
//  Get time difference between location's longitude and the Meridian, in
//  hours. West of Meridian has a negative time difference.
//

- (double) hoursFromMeridianForLongitude:(double)longitude;

//
// Calculate the day of the year, where Jan 1st is day 1. Note that this
// method needs to know the year, because leap years have an impact here
//

- (int) dayOfYearForYear:(int)year andMonth:(int)month andDay:(int)day;

//
//  Get sunrise as a double
//

- (double) UTCSunsetForDate:(NSDate*)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation;

//
//  Get sunset as a double
//
- 
(double) UTCSunriseForDate:(NSDate*)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation;
   
//
//  Break up a date object into day, month, year
//

- (NSArray *)yearMonthAndDayFromDate:(NSDate *)date;

//
//	Method to return the adjustment to the zenith required to account for the
//	elevation. Since a person at a higher elevation can see farther below the
//	horizon, the calculation for sunrise / sunset is calculated below the
//	horizon used at sea level. This is only used for sunrise and sunset and
//	not times above or below it such as
//	{@link AstronomicalCalendar#getBeginNauticalTwilight() nautical twilight}
//	since those calculations are based on the level of available light at the
//	given dip below the horizon, something that is not affected by elevation,
//	the adjustment should only made if the zenith == 90&deg;
//	{@link #adjustZenith adjusted} for refraction and solar radius.<br />
//	The algorithm used is:
//
//	<pre>
//	elevationAdjustment = Math.toDegrees(Math.acos(earthRadiusInMeters
//			/ (earthRadiusInMeters + elevationMeters)));
//	</pre>
//
//	The source of this algorthitm is <a
//	href="http://www.calendarists.com">Calendrical Calculations</a> by
//	Edward M. Reingold and Nachum Dershowitz. An alternate algorithm that
//	produces an almost identical (but not accurate) result found in Ma'aglay
//	Tzedek by Moishe Kosower and other sources is:
//
//	<pre>
//	elevationAdjustment = 0.0347 * Math.sqrt(elevationMeters);
//	</pre>
//
//	@param elevation
//	           elevation in Meters.
//	@return the adjusted zenith
//

- (double)elevationAdjustmentForElevation:(double)elevation;

//
//	Adjusts the zenith to account for solar refraction, solar radius and
//	elevation. The value for Sun's zenith and true rise/set Zenith (used in
//	this class and subclasses) is the angle that the center of the Sun makes
//	to a line perpendicular to the Earth's surface. If the Sun were a point
//	and the Earth were without an atmosphere, true sunset and sunrise would
//	correspond to a 90&deg; zenith. Because the Sun is not a point, and
//	because the atmosphere refracts light, this 90&deg; zenith does not, in
//	fact, correspond to true sunset or sunrise, instead the centre of the
//	Sun's disk must lie just below the horizon for the upper edge to be
//	obscured. This means that a zenith of just above 90&deg; must be used.
//	The Sun subtends an angle of 16 minutes of arc (this can be changed via
//	the {@link #setSolarRadius(double)} method , and atmospheric refraction
//	accounts for 34 minutes or so (this can be changed via the
//	{@link #setRefraction(double)} method), giving a total of 50 arcminutes.
//	The total value for ZENITH is 90+(5/6) or 90.8333333&deg; for true
//	sunrise/sunset. Since a person at an elevation can see blow the horizon
//	of a person at sea level, this will also adjust the zenith to account for
//	elevation if available. 
//
//	@return The zenith adjusted to include the
//	        {@link #getSolarRadius sun's radius},
//	        {@link #getRefraction refraction} and
//	        {@link #getElevationAdjustment elevation} adjustment.
//

-(double) adjustZenith:(double) zenith forElevation:(double) elevation;


@end
