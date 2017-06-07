//
//  TTCircleTimer.h
//  Triggertrap
//
//  Created by Ross Gibson on 21/08/2013.
//
//

#import "DACircularProgressView.h"

#pragma mark - Delegate

@class TTCircleTimer;
@protocol TTCircleTimerDelegate <NSObject>
@optional
- (void)progressComplete;
@end

#pragma mark - Class

typedef NS_ENUM(NSInteger, kProgressDirection) {
    kProgressDirectionClockwise = 0,
    kProgressDirectionAntiClockwise
};

@interface TTCircleTimer : DACircularProgressView

@property (weak) id <TTCircleTimerDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval cycleDuration;
@property (nonatomic, assign) NSInteger progressDirection;
@property (nonatomic, assign) BOOL continuous;
@property (nonatomic, assign) BOOL isRunning;

#pragma mark - Public

- (void)start;
- (void)stop;
- (void)repeat;

@end
