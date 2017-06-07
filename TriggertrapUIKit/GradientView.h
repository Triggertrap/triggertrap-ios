//
//  GradientView.h
//  TTHorizontalPicker
//
//  Created by Valentin Kalchev on 14/08/2014.
//  Copyright (c) 2014 Triggertrap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientView : UIView

/*!
 * Use to set left hand side start gradient color
 */
@property (nonatomic, strong) UIColor *leftGradientStartColor;

/*!
 * Use to set left hand side end gradient color
 */
@property (nonatomic, strong) UIColor *leftGradientEndColor;

/*!
 * Use to set right hand side start gradient color
 */
@property (nonatomic, strong) UIColor *rightGradientStartColor;

/*!
 * Use to set right hand side end gradient color
 */
@property (nonatomic, strong) UIColor *rightGradientEndColor;

/*!
 * Use to set horizontal lines (triangle & top line) color
 */
@property (nonatomic, strong) UIColor *horizontalLinesColor;

/*!
 * Use to set vertical lines (separating the view into three parts) color
 */
@property (nonatomic, strong) UIColor *verticalLinesColor;

@end
