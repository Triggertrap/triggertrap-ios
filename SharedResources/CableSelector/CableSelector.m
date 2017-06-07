//
//  CableSelector.h
//  CableSelector
//
//  Created by Valentin Kalchev on 31/07/2014.
//  Copyright (c) 2014 Triggertrap. All rights reserved.
//

#import "CableSelector.h"

NSString *const kJSONCameraChooserName = @"CameraChooser";
NSString *const kJSONStoreLinksName = @"StoreLinks";

@interface CableSelector ()
{
    NSDictionary *cameraDictionary;
    NSDictionary *storeURLDictionary;
    
    NSArray *cameraManufacturers;
}
@end

@implementation CableSelector

#pragma mark - Lifecycle
- (instancetype)init {
   
    if (self = [super init]) {

        NSString *filePath = [[NSBundle mainBundle] pathForResource:kJSONCameraChooserName ofType:@"JSON"];
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        
        cameraDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSString *storeLinksFilePath = [[NSBundle mainBundle] pathForResource:kJSONStoreLinksName ofType:@"JSON"];
        NSData *storeLinksData = [NSData dataWithContentsOfFile:storeLinksFilePath];
        
        storeURLDictionary = [NSJSONSerialization JSONObjectWithData:storeLinksData options:kNilOptions error:nil];
    }
    
    return self;
}

#pragma mark - Public

//Camera manufacturers
- (NSArray *)cameraManufacturers {
    
    //Sort array of manufactuers
    cameraManufacturers = [[cameraDictionary allKeys] sortedArrayUsingComparator: ^(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2];
    }];
    
    return cameraManufacturers;
}

//Camera models for manufacturer
- (NSArray *)cameraModelsForManufacturer:(NSString *)cameraManufacturer {
    NSDictionary *models = [cameraDictionary objectForKey:cameraManufacturer];
    
    NSArray *cameraModels = [[models allKeys] sortedArrayUsingComparator: ^(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2];
    }];
    
    return cameraModels;
}

//Values from pickers fro camera manufacturer and camera model
- (NSString *)cableForCameraManufacturer:(NSString *)cameraManufacturer withModel:(NSString *)cameraModel {
    
    NSDictionary *models = [cameraDictionary objectForKey:cameraManufacturer];
    
    NSArray *cabel = [models objectForKey:cameraModel];

    return cabel[0];
}

//Get url for cable
- (NSString *)urlForCable:(NSString *)cable {
    
    return [storeURLDictionary objectForKey:cable][0];
}

@end
