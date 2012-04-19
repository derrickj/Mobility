//
//  MobilityLogger.h
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//  MobilityLogger's responsibility is to interact with the persistent storage (Core Data)
//  It will provide an Interface for storing sensor data, and retreiving the data, irrespective of
//  internal storage/schema choices.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreData/CoreData.h>

@interface MobilityLogger : NSObject {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
}

// API for Storing Data
// store location
- (BOOL) didStoreLocation: (CLLocation *)location;
// store accel data
- (BOOL) didStoreAccelerometerData:(CMAccelerometerData *)accelData;
// store wifi data FIXME: add api for this (lower priority)

// Data Point Retreival: A Classifier would probably want to use this, or the uploader
- (NSArray *)getAllStoredLocationPoints; // return of CLLocation objects
- (NSArray *)getAllStoredAccelerometerPoints; // return list of CMAccelerometerData


// Private properties, really here to support lazy initializtion etc
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;

@end
