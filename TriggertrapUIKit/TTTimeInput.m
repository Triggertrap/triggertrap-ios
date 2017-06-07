//
//  TTTimeInput.m
//  TTNumericKeys
//
//  Created by Matt Kane on 12/08/2013.
//  Copyright (c) 2013 Triggertrap. All rights reserved.
//

#import "TTTimeInput.h"
#import "TTBranding.h"

@implementation TTTimeInput

#pragma mark - Inits

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        hours = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 40)];
        hours.text = @"00";
        hours.adjustsFontSizeToFitWidth = YES;
        
        minutes = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 60, 40)];
        minutes.text = @"00";
        
        seconds = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 60, 40)];
        seconds.text = @"00";
        
        fractions = [[UILabel alloc] initWithFrame:CGRectMake(180, 4, 60, 40)];
        
        self.showFractionsInFull = NO;
        
        if (!self.showFractionsInFull) {
            fractions.text = @".00";
        } else {
            fractions.text = @".000";
        }
        
        minutes.font = seconds.font = self.valueFont;
        fractions.font = self.smallValueFont;
        
        h = [[UILabel alloc] initWithFrame:CGRectMake(54, 3, 20, 20)];
        h.text = @"H";
        
        m = [[UILabel alloc] initWithFrame:CGRectMake(113, 3, 20, 20)];
        m.text = @"M";
        
        s = [[UILabel alloc] initWithFrame:CGRectMake(175, 3, 20, 20)];
        s.text = @"S";
        
        hours.backgroundColor = [UIColor clearColor];
        minutes.backgroundColor = [UIColor clearColor];
        seconds.backgroundColor = [UIColor clearColor];
        fractions.backgroundColor = [UIColor clearColor];
        h.backgroundColor = [UIColor clearColor];
        m.backgroundColor = [UIColor clearColor];
        s.backgroundColor = [UIColor clearColor];
        
        [self addSubview:hours];
        [self addSubview:h];
        
        [self addSubview:minutes];
        [self addSubview:m];
        
        [self addSubview:seconds];
        [self addSubview:fractions];
        [self addSubview:s];
        
        self.displayView.hidden = YES;
        
        self.showFractions = TRUE;
        
        self.unitsLabelFont = TTTimeInputUnitsFont;
        self.boldValueFont = TTTimeInputBoldValueFont;
    }
    
    return self;
}

- (void)setMinimumWidthForLabel:(UILabel *)label {
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.5f;
}


