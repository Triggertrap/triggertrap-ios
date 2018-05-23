//
//  TTPulseGenerator.m
//  TTLibrary
//
//  Created by Ross Gibson on 13/02/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

// https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/AudioUnitHostingGuide_iOS/ConstructingAudioUnitApps/ConstructingAudioUnitApps.html

#define LOW_LATENCY 0.001
#define HIGH_LATENCY 0.023220

#define kFrequency 19000.0

#define FAIL_ON_ERR(_X_) if ((status = (_X_)) != noErr) { goto failed; }

// The left channel is the shutter and the right is focus
typedef enum {
    kChannelLeft,
    kChannelRight,
    kChannelBoth
} AudioChannel;

@interface AudioPlayer () {
    
}

@end

static OSStatus MyRenderer(void *                           inRefCon,
                           AudioUnitRenderActionFlags *     ioActionFlags,
                           const AudioTimeStamp *           inTimeStamp,
                           UInt32                           inBusNumber,
                           UInt32                           inNumberFrames,
                           AudioBufferList *                ioData);

static void FillFrame(AudioPlayer *self, int16_t *sample);

@implementation AudioPlayer

static AudioPlayer * sharedInstance = nil;

#pragma mark - Lifecycle

+ (AudioPlayer *)sharedInstance {
    
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[super allocWithZone:nil] init];
        [sharedInstance setupAudioSession];
        [sharedInstance setup];
    });
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (void)setupAudioSession {
    // Chaged to using this C version, as apparently there is a bug is Apples code
    // http://stackoverflow.com/questions/15330777/avaudiosession-audio-session-services-switching-output-solved
    // Apparently the order of setting properties matters, although there is no mention of this in the docs.
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    [sharedInstance setLatencyMode:kHighLatency];
    
    //AVAudioSessionCategoryPlayback - For playing recorded music or other sounds that are central to the successful use of your app.
    //AVAudioSessionCategoryOptionDefaultToSpeaker - Routes audio from the session to the built-in speaker by default.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    
}

- (void)setup {
    _limit[kChannelLeft] = 0;
    _limit[kChannelRight] = 0;
    
    if (_graph) {
        AUGraphUninitialize(_graph);
        AUGraphClose(_graph);
        DisposeAUGraph(_graph);
    }
    
    NewAUGraph(&_graph);
    [sharedInstance addOutputNode];
    [sharedInstance addConverterNode];
    AUGraphConnectNodeInput(_graph, _converterNode, 0,
                            _outputNode, 0);
    AUGraphOpen(_graph);
    [sharedInstance setupDataFormat];
    [sharedInstance setDataFormatOfConverterAudioUnit];
    [sharedInstance setMaximumFramesPerSlice];
    [sharedInstance setRenderCallbackOfConverterNode];
    _frequency = kFrequency;
    
    A440SineWaveGeneratorInitWithFrequency(&_sineWaveGenerator, _frequency);
    
    for (int32_t i = 0; i < 4410; i++) {
        _samples[i] = A440SineWaveGeneratorNextSample(&_sineWaveGenerator);
    }
    
    AUGraphInitialize(_graph);
}

- (void)dealloc {
    AUGraphUninitialize(_graph);
    AUGraphClose(_graph);
    DisposeAUGraph(_graph);
    _graph = NULL;
}

#pragma mark - Public

- (BOOL)start {
    Boolean running;
    AUGraphIsRunning(_graph, &running);
    
    if (running) {
        return YES;
    }
    
    //NSLog(@"Audio Player: Starting Audio Player");
    OSStatus status;
    
    FAIL_ON_ERR(AUGraphStart(_graph));
    
    return YES;
    
failed:
    // Error handling...
    if (_graph != NULL) {
        DisposeAUGraph(_graph);
    }
    
    return NO;
}

- (void)stop {
    //NSLog(@"Audio Player: Stopping Audio Player");
    
    [sharedInstance stopAudio];
    AUGraphStop(_graph);
}

