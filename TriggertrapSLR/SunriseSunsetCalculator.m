//
//  SunriseSunsetCalculator.m
//  Triggertrap
//
//  Created by Valentin Kalchev on 10/05/2014.
//
//

#import "SunriseSunsetCalculator.h"
#import "AstronomicalCalculator.h"
#import "AstronomicalCalendar.h"

@implementation SunriseSunsetCalculator
{
    float latitude;
    float longitude;
    
    NSDate *nextSunriseDate;
    NSDate *nextSunsetDate;
    
    NSTimer *nextSunriseTimer;
    NSTimer *nextSunsetTimer;
    
    NSString *timeUntilNextSunrise;
    NSString *timeUntilNextSunset;
}

- (void)setCoordinates:(CLLocationCoordinate2D)coordinate {
    latitude = coordinate.latitude;
    longitude = coordinate.longitude;
}

- (NSDate *)astronomicalDateFor:(NSDate *)date withType:(int)type {
    
    GeoLocation *aGeoLocation = [[GeoLocation alloc] initWithName:@"Location"
                                                      andLatitude:latitude
                                                     andLongitude:longitude
                                                      andTimeZone:[NSTimeZone systemTimeZone]];
    
    AstronomicalCalendar *astronomicalCalendar = [[AstronomicalCalendar alloc] initWithLocation:aGeoLocation];
    
    //I found that by updating the workingDate of the astronomical calendar, user can pass other dates (as supposed to current date)
    astronomicalCalendar.workingDate = date;
    
    switch (type) {
            
        //First light
        case AstronomicalTypeFirstLight:
            return [astronomicalCalendar beginCivilTwilight];
            break;
            
        //Sunrise
        case AstronomicalTypeSunrise:
            return [astronomicalCalendar sunrise];
            break;
            
        //Sunset
        case AstronomicalTypeSunset:
            return [astronomicalCalendar sunset];
            break;
            
        //Last light
        case AstronomicalTypeLastLight:
            return [astronomicalCalendar endCivilTwilight];
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSDate *)nextAstronomicalDateFor:(int)type {
    NSDate *nextAstronomicalDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:( NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    
    //Increment todays day with 1
    [components setDay:[components day] + 1];
    
    if ([self hasAstronomicalDatePassedWithType:type]) {
        return nextAstronomicalDate = [self astronomicalDateFor:[calendar dateFromComponents:components] withType:type];
    } else {
        return nextAstronomicalDate = [self astronomicalDateFor:[NSDate date] withType:type];
    }
}

- (BOOL)hasAstronomicalDatePassedWithType:(int)type {
    //Get current date with hours/minutes/seconds
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    NSInteger seconds = [components second];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    //Get today's sunrise(0) or sunset(1) hours/minutes/seconds
    NSDate *todayAstronomicalDate = [self astronomicalDateFor:[NSDate date] withType:type];
    
    NSDateComponents *astronomicalDateComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:todayAstronomicalDate];
    NSInteger astronomicalDateSecond = [astronomicalDateComponents second];
    NSInteger astronomicalDateMinute = [astronomicalDateComponents minute];
    NSInteger astronomicalDateHour = [astronomicalDateComponents hour];
    
    //Compare today's sunrise hours/minutes/seconds with current date hours/minutes/seconds and determine whether today's sunrise has passed
    if (hour >= astronomicalDateHour) {
        if (hour == astronomicalDateHour) {
            if (minute >= astronomicalDateMinute) {
                if (minute == astronomicalDateMinute) {
                    if (seconds > astronomicalDateSecond) {
                        return YES;
                    } else {
                        return NO;
                    }
                } else {
                    return YES;
                }
            } else {
                return NO;
            }
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

@end
