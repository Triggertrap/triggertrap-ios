//
//  NSString+TimeFormatting.h
//  TriggerTrap
//
//  Created by Matt Kane on 22/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TimeFormatting)

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)seconds format:(NSString *)format;
+ (NSString *)stringFromTimeInterval:(NSTimeInterval)seconds format:(NSString *)format compact:(BOOL)compact decimal:(BOOL)decimal;

@end
