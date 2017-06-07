//
//  TTNumberInput.h
//  TTNumericKeys
//
//  Created by Matt Kane on 09/08/2013.
//  Copyright (c) 2013 Triggertrap. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTNumberPadView.h"

#pragma mark - Delegate

@protocol TTNumberInputDelegate <NSObject>
@optional
- (void)TTNumberInputKeyboardDidDismiss;
- (void)numberInputValueChanged;
- (void)numberInputDisplayValueChanged;
- (void)dismissButtonPressed;

@end

@protocol TTKeyboardDelegate <NSObject>
@optional
- (void)editingChanged;
@end

@interface TTNumberInput : UIControl <TTNumberPadViewDelegate> {
    UIView *overlayView;
    UIView *coveredView;
    UIView *superView;
    TTNumberPadView *numberPadView;
}

@property (strong, nonatomic) id <TTNumberInputDelegate> delegate;
@property (strong, nonatomic) id <TTKeyboardDelegate> ttKeyboardDelegate;

@property (nonatomic, retain) IBOutlet TTNumberInput *nextField;
@property (nonatomic, assign) NSInteger numberType;
@property (nonatomic, assign) NSInteger maxNumberLength;
@property (nonatomic, retain) UILabel  *displayView;
@property (nonatomic, retain) UIFont *valueFont;
@property (nonatomic, retain) UIFont *smallValueFont;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, retain) UIColor *borderHighlightColor;
@property (nonatomic, assign) unsigned long long maxValue;
@property (nonatomic, assign) unsigned long long minValue;
@property (nonatomic, assign) unsigned long long value;
@property (nonatomic, assign) unsigned long long displayValue;
@property (nonatomic, assign) unsigned long long initialValue;
@property (nonatomic) BOOL valueChanged;
@property (nonatomic) BOOL keyboardOpen;
@property (nonatomic) BOOL keyboardJustOpened;

/*!
 * Determins whether the touch outside the keyboard will dismiss it. "YES" per default. If set to "NO", OK button is hidden
 */
@property (nonatomic) BOOL keyboardCanBeDismissed;

#pragma mark - Public

- (void)openKeyboardInView:(UIView *)view covering:(UIView *)covered;
- (void)openKeyboardInView:(UIView *)view covering:(UIView *)covered animate:(BOOL)animate;
- (void)normalise;
- (int)numberOfDigits:(unsigned long long)n;
- (void)updateValueDisplay;
- (void)hideKeyboard;
- (void)hideKeyboardWithAnimation:(BOOL)animate;
- (void)drawCursor;
- (unsigned long long)savedValueForKey:(NSString *)identifier;
- (void)saveValue:(unsigned long long)value forKey:(NSString *)identifier;

@end