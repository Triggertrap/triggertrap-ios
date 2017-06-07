//
//  TPPreciseTimer.h
//  Loopy
//
//  Created by Michael Tyson on 06/09/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

// This class is based on the example found here
// http://atastypixel.com/blog/experiments-with-precise-timing-in-ios/

#import <Foundation/Foundation.h>

@interface PreciseTimer : NSObject {
    double _timebase_ratio;
    
    NSMutableArray *_events;
    NSCondition *_condition;
    pthread_t _thread;
}

+ (void)scheduleAction:(SEL)action target:(id)target inTimeInterval:(NSTimeInterval)timeInterval;
+ (void)scheduleAction:(SEL)action target:(id)target context:(id)context inTimeInterval:(NSTimeInterval)timeInterval;
+ (void)cancelAction:(SEL)action target:(id)target;
+ (void)cancelAction:(SEL)action target:(id)target context:(id)context;

#if NS_BLOCKS_AVAILABLE
+ (void)scheduleBlock:(void (^)(void))block inTimeInterval:(NSTimeInterval)timeInterval;
#endif

+ (void)removeAllScheduledEvents;

@end