//
//  SettingsManager.h
//  TTGlobalSettings
//
//  Created by Valentin Kalchev on 15/08/2014.
//  Copyright (c) 2014 Triggertrap. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kUserDefaultsCacheSensorDelayKey;
extern NSString *const kUserDefaultsCacheSensorResetDelayKey;
extern NSString *const kUserDefaultsCachePulseLengthKey;
extern NSString *const kUserDefaultsCacheSpeedUnitKey;
extern NSString *const kUserDefaultsCacheDistanceUnitKey;

// TODO: Temp removed - Screen flashing / screen dimming
//extern NSString *const kUserDefaultsCacheScreenFlashingKey;
//extern NSString *const kUserDefaultsCacheScreenDimmingKey;

extern int const kMinimumGap;

@interface SettingsManager : NSObject

+ (SettingsManager *)sharedInstance;

/*!
 * Use to set / get sensor delay
 */
@property (nonatomic, strong) NSNumber *sensorDelay;

/*!
 * Use to set / get sensor reset delay
 */
@property (nonatomic, strong) NSNumber *sensorResetDelay;

/*!
 * Use to set / get pulse length
 */
@property (nonatomic, strong) NSNumber *pulseLength;

/*!
 * Use to set / get speed unit
 */
@property (nonatomic, strong) NSNumber *speedUnit;

/*!
 * Use to set / get distance unit
 */
@property (nonatomic, strong) NSNumber *distanceUnit;

// TODO: Temp removed - Screen flashing / screen dimming
///*!
// * Use to set / get screen flashing
// */
//@property (nonatomic, assign) BOOL screenFlashing;
//
///*!
// * Use to set / get screen dimming
// */
//@property (nonatomic, assign) BOOL screenDimming;

/*!
 * Use to check whether values are equal to User Defaults and update them if needed
 */
- (void)updateSettingsValues;

/*!
 * Use to reset settings to default
 */
- (void)resetSettings;

@end
