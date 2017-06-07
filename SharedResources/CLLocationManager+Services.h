//
//  CLLocationManager+Services.h
//  Triggertrap
//
//  Created by Ross Gibson on 10/04/2013.
//
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocationManager (Services)

- (BOOL)locationServicesAreEnabled;
- (BOOL)hasHeading;

@end