- (void)playAudioForDuration:(uint64_t)milliseconds {
    // We have a 44Khz sample rate, so we have 44 samples per millisecond.
    uint64_t cycles = milliseconds * 44;
    //NSLog(@"PlayAudioForDuration Cycles : %llu", cycles);
    
    // We delay the left channel (shutter) to support Samsung NX cameras
    _pause[kChannelLeft] = 20;
    
    _limit[kChannelLeft] = cycles - 20;
    //NSLog(@"PlayAudioForDuration kChannelLeft : %llu", _limit[kChannelLeft]);
    
    _limit[kChannelRight] = cycles;
    //NSLog(@"PlayAudioForDuration kChannelRight : %llu", _limit[kChannelRight]);
    
    //NSLog(@"Audio Player: Playing audio for %llums at %.0fHz", milliseconds, _frequency);
}

- (void)stopAudio {
    _limit[kChannelLeft] = 0;
    _limit[kChannelRight] = 0;
    
    [sharedInstance audioDidFinishForChannel:kChannelBoth];
}

- (void)setFrequency:(double)freq {
    
    _frequency = freq;
    _sample = 0;
    A440SineWaveGeneratorInitWithFrequency(&_sineWaveGenerator, _frequency);
}

- (void)setLatencyMode:(LatencyMode)mode {
    
    if (mode == kLowLatency) {
        [sharedInstance setPreferredBufferDuration:LOW_LATENCY];
    } else if (mode == kHighLatency) {
        [sharedInstance setPreferredBufferDuration:HIGH_LATENCY];
    }
}

- (BOOL)hasBuiltInMic {
#if TARGET_IPHONE_SIMULATOR
    return TRUE;
#else
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInMicrophone]
                                                                                                                            mediaType:AVMediaTypeAudio
                                                                                                                             position:AVCaptureDevicePositionUnspecified];
    NSUInteger count = [[captureDeviceDiscoverySession devices] count];
    return count > 0;
#endif
}

#pragma mark - Private

- (void)audioDidFinishForChannel:(AudioChannel)channel {
    //NSLog(@"Audio Player: Finished playing audio");
    
    if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(audioPlayerlDidFinishPlayingAudio)]) {
        [sharedInstance.delegate audioPlayerlDidFinishPlayingAudio];
    }
}

- (uint64_t)timeRemainingOnChannel:(AudioChannel)channel {
    
    if (channel == kChannelBoth) {
        return 0;
    }
    
    return _limit[channel];
}

- (BOOL)play:(NSError **)error {
    return YES;
}

- (BOOL)stop:(NSError **)error {
    return YES;
}

- (OSStatus)addOutputNode {
    AudioComponentDescription description = {
        .componentType = kAudioUnitType_Output,
#if TARGET_OS_IPHONE
        .componentSubType = kAudioUnitSubType_RemoteIO,
#else
        .componentSubType = kAudioUnitSubType_DefaultOutput,
#endif
        .componentManufacturer = kAudioUnitManufacturer_Apple,
    };
    
    return AUGraphAddNode(_graph, &description, &_outputNode);
}

- (OSStatus)addConverterNode {
    AudioComponentDescription description = {
        .componentType = kAudioUnitType_FormatConverter,
        .componentSubType = kAudioUnitSubType_AUConverter,
        .componentManufacturer = kAudioUnitManufacturer_Apple,
    };
    
    return AUGraphAddNode(_graph, &description, &_converterNode);
}

- (void)setupDataFormat {
    // 16-bit native endian signed integer, stereo LPCM
    UInt32 formatFlags = (0
                          | kAudioFormatFlagIsPacked
                          | kAudioFormatFlagIsSignedInteger
                          | kAudioFormatFlagsNativeEndian
                          );
    
    _dataFormat = (AudioStreamBasicDescription) {
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = formatFlags,
        .mSampleRate = SAMPLE_RATE,
        .mBitsPerChannel = 16,
        .mChannelsPerFrame = 2,
        .mBytesPerFrame = 4,
        .mFramesPerPacket = 1,
        .mBytesPerPacket = 4,
    };
}

