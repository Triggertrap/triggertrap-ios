//
//  TTPulseGenerator.h
//  TTLibrary
//
//  Created by Ross Gibson on 13/02/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "A440SineWaveGenerator.h"

#define kPlayForever UINT64_MAX
#define kInfinitePulseLength [NSNumber numberWithUnsignedLongLong:kPlayForever]

typedef enum {
    kLowLatency,
    kHighLatency
} LatencyMode;

@protocol AudioPlayerDelegate <NSObject>
@optional
- (void)audioPlayerlDidFinishPlayingAudio;
@end

@interface AudioPlayer : NSObject {
    AUGraph _graph;
    AUNode _outputNode;
    AUNode _converterNode;
    AudioStreamBasicDescription _dataFormat;
    
    A440SineWaveGenerator _sineWaveGenerator;
    
    int _sample;
    double _frequency;
    
    int16_t _samples[4410];
    uint64_t _limit[2];
    uint64_t _pause[2];

    BOOL _playing;
}

@property (assign, nonatomic) id<AudioPlayerDelegate> delegate;

+ (AudioPlayer *)sharedInstance;

// Starts the audio player. This will continue to
// play 'empty' sound until the buffer is filled.
- (BOOL)start;

// Stops the audio player from playing sound,
// wether it's 'empty' sound or not.
- (void)stop;

// Fills the buffer with sound for the given duration.
- (void)playAudioForDuration:(uint64_t)milliseconds;

// Stops the audio and continues to play 'empty sound.
- (void)stopAudio;

- (void)setFrequency:(double)freq;

- (void)setLatencyMode:(LatencyMode)mode;

- (BOOL)hasBuiltInMic;

@end
