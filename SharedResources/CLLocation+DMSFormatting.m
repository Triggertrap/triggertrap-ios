//
//  CLLocation+DMSFormatting.m
//  TriggerTrap
//
//  Created by Matt Kane on 26/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CLLocation+DMSFormatting.h"

@interface CLLocation(Internal)

- (NSString *)formatLatLon:(CLLocationDegrees)coord;

@end

@implementation CLLocation (DMSFormatting)

- (NSString *)toDegreeMinuteSecondString {
    CLLocationDegrees lat = self.coordinate.latitude;
    CLLocationDegrees lon = self.coordinate.longitude;
    
    NSString *latLabel = NSLocalizedString(@"N", @"N");
    NSString *lonLabel = NSLocalizedString(@"E", @"E");

    if (lat < 0.0) {
        lat = -lat;
        latLabel = NSLocalizedString(@"S", @"S");
    }
    
    if (lon < 0.0) {
        lon = -lon;
        lonLabel = NSLocalizedString(@"W", @"W");

    }
    
    return [NSString stringWithFormat:@"%@ %@, %@ %@", [self formatLatLon:lat], latLabel, [self formatLatLon:lon], lonLabel];
}

- (NSString *)formatLatLon:(CLLocationDegrees)coord {
    double degrees = floor(coord);
    double mins = (coord - degrees) * 60.0;
    double secs = (mins - floor(mins)) * 60.0;
    return [NSString localizedStringWithFormat:@"%.0f° %.0f′ %.2f″", degrees, mins, secs];
}

@end
