//
//  TPPreciseTimer.m
//  Loopy
//
//  Created by Michael Tyson on 06/09/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import "PreciseTimer.h"
#import <mach/mach_time.h>
#import <pthread.h>

#define kSpinLockTime 0.01
//#define kAnalyzeTiming // Uncomment to display timing discrepancy reports

static PreciseTimer * __sharedInstance = nil;

static NSString * kTimeKey = @"time";
static NSString * kTargetKey = @"target";
static NSString * kSelectorKey = @"selector";
static NSString * kArgumentKey = @"argument";
#if NS_BLOCKS_AVAILABLE
static NSString * kBlockKey = @"block";
#endif

@interface PreciseTimer ()
- (void)scheduleAction:(SEL)action target:(id)target inTimeInterval:(NSTimeInterval)timeInterval;
- (void)scheduleAction:(SEL)action target:(id)target context:(id)context inTimeInterval:(NSTimeInterval)timeInterval;
- (void)cancelAction:(SEL)action target:(id)target;
- (void)cancelAction:(SEL)action target:(id)target context:(id)context;
#if NS_BLOCKS_AVAILABLE
- (void)scheduleBlock:(void (^)(void))block inTimeInterval:(NSTimeInterval)timeInterval;
#endif
- (void)addSchedule:(NSDictionary *)schedule;
void thread_signal(int signal);
void *thread_entry(void *argument);
- (void)thread;

@end

@implementation PreciseTimer

+ (void)scheduleAction:(SEL)action target:(id)target inTimeInterval:(NSTimeInterval)timeInterval {
    if ( !__sharedInstance ) __sharedInstance = [[PreciseTimer alloc] init];
    [__sharedInstance scheduleAction:action target:target inTimeInterval:timeInterval];
}

+ (void)scheduleAction:(SEL)action target:(id)target context:(id)context inTimeInterval:(NSTimeInterval)timeInterval {
    if ( !__sharedInstance ) __sharedInstance = [[PreciseTimer alloc] init];
    [__sharedInstance scheduleAction:action target:target context:context inTimeInterval:timeInterval];
}

+ (void)cancelAction:(SEL)action target:(id)target {
    if ( !__sharedInstance ) __sharedInstance = [[PreciseTimer alloc] init];
    [__sharedInstance cancelAction:action target:target];
}

+ (void)cancelAction:(SEL)action target:(id)target context:(id)context {
    if ( !__sharedInstance ) __sharedInstance = [[PreciseTimer alloc] init];
    [__sharedInstance cancelAction:action target:target context:context];
}

#if NS_BLOCKS_AVAILABLE
+ (void)scheduleBlock:(void (^)(void))block inTimeInterval:(NSTimeInterval)timeInterval {
    if ( !__sharedInstance ) __sharedInstance = [[PreciseTimer alloc] init];
    [__sharedInstance scheduleBlock:block inTimeInterval:timeInterval];
}

#endif

- (id)init {
    if ( !(self = [super init]) ) return nil;
    
    struct mach_timebase_info timebase;
    mach_timebase_info(&timebase);
    _timebase_ratio = ((double)timebase.numer / (double)timebase.denom) * 1.0e-9;
    
    _events = [[NSMutableArray alloc] init];
    _condition = [[NSCondition alloc] init];
    
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    struct sched_param param;
    param.sched_priority = sched_get_priority_max(SCHED_FIFO);
    pthread_attr_setschedparam(&attr, &param);
    pthread_attr_setschedpolicy(&attr, SCHED_FIFO);
    pthread_create(&_thread, &attr, thread_entry, (__bridge void *)self);
    
    return self;
}

- (void)scheduleAction:(SEL)action target:(id)target inTimeInterval:(NSTimeInterval)timeInterval {
    [self addSchedule:[NSDictionary dictionaryWithObjectsAndKeys:
                       NSStringFromSelector(action), kSelectorKey,
                       target, kTargetKey,
                       [NSNumber numberWithUnsignedLongLong:mach_absolute_time() + (timeInterval / _timebase_ratio)], kTimeKey,
                       nil]];
}

- (void)scheduleAction:(SEL)action target:(id)target context:(id)context inTimeInterval:(NSTimeInterval)timeInterval {
    [self addSchedule:[NSDictionary dictionaryWithObjectsAndKeys:
                       NSStringFromSelector(action), kSelectorKey,
                       target, kTargetKey,
                       [NSNumber numberWithUnsignedLongLong:mach_absolute_time() + (timeInterval / _timebase_ratio)], kTimeKey,
                       context, kArgumentKey,
                       nil]];
}

