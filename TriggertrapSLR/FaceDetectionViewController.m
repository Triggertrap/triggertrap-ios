//
//  FaceDetectionViewController.m
//  TriggertrapSLR
//
//  Created by Ross Gibson on 17/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

#import "FaceDetectionViewController.h"
#import <CoreImage/CoreImage.h>
#import "UIDevice+Camera.h"

@implementation FaceDetectionViewController  

@synthesize faceDetector;

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
    
    // Style the picker
    self.picker.gradientView.leftGradientStartColor = [UIColor clearColor];
    self.picker.gradientView.leftGradientEndColor = [UIColor clearColor];
    self.picker.gradientView.rightGradientStartColor = [UIColor clearColor];
    self.picker.gradientView.rightGradientEndColor = [UIColor clearColor];
    self.picker.gradientView.horizontalLinesColor = [UIColor whiteColor];
    self.picker.fontColor = [UIColor whiteColor];
    self.picker.font = [UIFont fontWithName:@"OpenSans" size:18.0f];
    
    self.picker.delegate = self;
    self.picker.dataSource = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PeekabooDataSource" ofType:@"plist"]];
    self.picker.minimumValue = [NSNumber numberWithInteger:1];
    self.picker.maximumValue = [NSNumber numberWithInteger:5];
    self.picker.defaultIndex = 0;
    
    if (![[UIDevice currentDevice] hasFrontCamera] || ![[UIDevice currentDevice] hasRearCamera]) {
        _rotationButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([GPUImageContext supportsFastTextureUpload]) {
        NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        faceThinking = NO;
    }
    
    self.picker.currentIndex = [NSIndexPath indexPathForRow:[self.picker savedIndexForKey:@"peekaboo.requiredFaces"] inSection:0];
    
    // Row 0 has 1 face therefore increment value with 1
    requiredFaces = self.picker.currentIndex.row + 1;
    
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
    // Note: We need to stop camera capture before the view goes off the screen
    // in order to prevent a crash from the camera still sending frames.
    [videoCamera stopCameraCapture];
    
	[super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction)rotateCameraTapped:(id)sender {
    [videoCamera rotateCamera];
}

#pragma mark - Private

- (void)setupFilter; {
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition: AVCaptureDevicePositionFront]; 
    
    videoCamera.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Force the front facing camera to show the image the same way as the standard iPhone camera
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    filter = [[GPUImageSaturationFilter alloc] init];
    [videoCamera setDelegate:self];
    [videoCamera addTarget:filter];
    
    videoCamera.runBenchmark = YES;
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    [filter addTarget:filterView];

    [videoCamera startCameraCapture];
}

- (void)horizontalPicker:(id)horizontalPicker didSelectValue:(NSNumber *)value {
    NSLog(@"%ld", (long)value.integerValue);
    
    requiredFaces = value.integerValue;
}
                                                             
-(void)horizontalPicker:(id)horizontalPicker didSelectObjectFromDataSourceAtIndex:(NSInteger)index {
    [self.picker saveIndex:index forKey:@"peekaboo.requiredFaces"];
}

#pragma mark - Face Detection Delegates

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (!faceThinking) {
        CFAllocatorRef allocator = CFAllocatorGetDefault();
        CMSampleBufferRef sbufCopyOut;
        CMSampleBufferCreateCopy(allocator,sampleBuffer,&sbufCopyOut);
        [self performSelectorInBackground:@selector(grepFacesForSampleBuffer:) withObject:CFBridgingRelease(sbufCopyOut)];
    }
}

- (void)grepFacesForSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    faceThinking = TRUE;

    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    if (attachments) {
        CFRelease(attachments);
    }

	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	int exifOrientation;
	
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
    
	BOOL isUsingFrontFacingCamera = FALSE;
    AVCaptureDevicePosition currentCameraPosition = [videoCamera cameraPosition];
    
    if (currentCameraPosition != AVCaptureDevicePositionBack) {
        isUsingFrontFacingCamera = TRUE;
    }
    
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];

//    NSLog(@"Face Detector %@", [self.faceDetector description]);
//    NSLog(@"converted Image %@", [convertedImage description]);
    NSArray *features = [self.faceDetector featuresInImage:convertedImage options:imageOptions];
    
    __unsafe_unretained FaceDetectionViewController *weakSelf = self;
    
    if (features.count >= requiredFaces) { 
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(facesDetected:)]) {
                [weakSelf.delegate facesDetected:features.count];
            }
        });
    }
    
    // Get the clean aperture.
    // The clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
//    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
//    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
//    [self GPUVCWillOutputFeatures:features forClap:clap andOrientation:curDeviceOrientation];
    
    faceThinking = FALSE;
}

//- (void)GPUVCWillOutputFeatures:(NSArray*)featureArray forClap:(CGRect)clap
//                 andOrientation:(UIDeviceOrientation)curDeviceOrientation {
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        CGRect previewBox = self.view.frame;
//	
//        if (featureArray == nil && faceView) {
//            [faceView removeFromSuperview];
//            faceView = nil;
//        }
//        
//        if (featureArray.count > 0) {
//            for (CIFaceFeature *faceFeature in featureArray) {
//                
//                // Find the correct position for the square layer within the previewLayer
//                // the feature box originates in the bottom left of the video frame.
//                // (Bottom right if mirroring is turned on)
//                
////                NSLog(@"%@", NSStringFromCGRect([faceFeature bounds]));
//                
//                // Update face bounds for iOS Coordinate System
//                CGRect faceRect = [faceFeature bounds];
//                
//                // Flip preview width and height
//                CGFloat temp = faceRect.size.width;
//                faceRect.size.width = faceRect.size.height;
//                faceRect.size.height = temp;
//                temp = faceRect.origin.x;
//                faceRect.origin.x = faceRect.origin.y;
//                faceRect.origin.y = temp;
//                
//                // Scale coordinates so they fit in the preview box, which may be scaled
//                CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
//                CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
//                faceRect.size.width *= widthScaleBy;
//                faceRect.size.height *= heightScaleBy;
//                faceRect.origin.x *= widthScaleBy;
//                faceRect.origin.y *= heightScaleBy;
//                
//                faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
//                
//                if (faceView) {
//                    [faceView removeFromSuperview];
//                    faceView =  nil;
//                }
//                
//                // Create a UIView using the bounds of the face
//                faceView = [[UIView alloc] initWithFrame:faceRect];
//                
//                // Add a border around the newly created UIView
//                faceView.layer.borderWidth = 1;
//                faceView.layer.borderColor = [[UIColor redColor] CGColor];
//                
//                // Add the new view to create a box around the face
//                [self.view addSubview:faceView];
//            }
//        } else {
//            [faceView removeFromSuperview];
//        }
//        
//    });
//}

@end
