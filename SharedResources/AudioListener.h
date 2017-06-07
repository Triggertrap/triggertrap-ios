//
//  AudioListener.h
//  Yell Camera
//
//  Created by Ross Gibson on 28/06/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

extern float const kAudioListenerSensitivityLow;
extern float const kAudioListenerSensitivityMedium;
extern float const kAudioListenerSensitivityHigh;

extern float const kAudioListenerFrequencyLow;
extern float const kAudioListenerFrequencyMedium;
extern float const kAudioListenerFrequencyHigh;

@class AudioListener;

/**
 *  AudioListenerDelegate
 */
@protocol AudioListenerDelegate <NSObject>

@required

- (void)audioLevelsUpdated:(AudioListener *)listner
             averageLevel:(float)averageLevel
                 peakLevel:(float)peakLevel;

@end

@interface AudioListener : NSObject

@property (nonatomic, weak) id <AudioListenerDelegate> delegate; 

- (void)startSession;
- (BOOL)recordPermissionGranted;
- (void)endSession;

@end
