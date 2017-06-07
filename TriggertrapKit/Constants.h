//
//  Constants.h 
//
//  Created by Ross Gibson on 17/02/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - Notifications

extern NSString * const kDongleDidTriggerNotification;
extern NSString * const kRemoteOuptputServerDidTriggerNotification;
extern NSString * const kRemoteOutputServerStatusChangedNotification;

#pragma mark - UserDefaults

extern NSString * const kLastConnectMasterServer;

@end
