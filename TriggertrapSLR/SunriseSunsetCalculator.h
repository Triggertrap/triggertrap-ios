//
//  SunriseSunsetCalculator.h
//  Triggertrap
//
//  Created by Valentin Kalchev on 10/05/2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(int, AstronomicalType){
    AstronomicalTypeFirstLight,
    AstronomicalTypeSunrise,
    AstronomicalTypeSunset,
    AstronomicalTypeLastLight
};

@interface SunriseSunsetCalculator : NSObject

- (void)setCoordinates:(CLLocationCoordinate2D)coordinate;

- (NSDate *)astronomicalDateFor:(NSDate *)date withType:(int)type;

- (NSDate *)nextAstronomicalDateFor:(int)type;

- (BOOL)hasAstronomicalDatePassedWithType:(int)type;

@end
