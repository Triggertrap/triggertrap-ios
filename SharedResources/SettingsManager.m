//
//  SettingsManager.m
//  TTGlobalSettings
//
//  Created by Valentin Kalchev on 15/08/2014.
//  Copyright (c) 2014 Triggertrap. All rights reserved.
//

#import "SettingsManager.h"

NSString *const kUserDefaultsCacheSensorDelayKey = @"delay_before_trigger";
NSString *const kUserDefaultsCacheSensorResetDelayKey = @"reset_delay";
NSString *const kUserDefaultsCachePulseLengthKey = @"flashAdapter";
NSString *const kUserDefaultsCacheSpeedUnitKey = @"speed_unit";
NSString *const kUserDefaultsCacheDistanceUnitKey = @"distance_units";

// TODO: Temp removed - Screen flashing / screen dimming
//NSString *const kUserDefaultsCacheScreenFlashingKey = @"screenFlashEnabled";
//NSString *const kUserDefaultsCacheScreenDimmingKey = @"screenDimming";

int const kMinimumGap = 150;

#define kDefaultSensorDelayValue @0
#define kDefaultSensorResetDelayValue @1000
#define kDefaultPulseLengthValue @150
#define kDefaultSpeedUnitValue @1 //@"Miles per hour"
#define kDefaultDistanceUnitValue @0 //@"Meters / Kilometers"

// TODO: Temp removed - Screen flashing / screen dimming
//#define kDefaultScreenFlashingValue YES
//#define kDefaultScreenDimmingValue YES

@implementation SettingsManager

static SettingsManager *sharedInstance = nil;

+ (SettingsManager *)sharedInstance {

    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    
    return sharedInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return  [self sharedInstance];
}

#pragma mark - Setters

- (void)setSensorDelay:(NSNumber *)sensorDelay {
    [[NSUserDefaults standardUserDefaults] setObject:sensorDelay forKey:kUserDefaultsCacheSensorDelayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSensorResetDelay:(NSNumber *)sensorResetDelay {
    [[NSUserDefaults standardUserDefaults] setObject:sensorResetDelay forKey:kUserDefaultsCacheSensorResetDelayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPulseLength:(NSNumber *)pulseLength {
    [[NSUserDefaults standardUserDefaults] setObject:pulseLength forKey:kUserDefaultsCachePulseLengthKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSpeedUnit:(NSNumber *)speedUnit {
    [[NSUserDefaults standardUserDefaults] setObject:speedUnit forKey:kUserDefaultsCacheSpeedUnitKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDistanceUnit:(NSNumber *)distanceUnit {
    [[NSUserDefaults standardUserDefaults] setObject:distanceUnit forKey:kUserDefaultsCacheDistanceUnitKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// TODO: Temp removed - Screen flashing / screen dimming
//- (void)setScreenFlashing:(BOOL)enabled {
//    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kUserDefaultsCacheScreenFlashingKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (void)setScreenDimming:(BOOL)enabled {
//    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kUserDefaultsCacheScreenDimmingKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

#pragma mark - Getters

- (NSNumber *)sensorDelay {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheSensorDelayKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheSensorDelayKey];
    } else {
        [self setSensorDelay:kDefaultSensorDelayValue];
        return self.sensorDelay;
    }
}

- (NSNumber *)sensorResetDelay {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheSensorResetDelayKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheSensorResetDelayKey];
    } else {
        [self setSensorResetDelay:kDefaultSensorResetDelayValue];
        return self.sensorResetDelay;
    }
}

- (NSNumber *)pulseLength {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCachePulseLengthKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCachePulseLengthKey];
    } else {
        [self setPulseLength:kDefaultPulseLengthValue];
        return self.pulseLength;
    }
}

- (NSNumber *)speedUnit {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheSpeedUnitKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheSpeedUnitKey];
    } else {
        [self setSpeedUnit:kDefaultSpeedUnitValue];
        return self.speedUnit;
    }
}

- (NSNumber *)distanceUnit {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheDistanceUnitKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheDistanceUnitKey];
    } else {
        [self setDistanceUnit:kDefaultDistanceUnitValue];
        return self.distanceUnit;
    }
}

// TODO: Temp removed - Screen flashing / screen dimming
//- (BOOL)screenFlashing {
//    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheScreenFlashingKey]) {
//        return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsCacheScreenFlashingKey];
//    } else {
//        [self setScreenFlashing:kDefaultScreenFlashingValue];
//        return self.screenFlashing;
//    }
//}
//
//- (BOOL)screenDimming {
//    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCacheScreenDimmingKey]) {
//        return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsCacheScreenDimmingKey];
//    } else {
//        [self setScreenDimming:kDefaultScreenDimmingValue];
//        return self.screenDimming;
//    }
//}

- (void)updateSettingsValues {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([self sensorDelay] != [defaults objectForKey:kUserDefaultsCacheSensorDelayKey]) {
        [self setSensorDelay:[defaults objectForKey:kUserDefaultsCacheSensorDelayKey]];
    }
    
    if ([self sensorResetDelay] != [defaults objectForKey:kUserDefaultsCacheSensorResetDelayKey]) {
        [self setSensorResetDelay:[defaults objectForKey:kUserDefaultsCacheSensorResetDelayKey]];
    }
    
    if ([self pulseLength] != [defaults objectForKey:kUserDefaultsCachePulseLengthKey]) {
        [self setPulseLength:[defaults objectForKey:kUserDefaultsCachePulseLengthKey]];
    }
    
    if ([self speedUnit] != [defaults objectForKey:kUserDefaultsCacheSpeedUnitKey]) {
        [self setSpeedUnit:[defaults objectForKey:kUserDefaultsCacheSpeedUnitKey]];
    }
    
    if ([self distanceUnit] != [defaults objectForKey:kUserDefaultsCacheDistanceUnitKey]) {
        [self setDistanceUnit:[defaults objectForKey:kUserDefaultsCacheDistanceUnitKey]];
    }
    
    // TODO: Temp removed - Screen flashing / screen dimming
//    if ([self screenFlashing] != [[defaults objectForKey:kUserDefaultsCacheScreenFlashingKey] boolValue]) {
//        [self setScreenFlashing:[[defaults objectForKey:kUserDefaultsCacheScreenFlashingKey] boolValue]];
//    }
//    
//    if ([self screenDimming] != [[defaults objectForKey:kUserDefaultsCacheScreenDimmingKey] boolValue]) {
//        [self setScreenDimming:[[defaults objectForKey:kUserDefaultsCacheScreenDimmingKey] boolValue]];
//    }
}

- (void)resetSettings {
    
    self.sensorDelay = nil;
    self.sensorResetDelay = nil;
    self.pulseLength = nil;
    self.speedUnit = nil;
    self.distanceUnit = nil;
    
    // TODO: Temp removed - Screen flashing / screen dimming
//    self.screenFlashing = YES;
//    self.screenDimming = YES;
}

@end
