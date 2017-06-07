//
//  UIDevice+Camera.h
//  TTLibrary
//
//  Created by Ross Gibson on 27/01/2014.
//  Copyright (c) 2014 Triggertrap Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Camera)

@property (readonly) BOOL hasCamera;
@property (readonly) BOOL hasFrontCamera;
@property (readonly) BOOL hasRearCamera;

@end