- (OSStatus)setDataFormatOfConverterAudioUnit {
    AudioUnit converterAudioUnit;
    OSStatus status;
    status = AUGraphNodeInfo(_graph, _converterNode,
                             NULL, &converterAudioUnit);
    
    if (status != noErr) {
        return status;
    }
    
    AudioUnitSetProperty(converterAudioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &_dataFormat,
                         sizeof(_dataFormat)
                         );
    
    return status;
}

- (OSStatus)setMaximumFramesPerSlice {
#if TARGET_OS_IPHONE
    /*
     * See Technical Q&A QA1606 Audio Unit Processing Graph -
     *   Ensuring audio playback continues when screen is locked
     *
     * http://developer.apple.com/iphone/library/qa/qa2009/qa1606.html
     *
     * Need to set kAudioUnitProperty_MaximumFramesPerSlice to 4096 on all
     * non-output audio units.  In this case, that's only the converter unit.
     */
    
    AudioUnit converterAudioUnit;
    OSStatus status;
    status = AUGraphNodeInfo(_graph, _converterNode,
                             NULL, &converterAudioUnit);
    
    if (status != noErr) {
        return status;
    }
    
    // Set the mixer unit to handle 4096 samples per slice since we want to keep rendering during screen lock.
    UInt32 maxFPS = 4096;
    AudioUnitSetProperty(converterAudioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0,
                         &maxFPS, sizeof(maxFPS));
    return status;
    
#else
    // Don't bother on the desktop.
    return noErr;
#endif
}

- (OSStatus)setRenderCallbackOfConverterNode {
    AURenderCallbackStruct callback = {
        .inputProc = MyRenderer,
        .inputProcRefCon = (__bridge void *)self,
    };
    
    return AUGraphSetNodeInputCallback(_graph, _converterNode,
                                       0, &callback);
}

static OSStatus MyRenderer(
                           void * inRefCon,
                           AudioUnitRenderActionFlags * ioActionFlags,
                           const AudioTimeStamp * inTimeStamp,
                           UInt32 inBusNumber,
                           UInt32 inNumberFrames,
                           AudioBufferList *ioData)
{
    AudioPlayer *self = (__bridge AudioPlayer *)inRefCon;
    
    int16_t *sample = ioData->mBuffers[0].mData;
    UInt32 channelsPerFrame = self->_dataFormat.mChannelsPerFrame;
    
    for (UInt32 i = 0; i < inNumberFrames; i++) {
        FillFrame(self, sample);
        sample += channelsPerFrame;
    }
    
    ioData->mBuffers[0].mDataByteSize =
    inNumberFrames *self->_dataFormat.mBytesPerFrame;
    
    return noErr;
}

- (void)setPreferredBufferDuration:(NSTimeInterval)interval {
    NSError *error;
    
    //Sets the preferred audio I/O buffer duration, in seconds.
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:interval error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
}

static void FillFrame(AudioPlayer *self, int16_t *sample) {
    sample[0] = 0;
    sample[1] = 0;
    
    BOOL limitReachedZero = NO;
    
    // Fill the left channel after the pause.
    if (sharedInstance->_limit[kChannelLeft] > 0) {
        
        if (sharedInstance->_pause[kChannelLeft] > 0) {
            sharedInstance->_pause[kChannelLeft]--;
        } else {
            
            if (sharedInstance->_limit[kChannelLeft] != kPlayForever) {
                sharedInstance->_limit[kChannelLeft]--;
                
                if (sharedInstance->_limit[kChannelLeft] == 0) {
                    limitReachedZero = YES;
                }
            }
            
            sample[0] = sharedInstance->_samples[sharedInstance->_sample];
        }
    }
    
    // Fill the right channel.
    if (sharedInstance->_limit[kChannelRight] > 0) {
        
        if (sharedInstance->_limit[kChannelRight] != kPlayForever) {
            sharedInstance->_limit[kChannelRight]--;
            
            if (sharedInstance->_limit[kChannelRight] == 0) {
                limitReachedZero = YES;
            }
        }
        
        sample[1] = sharedInstance->_samples[sharedInstance->_sample];
    }
    
    if (limitReachedZero) {
        [sharedInstance stopAudio];
    }
    
    if (++sharedInstance->_sample >= 4410) {
        sharedInstance->_sample = 0;
    }
}

@end