- (void)cancelAction:(SEL)action target:(id)target {
    [_condition lock];
    NSDictionary *originalNextEvent = [_events count] > 0 ? [_events objectAtIndex:0] : nil;
    [_events filterUsingPredicate:[NSPredicate predicateWithFormat:@"%K != %@ AND %K != %@", kTargetKey, target, kSelectorKey, NSStringFromSelector(action)]];
    BOOL mustSignal = originalNextEvent != ([_events count] > 0 ? [_events objectAtIndex:0] : nil);
    [_condition signal];
    [_condition unlock];
    
    if (mustSignal) {
        pthread_kill(_thread, SIGALRM); // Interrupt thread if it's performing a mach_wait_until
    }
}

- (void)cancelAction:(SEL)action target:(id)target context:(id)context {
    [_condition lock];
    NSDictionary *originalNextEvent = [_events count] > 0 ? [_events objectAtIndex:0] : nil;
    [_events filterUsingPredicate:[NSPredicate predicateWithFormat:@"%K != %@ AND %K != %@ AND %K != %@", kTargetKey, target, kSelectorKey, NSStringFromSelector(action), kArgumentKey, context]];
    BOOL mustSignal = originalNextEvent != ([_events count] > 0 ? [_events objectAtIndex:0] : nil);
    [_condition signal];
    [_condition unlock];
    
    if (mustSignal) {
        pthread_kill(_thread, SIGALRM); // Interrupt thread if it's performing a mach_wait_until
    }
}

#if NS_BLOCKS_AVAILABLE
- (void)scheduleBlock:(void (^)(void))block inTimeInterval:(NSTimeInterval)timeInterval {
    [self addSchedule:[NSDictionary dictionaryWithObjectsAndKeys:
                       [block copy], kBlockKey,
                       [NSNumber numberWithUnsignedLongLong:mach_absolute_time() + (timeInterval / _timebase_ratio)], kTimeKey,
                       nil]];
}

#endif

- (void)addSchedule:(NSDictionary *)schedule {
    [_condition lock];
    [_events addObject:schedule];
    [_events sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kTimeKey ascending:YES]]];
    BOOL mustSignal = [_events count] > 1 && [_events objectAtIndex:0] == schedule;
    [_condition signal];
    [_condition unlock];
    
    if (mustSignal) {
        pthread_kill(_thread, SIGALRM); // Interrupt thread if it's performing a mach_wait_until and new schedule is earlier
    }
}

void *thread_entry(void *argument) {
    [(__bridge PreciseTimer *)argument thread];
    
    return NULL;
}

void thread_signal(int signal) {
    // Ignore
}

- (void)thread {
    signal(SIGALRM, thread_signal);
    [_condition lock];
    
    while ( 1 ) {
        while ( [_events count] == 0 ) {
            [_condition wait];
        }
        NSDictionary *nextEvent = [_events objectAtIndex:0];
        NSTimeInterval time = [[nextEvent objectForKey:kTimeKey] unsignedLongLongValue] * _timebase_ratio;
        
        [_condition unlock];
        
        mach_wait_until((uint64_t)((time - kSpinLockTime) / _timebase_ratio));
        
        if ( (double)(mach_absolute_time() * _timebase_ratio) >= time-kSpinLockTime ) {
            
            // Spin lock until it's time
            uint64_t end = time / _timebase_ratio;
            while ( mach_absolute_time() < end );
            
#ifdef kAnalyzeTiming
            double discrepancy = (double)(mach_absolute_time() * timebase_ratio) - time;
            printf("TPPreciseTimer fired: %lfs time discrepancy\n", discrepancy);
#endif
            
            // Perform action
#if NS_BLOCKS_AVAILABLE
            void (^block)(void) = [nextEvent objectForKey:kBlockKey];
            if ( block ) {
                block();
            } else {
#endif
                // To resolve a warning here, I have followed the points outlined inthese two comments:
                // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
                // http://stackoverflow.com/questions/21433873/performselector-may-cause-a-leak-because-its-selector-is-unknown-in-singleton-cl
                
                id target = [nextEvent objectForKey:kTargetKey];
                if (!target) { return; }
                SEL selector = NSSelectorFromString([nextEvent objectForKey:kSelectorKey]);
                IMP imp = [target methodForSelector:selector];
                
                if ( [nextEvent objectForKey:kArgumentKey] ) {
//                    [target performSelector:selector withObject:[nextEvent objectForKey:kArgumentKey]];
                    void (*func)(id, SEL, id) = (void *)imp;
                    func(target, selector, [nextEvent objectForKey:kArgumentKey]);
                } else {
//                    [target performSelector:selector];
                    void (*func)(id, SEL) = (void *)imp;
                    func(target, selector);
                }
                
#if NS_BLOCKS_AVAILABLE
            }
#endif
            
            [_condition lock];
            [_events removeObject:nextEvent];
        } else {
            [_condition lock];
        }
    }
}

+ (void)removeAllScheduledEvents {
    [__sharedInstance removeAllEvents];
}

- (void)removeAllEvents {
    [_condition lock];
    pthread_kill(_thread, SIGALRM); // Interrupt thread if it's performing a mach_wait_until
    [_events removeAllObjects];
    [_condition unlock];
}

@end