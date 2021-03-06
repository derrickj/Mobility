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

#pragma mark - API for Data Point Storage
// store location
- (BOOL) didStoreLocation:(CLLocation *)location;
- (BOOL) didStoreLocation:(CLLocation *)location withProvider:(NSString *)theProvider;
// store accel data
- (BOOL) didStoreAccelerometerData:(CMAccelerometerData *)accelData;
// store wifi data FIXME: add api for this (lower priority)


- (BOOL) didLogCurrentBatteryLevel:(float)currentLevel;

#pragma mark - API for Data Point Retreival
// Data Point Retreival: A Classifier would probably want to use this, or the uploader
- (NSArray *)storedLocationPoints; // return of CLLocation objects
- (NSArray *)storedAccelerometerPoints; // return list of CMAccelerometerData
- (NSArray *)storedAccelerometerPointsFromDate:(NSDate *)earliest toDate:(NSDate *)latest;

+ (unsigned long long)millisecondsSinceUnixEpoch; // Local timezone
+ (NSString *)generateRandomUUID;
#pragma mark -
// Private properties, really here to support lazy initializtion etc
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;

@end
