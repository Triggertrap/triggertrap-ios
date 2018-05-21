//
//  MotionDetectionViewController.h
//  TriggertrapSLR
//
//  Created by Ross Gibson on 17/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

#import "MotionDetectionViewController.h"
#import <CoreImage/CoreImage.h>
#import "UIDevice+Camera.h"

@interface MotionDetectionViewController()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewBottomSpacing;

@end

@implementation MotionDetectionViewController { 
}

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[UIDevice currentDevice] hasFrontCamera] || ![[UIDevice currentDevice] hasRearCamera]) {
        _rotationButton.hidden = YES;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        
        self.viewBottomSpacing.constant += bottomPadding;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupFilter];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    videoCamera.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Note: We need to stop camera capture before the view goes off the screen
    // in order to prevent a crash from the camera still sending frames.
    [videoCamera stopCameraCapture];
}

#pragma mark - Actions

- (IBAction)rotateCameraTapped:(id)sender {
    [videoCamera rotateCamera];
}

- (IBAction)updatedFilterFromSlider:(id)sender {
    [videoCamera resetBenchmarkAverage];
    [(GPUImageMotionDetector *)filter setLowPassFilterStrength:[(UISlider *)sender value]];
}

#pragma mark - Private

- (void)setupFilter; {
    
    // By default show the back camera, otherwise show the front facing camera
    if ([[UIDevice currentDevice] hasRearCamera]) {
        videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition: AVCaptureDevicePositionBack];
    } else {
        videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition: AVCaptureDevicePositionFront];
    }
    
    videoCamera.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Force the front facing camera to show the image the same way as the standard iPhone camera
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    filter = [[GPUImageMotionDetector alloc] init];
    
    [videoCamera addTarget:filter];
    
    videoCamera.runBenchmark = YES;
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
//    boundsView = [[UIView alloc] initWithFrame:CGRectMake(100.0, 100.0, 100.0, 100.0)];
//    boundsView.layer.borderWidth = 1;
//    boundsView.layer.borderColor = [[UIColor redColor] CGColor];
//    [self.view addSubview:boundsView];
//    boundsView.hidden = YES;
    
    __unsafe_unretained MotionDetectionViewController *weakSelf = self;
    
    [(GPUImageMotionDetector *) filter setMotionDetectionBlock:^(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime) {
        
        if (motionIntensity > 0.01) {
//            CGFloat motionBoxWidth = 1500.0 * motionIntensity;
//            CGSize viewBounds = weakSelf.view.bounds.size;
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf->boundsView.frame = CGRectMake(round(viewBounds.width * motionCentroid.x - motionBoxWidth / 2.0), round(viewBounds.height * motionCentroid.y - motionBoxWidth / 2.0), motionBoxWidth, motionBoxWidth);
//                weakSelf->boundsView.hidden = NO;
                
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(motionDetected:)]) {
                    [weakSelf.delegate motionDetected:true];
                }
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf->boundsView.hidden = YES;
                
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(motionDetected:)]) {
                    [weakSelf.delegate motionDetected:false];
                }
            });
        }
        
    }];
    
    [videoCamera addTarget:filterView];
    [videoCamera startCameraCapture];
}

@end
