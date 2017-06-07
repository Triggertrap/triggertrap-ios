//
//  TTNumberPadView.h
//  TTNumericKeys
//
//  Created by Matt Kane on 12/08/2013.
//  Copyright (c) 2013 Triggertrap. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Delegate

@protocol TTNumberPadViewDelegate
@optional
- (void)digitPressed:(NSInteger)value;
- (void)deletePressed;
- (void)dismissKeypad;
- (void)clearPressed;
@end

@interface TTNumberPadView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UIInputViewAudioFeedback> {
    UICollectionView *collectionView;
}

@property (nonatomic, weak) NSObject<TTNumberPadViewDelegate> *delegate;
@property (nonatomic, retain) UIFont *font;

@end