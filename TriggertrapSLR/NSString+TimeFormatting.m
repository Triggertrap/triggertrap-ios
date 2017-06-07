//
//  NSString+TimeFormatting.m
//  TriggerTrap
//
//  Created by Matt Kane on 22/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+TimeFormatting.h"

@implementation NSString (TimeFormatting)

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)seconds format:(NSString *)format {
    return [self stringFromTimeInterval:seconds format:format compact:NO decimal:YES];
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)seconds format:(NSString *)format compact:(BOOL)compact decimal:(BOOL)decimal {
    NSString *string;
    
    if (!format) {
        format = @"%@";
    }
    
    // TODO: Update the keys of these strings
    if (decimal) {
        if (seconds < 1) {
            string = [NSString localizedStringWithFormat: compact ? NSLocalizedString(@"%.0f ms", @"milliseconds") : NSLocalizedString(@"%.0f milliseconds", nil),seconds * 1000.0];
        } else if (seconds < 10) {
            string = [NSString localizedStringWithFormat: compact ? NSLocalizedString(@"%.1f secs", @"seconds") : NSLocalizedString(@"%.1f seconds", nil),seconds ]; 
        } else if (seconds < 120) {
            string = [NSString localizedStringWithFormat: compact ? NSLocalizedString(@"%.0f secs", @"seconds") : NSLocalizedString(@"%.0f seconds", nil),seconds ]; 
        } else if (seconds < 5400) {
            string = [NSString localizedStringWithFormat: compact ? NSLocalizedString(@"%.1f mins", @"minutes") : NSLocalizedString(@"%.1f minutes", nil), seconds / 60.0 ];
        } else if (seconds < 172800) {
            string = [NSString localizedStringWithFormat: compact ? NSLocalizedString(@"%.1f hrs", @"hours") : NSLocalizedString(@"%.1f hours", nil), seconds / 3600.0 ];   
        } else {
            string = [NSString localizedStringWithFormat: NSLocalizedString(@"%.1f days", nil), seconds / 86400.0 ];
        }
    } else {
        int sec = (int)seconds % 60;
        int min = ((int)seconds / 60) % 60;
        int hours = (int)seconds / 3600;
        string = [NSString localizedStringWithFormat:NSLocalizedString(@"%i hours %i minutes and %i seconds", @"%i hours %i minutes and %i seconds"), hours, min, sec];
    }
    
    return [NSString stringWithFormat:format, string];
}

@end
 