//
//  CachedPushNoAnimationStoryboardSegue.m
//  TriggertrapSLR
//
//  Created by Ross Gibson on 29/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

#import "CachedPushNoAnimationStoryboardSegue.h"

#pragma mark - Statics

static NSMutableDictionary * _CachedPushNoAnimationStoryboardSegueCache;

#pragma mark - Private Class - _CachedSegueKey

@interface _CachedSegueKey : NSObject <NSCopying> {
    Class _vcClass;
    NSString *_identifier;
}

+ (id)keyWithIdentifier:(NSString *)anId viewController:(UIViewController *)aVC;

@end

@implementation _CachedSegueKey

+ (id)keyWithIdentifier:(NSString *)anId viewController:(UIViewController *)aVC {
    _CachedSegueKey *me = [[self alloc] init];
    me->_vcClass = aVC.class;
    me->_identifier = [anId copy];
    return me;
}

- (BOOL)isEqual:(id)object {
    _CachedSegueKey *obj = (_CachedSegueKey *)object;
    BOOL e = ([obj->_identifier isEqualToString:self->_identifier] &&
            obj->_vcClass == self->_vcClass);
    return e;
}

- (NSUInteger)hash {
    NSUInteger hash = 0;
    hash = ((NSUInteger)_vcClass * 0x1f1f1f1f) ^ _identifier.hash;
    return hash;
}

- (id)copyWithZone:(NSZone *)zone {
    _CachedSegueKey *copy = [_CachedSegueKey new];
    copy->_identifier = [_identifier copy];
    copy->_vcClass = _vcClass;
    return copy;
}

@end

#pragma mark - CachedPushNoAnimationStoryboardSegue

@implementation CachedPushNoAnimationStoryboardSegue

#pragma mark - Class Methods

+ (void)drainCache {
    _CachedPushNoAnimationStoryboardSegueCache = nil;
}

#pragma mark - Overrides

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {
    // Alloc the static dict if required
    if (!_CachedPushNoAnimationStoryboardSegueCache) {
        _CachedPushNoAnimationStoryboardSegueCache = [NSMutableDictionary dictionary];
    }
    
    // Add it to the cache if doesn't exist...
    _CachedSegueKey *key = [_CachedSegueKey keyWithIdentifier:identifier viewController:destination];

    _destinationWasCached = YES;
    
    if (!([_CachedPushNoAnimationStoryboardSegueCache.allKeys containsObject:key])) {
        _CachedPushNoAnimationStoryboardSegueCache[key] = destination;
        _destinationWasCached = NO;
    }
    
    // Swizzle for the cached destination
    UIViewController *newDest = _CachedPushNoAnimationStoryboardSegueCache[key];
    return [super initWithIdentifier:identifier source:source destination:newDest];
    
}

- (void)perform {
    UIViewController *vc = (UIViewController *)self.sourceViewController;
    
    [vc.navigationController pushViewController:self.destinationViewController animated:FALSE];
}

@end
