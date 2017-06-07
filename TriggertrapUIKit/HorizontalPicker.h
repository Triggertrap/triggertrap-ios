//
//  HorizontalPicker.h
//  TTHorizontalPicker
//
//  Created by Valentin Kalchev on 12/08/2014.
//  Copyright (c) 2014 Triggertrap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientView.h"

typedef NS_OPTIONS (NSInteger, RowsPerColumn) {
    One,
    Two
};

@protocol HorizontalPickerDelegate <NSObject>
@optional

/*!
 * Use to send a call back to view controller that will receive the last item index selected from the horizontal picker
 */
- (void)horizontalPicker:(id)horizontalPicker didSelectObjectFromDataSourceAtIndex:(NSInteger)index;

/*!
 * Use to send a call back to view controller that will receive the last item value selected from the horizontal picker
 */
- (void)horizontalPicker:(id)horizontalPicker didSelectValue:(NSNumber *)value;

/*!
 * Use to send a call back to view controller that will receive the last item string selected from the horizontal picker
 */
- (void)horizontalPicker:(id)horizontalPicker didSelectString:(NSString *)string;

@end

@interface HorizontalPicker : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
 
@property (strong, nonatomic) id <HorizontalPickerDelegate> delegate;

@property (nonatomic) float value;
/*!
 * Use to change the horizontal picker text font color
 */
@property (strong, nonatomic) UIColor *fontColor;

/*!
 * Use to change the horizontal picker text font
 */
@property (strong, nonatomic) UIFont *font;

/*!
 * Use to set minimum value that the horizontal picker should display (use "value" string from plist as reference)
 */
@property (strong, nonatomic) NSNumber *minimumValue;

/*!
 * Use to set maximum value that the horizontal picker should display (use "value" string from plist as reference)
 */
@property (strong, nonatomic) NSNumber *maximumValue;

/*!
 * Use to set index in horizontal picker that needs to be displayed
 */
@property (strong, nonatomic) NSIndexPath *currentIndex;

/*!
 * Use to set data source for items in the horizontal picker
 */
@property (strong, nonatomic) NSArray *dataSource;

/*!
 * Use to set default index that needs displaying when horizontal picker becomes visible
 */
@property (nonatomic) NSInteger defaultIndex;

@property (nonatomic, strong) GradientView *gradientView;

/*!
 * Use to refresh horizontal picker items in case their span has changed
 */
- (void)refreshCurrentIndex;

/*!
 * Use to get saved index from picker
 */
- (NSInteger)savedIndexForKey:(NSString *)identifier;

/*!
 * Use to save index from picker
 */
- (void)saveIndex:(NSInteger)index forKey:(NSString *)identifier;

@end
