//
//  CameraChooser.h
//  CameraChooser
//
//  Created by Valentin Kalchev on 31/07/2014.
//  Copyright (c) 2014 Triggertrap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CableSelector : NSObject

/*!
 * Use to get an array of all camera manufacturers
 */
- (NSArray *)cameraManufacturers;

/*!
 * Use to get an array of all camera models for specific camera manufacturer
 */
- (NSArray *)cameraModelsForManufacturer:(NSString *)cameraManufacturer;

/*!
 * Use to get cable necessary for specific camera manufacturer and model
 */
- (NSString *)cableForCameraManufacturer:(NSString *)cameraManufacturer withModel:(NSString *)cameraModel;

/*!
 * Use to url to Triggertrap store with specific cable
 */
- (NSString *)urlForCable:(NSString *)cable;

@end

