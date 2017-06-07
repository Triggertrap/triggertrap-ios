//
//  FaceDetectionViewController.h
//  TriggertrapSLR
//
//  Created by Ross Gibson on 17/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "HorizontalPicker.h"

@class FaceDetectionViewController;

@protocol FaceDetectorDelegate <NSObject>

@required

- (void)facesDetected:(NSUInteger)faces;

@end

@interface FaceDetectionViewController : UIViewController <GPUImageVideoCameraDelegate, HorizontalPickerDelegate> {
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;

//    UIView *faceView;
    CIDetector *faceDetector;
    
    BOOL faceThinking;
    
    NSInteger requiredFaces;
}

@property (nonatomic, weak) IBOutlet UIButton * rotationButton; 
@property (nonatomic, weak) id <FaceDetectorDelegate> delegate;
@property (nonatomic,retain) CIDetector*faceDetector;
@property (nonatomic, weak) IBOutlet HorizontalPicker *picker;

@end
