//
//  UIColor+branding.m
//  Triggertrap
//
//  Created by Ross Gibson on 27/11/2013.
//
//

#import "UIColor+branding.h"

@implementation UIColor (branding)

+ (UIColor *)TTLightGreyColour {
    static UIColor *lightGrey = nil;
    
    if (!lightGrey) {
        lightGrey = [UIColor colorWithRed:239.0f / 255.0f
                              green:239.0f / 255.0f
                               blue:239.0f / 255.0f
                              alpha:1.000f];
    }
    
    return lightGrey;
}

+ (UIColor *)TTMediumGreyColour {
    static UIColor *mediumGrey = nil;
    
    if (!mediumGrey) {
        mediumGrey = [UIColor colorWithRed:219.0f / 255.0f
                              green:219.0f / 255.0f
                               blue:219.0f / 255.0f
                              alpha:1.000f];
    }
    
    return mediumGrey;
}

+ (UIColor *)TTMediumDarkGreyColour {
    static UIColor *mediumDarkGrey = nil;
    
    if (!mediumDarkGrey) {
        mediumDarkGrey = [UIColor colorWithRed:159.0f / 255.0f
                              green:159.0f / 255.0f
                               blue:159.0f / 255.0f
                              alpha:1.000f];
    }
    
    return mediumDarkGrey;
}

+ (UIColor *)TTDarkGreyColour {
    static UIColor *darkGrey = nil;
    
    if (!darkGrey) {
        darkGrey = [UIColor colorWithRed:131.0f / 255.0f
                              green:131.0f / 255.0f
                               blue:131.0f / 255.0f
                              alpha:1.000f];
    }
    
    return darkGrey;
}

+ (UIColor *)TTBlackColour {
    static UIColor *black = nil;
    
    if (!black) {
        black = [UIColor colorWithRed:49.0f / 255.0f
                              green:49.0f / 255.0f
                               blue:49.0f / 255.0f
                              alpha:1.000f];
    }
    
    return black;
}

+ (UIColor *)TTWhiteColour {
    static UIColor *white = nil;
    
    if (!white) {
        white = [UIColor colorWithRed:253.0f / 255.0f
                              green:253.0f / 255.0f
                               blue:253.0f / 255.0f
                              alpha:1.000f];
    }
    
    return white;
}

+ (UIColor *)TTRedColour {
    static UIColor *red = nil;
    
    if (!red) {
        red = [UIColor colorWithRed:226.0f / 255.0f
                              green:35.0f / 255.0f
                               blue:26.0f / 255.0f
                              alpha:1.000f];
    }
    
    return red;
}

//For SunriseSunset Caluclator
+ (UIColor *)TTShadeRedColour {
    static UIColor *shareRed = nil;
    
    if (!shareRed) {
        shareRed =  [UIColor colorWithRed:0.792 green:0.122 blue:0.09 alpha:1]; /*#ca1f17 */
    }
    
    return shareRed;
}

+ (UIColor *)TTDarkRedColour {
    static UIColor *darkRed = nil;
    
    if (!darkRed) {
        darkRed = [UIColor colorWithRed:193.0f / 255.0f
                              green:36.0f / 255.0f
                               blue:28.0f / 255.0f
                              alpha:1.000f];
    }
    
    return darkRed;
}

//For Time Warp mode
+ (UIColor *)TTTimeWarpDarkRedColor {
    static UIColor *timeWarpDarkRed = nil;
    
    if (!timeWarpDarkRed) {
        timeWarpDarkRed = [UIColor colorWithRed:0.62 green:0.094 blue:0.071 alpha:1]; /*#9e1812*/
    }
    
    return timeWarpDarkRed;
}

+ (UIColor *)TTDarkRedAlphaColour {
    static UIColor *darkRedAlpha = nil;
    
    if (!darkRedAlpha) {
        darkRedAlpha = [UIColor colorWithRed:193.0f / 255.0f
                              green:36.0f / 255.0f
                               blue:28.0f / 255.0f
                              alpha:0.700f];
    }
    
    return darkRedAlpha;
}

+ (UIColor *)TTGreenColour {
    static UIColor *green = nil;
    
    if (!green) {
        green = [UIColor colorWithRed:85.0f / 255.0f
                              green:213.0f / 255.0f
                               blue:80.0f / 255.0f
                              alpha:1.000f];
    }
    
    return green;
}

@end
