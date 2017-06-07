//
//  CLLocation+GPS.m
//  Triggertrap
//
//  Created by Ross Gibson on 11/04/2013.
//
//

#import "CLLocation+GPS.h"

@implementation CLLocation (GPS)

- (NSInteger)GPSSignalStrength {
    if (self.horizontalAccuracy > 140) {
        // Good or excellent GPS signal
        return kCLGPSSignalStrengthExcellent;
    } else if (self.horizontalAccuracy > 0) {
        // Fair GPS signal
        return kCLGPSSignalStrengthFair;
    } else {
        // Poor or no GPS signal, most likely means
        // we are in Airplane mode
        return kCLGPSSignalStrengthPoor;
    }
}

@end
