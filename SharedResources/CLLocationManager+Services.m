//
//  CLLocationManager+Services.m
//  Triggertrap
//
//  Created by Ross Gibson on 10/04/2013.
//
//

#import "CLLocationManager+Services.h"

@implementation CLLocationManager (Services)

- (BOOL)locationServicesAreEnabled {
    // check if Location Services are turned off globally or if they are ON but disabled for the Triggertrap app
    if (![CLLocationManager locationServicesEnabled] || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)hasHeading {
    // this method returns YES if the device has compass support, even if location services are OFF
    if ([CLLocationManager headingAvailable] == NO) {
        return NO;
    } else {
        return YES;
    }
}

@end
