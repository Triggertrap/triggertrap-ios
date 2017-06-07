//
//  CLLocation+GPS.h
//  Triggertrap
//
//  Created by Ross Gibson on 11/04/2013.
//
//

#import <CoreLocation/CoreLocation.h>

typedef enum {
    kCLGPSSignalStrengthPoor  = 0,
    kCLGPSSignalStrengthFair,
    kCLGPSSignalStrengthExcellent
} kCLGPSSignalStrength;

@interface CLLocation (GPS)

- (NSInteger)GPSSignalStrength;

@end
