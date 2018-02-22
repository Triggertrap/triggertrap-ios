//
//  SunriseAndSunset.m
//  Zmanim
//
//  Created by Moshe Berman on 3/29/11.
//  Copyright 2011 MosheBerman.com. All rights reserved.
//

#import "SunriseAndSunset.h"

@implementation SunriseAndSunset

@synthesize calculatorName;
@synthesize geoLocation;

//
//  The initializer.
//

- (id)initWithGeoLocation:(GeoLocation *)aGeoLocation{
    
    if (self = [super init]) {
        
        [self setCalculatorName:@"US Naval Almanac Algorithm"];
        
        //
        //  If there's no GeoLocation, then
        //  create one for where the equator
        //  and the prime meridian meet.
        //
        
        
        if (aGeoLocation == nil) {
            
            //
            //  Create the GeoLocation
            //
            
            GeoLocation *tempG = [[GeoLocation alloc] initWithName:@"Default" andLatitude:0.0 andLongitude:0.0 andTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
            
            //
            //  Assign it to the geoLoc object
            //
            
            aGeoLocation = tempG;
            
        }
        
        //
        //  Store the geoLocation object
        //
        
        self.geoLocation = aGeoLocation;
    }
    
    return self;
}


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
//  - Type:  type of calculation to carry out. kCalcTypeSunrise or kCalcTypeSunset
//
//

- (double) sunriseOrSunsetForYear:(int)year andMonth:(int)month andDay:(int)day atLongitude:(double)longitude andLatitude:(double)latitude withZenith:(double)zenith andType:(int)type{
    
    int dayOfYear = [self dayOfYearForYear:year andMonth:month andDay:day];
    
    double sunMeanAnomaly = [self meanAnomalyForDayOfYear:dayOfYear atLongitude:longitude forCalculationType:type];
    
    double sunTrueLong = [self sunTrueLongitudeFromAnomaly:sunMeanAnomaly];
    
    double sunRightAscensionHours = [self sunRightAscensionHoursForLongitude:sunTrueLong];
    
    double cosLocalHourAngle = [self cosLocalHourAngleForAngle:sunTrueLong andLatitude:latitude andZenith:zenith];
    
    double localHourAngle = 0;
    
    if (type == kTypeSunrise) {
        if (cosLocalHourAngle > 1) { // no rise. No need for an Exception
                                     // since the calculation
                                     // will return Double.NaN
        }
        localHourAngle = 360.0 - acosDeg(cosLocalHourAngle);
    } else /* if (type == TYPE_SUNSET) */{
        if (cosLocalHourAngle < -1) {// no SET. No need for an Exception
                                     // since the calculation
                                     // will return Double.NaN
        }
        localHourAngle = acosDeg(cosLocalHourAngle);
    }
    double localHour = localHourAngle / kDegreesPerHour;
    
    double localMeanTime = [self localMeanTimeForHour:localHour andAscension:sunRightAscensionHours andApproxTimeDays:[self approxTimeDaysForDayOfYear:dayOfYear withHoursFromMeridian:[self hoursFromMeridianForLongitude:longitude] forCalculationType:type]];
    
    double processedTime = localMeanTime - [self hoursFromMeridianForLongitude:longitude];
    
    while (processedTime < 0.0) {
        processedTime = processedTime + 24.0;
    }
    
    while (processedTime >= 24.0) {
        processedTime = processedTime - 24.0;
    }
    
    return processedTime;
}



//
//  Calculate the local mean time of rising or setting.
//  By 'local' is meant the
//  exact time at the location, assuming that there were no time zone. That
//  is, the time difference between the location and the Meridian depended
//  entirely on the longitude. We can't do anything with this time directly;
//  we must convert it to UTC and then to a local time. The result is
//  expressed as a fractional number of hours since midnight
//

- (double) localMeanTimeForHour:(double)localHour andAscension:(double)sunRightAscensionHours andApproxTimeDays:(double)approxTimeDays{
    
    double temp = localHour + sunRightAscensionHours - (0.06571 * approxTimeDays)
    - 6.622;
    
    //DLog(@"- (double) localMeanTimeForHour:(double)localHour andAscension:(double)sunRightAscensionHours andApproxTimeDays:(double)approxTimeDays; %.15f", temp);
    
    return temp;
    
}

//
//  s the cosine of the Sun's local hour angle
//

- (double) cosLocalHourAngleForAngle:(double)sunTrueLongitude andLatitude:(double)latitude andZenith:(double)zenith{
    
    //DLog(@"\n\n\n Long: %.15f \n\n Lat: %.15f \n\n Zen: %.15f\n\n\n", sunTrueLongitude, latitude, zenith);
    double sinDec = 0.39782 * (sinDeg(sunTrueLongitude));
    double cosDec = cosDeg((asinDeg(sinDec)));
    
    double cosH = ((cosDeg(zenith)) - (sinDec * (sinDeg(latitude)))) / (cosDec * (cosDeg(latitude)));
    
    //DLog(@"- (double) cosLocalHourAngleForAngle:(double)sunTrueLongitude andLatitude:(double)latitude andZenith:(double)zenith; %.15f" ,cosH);
    
    return cosH;
    
}

//
//  Calculates the Sun's right ascension in hours, given the Sun's true
//  longitude in degrees. Input and output are angles greater than 0 and
//  less than 360.
//

- (double) sunRightAscensionHoursForLongitude:(double)sunTrueLongitude{
    
    double a = 0.91764 * tanDeg(sunTrueLongitude);
    double ra = 360.0 / (2.0 * kMyPI) * atan(a);
    
    // get result into 0-360 degree range
    // if (ra >= 360.0) ra = ra - 360.0;
    // if (ra < 0) ra = ra + 360.0;
    
    double lQuadrant = floor(sunTrueLongitude / 90.0) * 90.0;
    double raQuadrant = floor(ra / 90.0) * 90.0;
    ra = ra + (lQuadrant - raQuadrant);
    
    
    
    //DLog(@"- (double) sunRightAscensionHoursForLongitude:(double)sunTrueLongitude; %.15f", ra/kDegreesPerHour);
    
    return ra / kDegreesPerHour; // convert to hours
}

//
//  Calculates the Sun's true longitude in degrees. The result is an angle
//  greater than 0 and less than 360. Requires the Sun's mean anomaly, also
//  in degrees.
//

- (double) sunTrueLongitudeFromAnomaly:(double)sunMeanAnomaly{
    
    double l = sunMeanAnomaly + (1.916 * sinDeg(sunMeanAnomaly))
    + (0.020 * sinDeg(2 * sunMeanAnomaly)) + 282.634;
    
    // get longitude into 0-360 degree range
    if (l >= 360.0) {
        l = l - 360.0;
    }
    if (l < 0) {
        l = l + 360.0;
    }
    
    //DLog(@"- (double) sunTrueLongitudeFromAnomaly:(double)sunMeanAnomaly{ Anomaly: %.15f", l);
    return l;
}

//
// Calculate the Sun's mean anomaly in degrees, at sunrise or sunset, given
// the longitude in degrees.
//


- (double) meanAnomalyForDayOfYear:(int)dayOfYear atLongitude:(double)longitude forCalculationType:(int)type{
    
    double temp = (0.9856 * [self approxTimeDaysForDayOfYear:dayOfYear withHoursFromMeridian:[self hoursFromMeridianForLongitude:longitude] forCalculationType:type]) - 3.289;
    
    //DLog(@"- (double)getMeanAnamolyForDayOfYear:(int)dayOfYear atLongitude:(double)longitude forCalculationType:(int)type %.15f", temp);
    
    return temp;
}

//
// s the approximate time of sunset or sunrise In DAYS since midnight
// Jan 1st, assuming 6am and 6pm events. We need this figure to derive the
// Sun's mean anomaly.
//

- (double) approxTimeDaysForDayOfYear:(int)dayOfYear withHoursFromMeridian:(double)hoursFromMeridian forCalculationType:(int)type{
    
    if (type == kTypeSunrise) {
        return dayOfYear + ((6.0 - hoursFromMeridian) / 24);
    } else /* if (type == TYPE_SUNSET) */{
        return dayOfYear + ((18.0 - hoursFromMeridian) / 24);
    }
    
}

//
//  Get time difference between location's longitude and the Meridian, in
//  hours. West of Meridian has a negative time offset.
//

- (double) hoursFromMeridianForLongitude:(double)longitude{    
    return longitude/kDegreesPerHour;
}

//
// Calculate the day of the year, where Jan 1st is day 1. Note that this
// method needs to know the year, because leap years have an impact here
//


//
// Calculate the day of the year, where Jan 1st is day 1. Note that this
// method needs to know the year, because leap years have an impact here
//

- (int) dayOfYearForYear:(int)year andMonth:(int)month andDay:(int)day{
    int n1 = 275 * month / 9;
    int n2 = (month + 9) / 12;
    int n3 = (1 + ((year - 4 * (year / 4) + 2) / 3));
    int n = n1 - (n2 * n3) + day - 30;
    
    //DLog(@"- (int)getDayOfYearForYear:(int)year andMonth:(int)month andDay:(int)day;  %i", n);
    return n;
}

//
//
//

- (double) UTCSunsetForDate:(NSDate*)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation{
    
    double doubleTime = NAN;
    
    if (adjustForElevation) {
        zenith = [self adjustZenith:zenith forElevation:self.geoLocation.altitude];
    }else{
        zenith = [self adjustZenith:zenith forElevation:0];
    }
    
    int year = [[[self yearMonthAndDayFromDate:date] objectAtIndex:0]intValue];
    
    int month = [[[self yearMonthAndDayFromDate:date] objectAtIndex:1]intValue];
    
    int day = [[[self yearMonthAndDayFromDate:date] objectAtIndex:2]intValue];
    
    doubleTime = [self sunriseOrSunsetForYear:year andMonth:month andDay:day atLongitude:self.geoLocation.longitude andLatitude:self.geoLocation.latitude withZenith:zenith andType:kTypeSunset];
    
    return doubleTime;
}

//
//
//

- (double) UTCSunriseForDate:(NSDate*)date andZenith:(double)zenith adjustForElevation:(BOOL)adjustForElevation{
    
    double doubleTime = NAN;
    
    if (adjustForElevation) {
        zenith = [self adjustZenith:zenith forElevation:self.geoLocation.altitude];
    }else{
        zenith = [self adjustZenith:zenith forElevation:0];
    }
    
    int year = [[[self yearMonthAndDayFromDate:date] objectAtIndex:0]intValue];
    
    int month = [[[self yearMonthAndDayFromDate:date] objectAtIndex:1]intValue];
    
    int day = [[[self yearMonthAndDayFromDate:date] objectAtIndex:2]intValue];
    
    
    doubleTime = [self sunriseOrSunsetForYear:year andMonth:month andDay:day atLongitude:self.geoLocation.longitude andLatitude:self.geoLocation.latitude withZenith:zenith andType:kTypeSunrise];
    
    return doubleTime;
}

#pragma mark - Methods from Astronomical Calculator

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

- (double) elevationAdjustmentForElevation:(double)elevation{
    
    double earthRadius = kEarthRadius;
    
    //double elevationAdjustment = 0.0347 * sqrt(elevation);
    double elevationAdjustment = toDegrees(acos(earthRadius/(earthRadius + (elevation / 1000))));
    
    ////DLog(@"Elevation Adjustment: %.15f", elevationAdjustment);
    
    return elevationAdjustment;    
}

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

- (double) adjustZenith:(double) zenith forElevation:(double)elevation{
    if (zenith == kZenithGeometric) {
        zenith = zenith
        + (kSolarRadius + kRefraction + [self elevationAdjustmentForElevation:elevation]);
    }
    
    return zenith;
}

#pragma mark - Method to get day, month and year

//
//  Break up a date object into day, month, year
//

- (NSArray *) yearMonthAndDayFromDate:(NSDate *)date{
    
    //
    //  Create a calendar
    //
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    //
    //  Set up the date components
    //
    
    NSDateComponents *parts = [gregorianCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    
    //
    //  Store the values in NSNumbers
    //
    
    NSNumber *year = [NSNumber numberWithInt:(int)[parts year]];
    NSNumber *month = [NSNumber numberWithInt:(int)[parts month]];    
    NSNumber *day = [NSNumber numberWithInt:(int)[parts day]];
    
    //
    //  Create an array to hold the day, month and year
    //
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithObjects:year, month, day, nil];
    
    //
    //  Release the calendar
    //
    
    
    //
    //  Return the array
    //
    
    return tempArray;
    
}


@end
