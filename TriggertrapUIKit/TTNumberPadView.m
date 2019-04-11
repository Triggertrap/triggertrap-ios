//
//  TTNumberPadView.m
//  TTNumericKeys
//
//  Created by Matt Kane on 12/08/2013.
//  Copyright (c) 2013 Triggertrap. All rights reserved.
//

#import "TTNumberPadView.h" 

@interface TTNumberPadView (private)
- (void)setupCollectionView;
@end

@implementation TTNumberPadView

#pragma mark - Inits

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupCollectionView];
        
        self.font = [UIFont fontWithName:@"Metric-Regular" size: 30.0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performThemeUpdate:) name:@"ThemeHasBeenUpdated" object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)buttonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 9) {
        if ([self.delegate respondsToSelector:@selector(deletePressed)]) {
            [self.delegate deletePressed];
        }
        return;
    }
    
    if (button.tag == 11) {
        if ([self.delegate respondsToSelector:@selector(dismissKeypad)]) {
            [self.delegate dismissKeypad];
        }
        return;
    }
    
    NSInteger digit;
    
    if (button.tag == 10) {
        digit = 0;
    } else {
        digit = button.tag + 1;
    }
    
    if ([self.delegate respondsToSelector:@selector(digitPressed:)]) {
        [self.delegate digitPressed:digit];
    }
}

- (BOOL)appThemeNormal {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"AppTheme"] == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)performThemeUpdate: (NSNotification *)notification {
    [collectionView reloadData];
}

- (void)sendClear {
    if ([self.delegate respondsToSelector:@selector(clearPressed)]) {
        [self.delegate clearPressed];
    }
}

#pragma mark - Private

- (void)setupCollectionView {
    collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    collectionView.backgroundColor = [UIColor colorWithRed:49.0/255.0 green:49.0/255.0 blue:49.0/255.0 alpha:1.0];

    //modern device fix
    UIEdgeInsets contentInset = collectionView.contentInset;

    collectionView.contentInset = contentInset;
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    [self addSubview:collectionView];
}

#pragma mark - UICollectionView methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger pos = [indexPath indexAtPosition:1];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(@available(iOS 11.0, *))
       if(pos >= 9 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && orientation == UIInterfaceOrientationPortrait)
           return CGSizeMake((self.frame.size.width) / 3, (self.frame.size.height - self.safeAreaInsets.bottom) / 4 + self.safeAreaInsets.bottom);
    return CGSizeMake((self.frame.size.width) / 3, (self.frame.size.height) / 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIColor *)fillColor {
    if ([self appThemeNormal] == YES) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0];
    }
}

- (UIColor *)foregroundColor {
    if ([self appThemeNormal] == YES) {
        return [UIColor colorWithRed:131.0/255.0 green:131.0/255.0 blue:131.0/255.0 alpha:1.0];
    } else {
        return [UIColor colorWithRed:62.0/255.0 green:62.0/255.0 blue:62.0/255.0 alpha:1.0];
    }
}

- (UIImage *)backspaceButtonImage {
    
    if ([self appThemeNormal] == YES) {
        return [UIImage imageNamed:@"Delete"];
    } else {
        return [UIImage imageNamed:@"Delete_Night"];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger pos = [indexPath indexAtPosition:1];
    UICollectionViewCell *cell = [cView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    for (cView in cell.contentView.subviews) {
        [cView removeFromSuperview];
    }

    UIButton *button = [[UIButton alloc] initWithFrame:cell.bounds];
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = [[self fillColor] CGColor];
    
    NSString *title;
    
    if (pos < 9) {
        title = [NSString stringWithFormat:@"%d", (int)pos + 1];
    } else if (pos == 9) {
        button.backgroundColor = [self foregroundColor];
        [button setImage: [self backspaceButtonImage] forState:UIControlStateNormal];
        title = @"";
    } else if (pos == 10) {
        title = @"0";
    } else {
        button.backgroundColor = [self foregroundColor];
        title = NSLocalizedString(@"OK", @"OK");
    }
    
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = pos;
    
    if (pos == 9) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendClear)];
        longPress.minimumPressDuration = 1.0;
        [button addGestureRecognizer:longPress];
    }

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    //this if can't be collapsed or the compiler freaks out
    if (@available(iOS 11.0, *)){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && orientation == UIInterfaceOrientationPortrait){
            if(pos == 9){
                button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                button.contentEdgeInsets = UIEdgeInsetsMake((button.frame.size.height - self.safeAreaInsets.bottom) / 4, 0, 0, 0);
            } else if(pos == 10){
                button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                button.contentEdgeInsets = UIEdgeInsetsMake((button.frame.size.height - self.safeAreaInsets.bottom) / 8, 0, 0, 0);
            } else if(pos == 11){
                button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                button.contentEdgeInsets = UIEdgeInsetsMake((button.frame.size.height - self.safeAreaInsets.bottom) / 8, 0, 0, 0);
            }
        }
    }
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = self.font;
    [button setTitleColor:[self fillColor] forState:UIControlStateNormal];
    
    [button setIsAccessibilityElement:YES];
    [button setAccessibilityLabel:title];
    [button setAccessibilityHint:@"Keypad digit"];
    [button setAccessibilityTraits:UIAccessibilityTraitButton];
    
    [cell.contentView addSubview:button];
    
    return cell;
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
