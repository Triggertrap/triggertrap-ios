//
//  CachedPushNoAnimationStoryboardSegue.h
//  TriggertrapSLR
//
//  Created by Ross Gibson on 29/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CachedPushNoAnimationStoryboardSegue : UIStoryboardSegue

/*!
* Manually drain the VC cache. This is the only way to release the cached VCs from their static store.
* Also release the dict used to hold the cache.  Make this a final op in your apps shutdown cleanup
*/
+ (void)drainCache;


/*!
* Use for exampe in [prepareForSegue:...] to determine whether the destination VC is a fresh instance or a pre-existing one
*/
@property (nonatomic, readonly) BOOL destinationWasCached;

@end