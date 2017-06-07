//
//  TTTimeInput.h
//  TTNumericKeys
//
//  Created by Matt Kane on 12/08/2013.
//  Copyright (c) 2013 Triggertrap. All rights reserved.
//

#import "TTNumberInput.h"

@interface TTTimeInput : TTNumberInput {
    UILabel *hours;
    UILabel *minutes;
    UILabel *seconds;
    UILabel *fractions;
    UILabel *h;
    UILabel *m;
    UILabel *s;
    unsigned long long rawValue;
}

@property (nonatomic, assign) BOOL showFractionsInFull;
@property (nonatomic, assign) BOOL showFractions;
@property (nonatomic, retain) UIFont *boldValueFont;
@property (nonatomic, retain) UIFont *unitsLabelFont;

- (void)updateRawDisplay:(unsigned long long)newVal;
- (void)setFontColor:(UIColor *)color; 
- (CGPoint)adjustedSize;

/*!
 * Pass YES to hide hours/h and move the rest of the labels to the left. Pass NO after YES to show hours/h and move the labels back to their original places
 */

- (void)hoursVisible:(BOOL)visible;

@end