- (void)hoursVisible:(BOOL)visible {
    
    NSArray *array = [NSArray arrayWithObjects:minutes, m, seconds, s,fractions, nil];
    
    //hours + h width
    float hoursWidth = 60;
    
    if (!visible) {
        h.hidden = YES;
        hours.hidden = YES;
        
        for (int i = 0; i < array.count; i++) {
            UILabel *label = array[i];
            label.frame = CGRectMake(label.frame.origin.x - hoursWidth, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
        }
    } else {
        h.hidden = NO;
        hours.hidden = NO;
        
        for (int i = 0; i < array.count; i++) {
            UILabel *label = array[i];
            label.frame = CGRectMake(label.frame.origin.x + hoursWidth, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
        }
    }
}

#pragma mark - Private

- (void)setup {
    if (!self.maxValue) {
        self.maxValue = ULONG_LONG_MAX;
    }
    
    self.maxNumberLength = 8;
}

- (void)normalise {
    
    int frac;
    int secs;
    int mins;
    int hrs;
    unsigned long long millis;
    
    if (!self.showFractionsInFull) {
        frac = rawValue % 100;
        millis = frac * 10;
        secs = floor(rawValue % 10000 / 100);
        mins = floor(rawValue % 1000000 / 10000);
        hrs = floor(rawValue % 100000000 / 1000000);
    } else {
        frac = rawValue % 1000;
        millis = frac;
        secs = floor(rawValue % 100000 / 1000);
        mins = floor(rawValue % 10000000 / 100000);
        hrs = floor(rawValue % 1000000000 / 10000000);
    }
    
    
    millis += secs * 1000;
    
    millis += mins * 60000;
    
    millis += hrs * 3600000;
    
    if (millis > self.maxValue) {
        millis = self.maxValue;
    }
    
    if (millis < self.minValue) {
        if (self.valueChanged) {
            if (!self.keyboardOpen) {
                millis = self.minValue;
            }
        } else {
            millis = self.initialValue;
        }
    }

    [self setDisplayValue:millis];
}

- (void)updateRawDisplay:(unsigned long long)newVal {
    
    if (!self.showFractionsInFull) {
        int frac = newVal % 100;
        fractions.text = [NSString stringWithFormat:@".%02d", frac];
        
        int secs = floor(newVal % 10000 / 100);
        seconds.text = [NSString stringWithFormat:@"%02d", secs];
        
        int mins = floor(newVal % 1000000 / 10000);
        minutes.text = [NSString stringWithFormat:@"%02d", mins];
        
        int hrs = floor(newVal % 100000000 / 1000000);
        hours.text = [NSString stringWithFormat:@"%02d", hrs];
        
    } else {
        int frac = newVal % 1000;
        fractions.text = [NSString stringWithFormat:@".%03d", frac];
        
        int secs = floor(newVal % 100000 / 1000);
        seconds.text = [NSString stringWithFormat:@"%02d", secs];
        
        int mins = floor(newVal % 10000000 / 100000);
        minutes.text = [NSString stringWithFormat:@"%02d", mins]; 
        
        int hrs = floor(newVal % 1000000000 / 10000000);
        hours.text = [NSString stringWithFormat:@"%02d", hrs];
        
    }
    
    rawValue = newVal;
    
    //[self normalise];
}

- (void)updateValueDisplay {
    unsigned long long msperhour = 3600000;
    unsigned long long mspermin = 60000;

    unsigned long long hrs = self.displayValue / msperhour;
    unsigned long long mins = (self.displayValue % msperhour) / mspermin;
    unsigned long long secs = ((self.displayValue % msperhour) % mspermin) / 1000;
    
    unsigned long long frac;
    
    if (!self.showFractionsInFull) {
        frac = self.displayValue % 1000 / 10;
        fractions.text = [NSString stringWithFormat:@".%02llu", frac];
    } else {
        frac = self.displayValue % 1000;
        fractions.text = [NSString stringWithFormat:@".%03llu", frac];
    }

    seconds.text = [NSString stringWithFormat:@"%02llu", secs];
    minutes.text = [NSString stringWithFormat:@"%02llu", mins];
    hours.text = [NSString stringWithFormat:@"%02llu", hrs];
    
    [self keyboardFinished];
}

#pragma mark - Setters

- (void)setShowFractions:(BOOL)showFractions {
    _showFractions = showFractions;
    fractions.hidden = !_showFractions;
}

- (void)setValueFont:(UIFont *)valueFont {
    super.valueFont = valueFont;
    seconds.font = valueFont;
    minutes.font = valueFont;
}

- (void)setBoldValueFont:(UIFont *)boldValueFont {
    _boldValueFont = boldValueFont;
    hours.font = boldValueFont; 
}

- (void)setSmallValueFont:(UIFont *)smallValueFont {
    super.smallValueFont = smallValueFont;
    fractions.font = smallValueFont;
}

- (void)setUnitsLabelFont:(UIFont *)unitsLabelFont {
    _unitsLabelFont = unitsLabelFont;
    h.font = unitsLabelFont;
    m.font = unitsLabelFont;
    s.font = unitsLabelFont;
}

- (void)setFontColor:(UIColor *)color {
    hours.textColor = h.textColor = minutes.textColor = m.textColor = seconds.textColor = s.textColor = fractions.textColor = color;
}

- (CGPoint)adjustedSize {
    return CGPointMake(s.frame.origin.x + s.frame.size.width, hours.frame.size.height);
}

#pragma mark - TTNumberPadViewDelegate methods

- (void)digitPressed:(NSInteger)value {
    self.valueChanged = YES;
    
    if (self.keyboardJustOpened) {
        rawValue = 0;
    }
    
    unsigned long long newVal;
    
    if (self.showFractions) {
        newVal = rawValue * 10ul + value;
    } else {
        newVal = rawValue * 10ul + (value * 100) ;
    }
    
    if ([self numberOfDigits:newVal] > self.maxNumberLength) {
        return;
    }
    
    [self updateRawDisplay:newVal];
    
    self.keyboardJustOpened = NO;
    
    [self keyboardFinished];
}

- (void)deletePressed {
    self.valueChanged = YES;
    
    unsigned long long newVal = rawValue / 10ul;
    
    if (!self.showFractions) {
        if ([self numberOfDigits:newVal] < 2) {
            return;
        }
        
        // Ensure it ends "00"
        newVal = floor(newVal / 100) * 100;
    }
    
    [self updateRawDisplay:newVal];
    [self keyboardFinished];
}

- (void)clearPressed {
    self.valueChanged = YES;
    [self updateRawDisplay:0];
    
    [self keyboardFinished];
}

- (void)keyboardFinished {
    if (self.ttKeyboardDelegate && [self.ttKeyboardDelegate respondsToSelector:@selector(editingChanged)]) {
        [self.ttKeyboardDelegate performSelector:@selector(editingChanged) withObject:nil];
    }
}
@end