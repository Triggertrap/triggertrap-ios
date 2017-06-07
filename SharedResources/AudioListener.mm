//
//  AudioListener.m
//  Yell Camera
//
//  Created by Ross Gibson on 28/06/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import "AudioListener.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#include "MeterTable.h"

#define kMinDBvalue -80.0

float const kAudioListenerSensitivityLow = 0.90f;
float const kAudioListenerSensitivityMedium = 0.70f;
float const kAudioListenerSensitivityHigh = 0.50f;

float const kAudioListenerFrequencyLow = 0.1f;
float const kAudioListenerFrequencyMedium = 0.03f;
float const kAudioListenerFrequencyHigh = 0.02f;

@interface AudioListener () {
    MeterTable *_meterTable;
}

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) dispatch_source_t levelTimer;
 
@property (nonatomic, assign) float lowPassPeak;
@property (nonatomic, assign) float lowPassAverage;

@end

@implementation AudioListener

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        self.lowPassPeak = 0.0f;
        self.lowPassAverage = 0.0f;
        
        _meterTable = new MeterTable(kMinDBvalue);
    }
    return self;
} 

- (void)dealloc {
    delete _meterTable;
}

#pragma mark - Public

- (void)startSession {
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]){
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted){
                [self initializeRecorder];
                [self initializeLevelTimer];
            }
        }];
    }
}

- (BOOL)recordPermissionGranted {
    
    if ([[UIDevice currentDevice] systemVersion].doubleValue >= 8.0) {
        if ([[AVAudioSession sharedInstance] recordPermission] == AVAudioSessionRecordPermissionGranted) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}

- (void)endSession {
    if (self.recorder) {
        [self.recorder stop];
        self.recorder = nil;
    }
    
    if (self.levelTimer) {
        self.levelTimer = nil;
    }
}

#pragma mark - Private

- (void)initializeRecorder {
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (self.recorder) {
        [self.recorder prepareToRecord];
        [self.recorder setMeteringEnabled:YES];
        [self.recorder record];
    }
}

- (void)initializeLevelTimer {
    self.levelTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.levelTimer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_MSEC, 20.0 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(self.levelTimer, ^{ [self levelTimerCallback]; });
    dispatch_resume(self.levelTimer);
}

- (void)levelTimerCallback {
    [self.recorder updateMeters];
    
    float averageLevel = _meterTable->ValueAt([self.recorder averagePowerForChannel:0]);
    float peakLevel = _meterTable->ValueAt([self.recorder peakPowerForChannel:0]);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioLevelsUpdated:averageLevel:peakLevel:)]) {
        [self.delegate audioLevelsUpdated:self averageLevel:averageLevel peakLevel:peakLevel];
    }
}

@end
