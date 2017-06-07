//
//  CLLocation+DMSFormatting.h
//  TriggerTrap
//
//  Created by Matt Kane on 26/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (DMSFormatting)

- (NSString *)toDegreeMinuteSecondString;

@end
