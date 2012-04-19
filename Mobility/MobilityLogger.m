//
//  MobilityLogger.m
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MobilityLogger.h"
#import "Location.h"

// entity names defined here to avoid typos from repeatingly typing literal nsstring
NSString *AccelData = @"AccelData";
NSString *LocationEntity = @"Location";
NSString *ScanEntity = @"Scan";
NSString *WifiDataEntity = @"WifiData";
NSString *SensorDataEntity = @"SensorData";

@implementation MobilityLogger

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;



#pragma mark - Memory Management

- (void)dealloc {
    [_managedObjectContext release];
    [_managedObjectModel release];
    [super dealloc];
}

#pragma mark - API to callers
// API for Storing Data
// store location
- (BOOL) didStoreLocation: (CLLocation *)location {
    // create new location object for database
    Location *l = [NSEntityDescription insertNewObjectForEntityForName:LocationEntity inManagedObjectContext:self.managedObjectContext];
    // set values
    l.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    l.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];

    NSTimeInterval t = [location.timestamp timeIntervalSince1970];
    l.time = [NSNumber numberWithDouble:t]; // timeinterval is typedef'ed to double
    l.timezone = @"GMT"; // NSDate's timeIntervalSince1970 method is in GMT
    l.accuracy = [NSNumber numberWithDouble:location.horizontalAccuracy];
    l.provider = @"iOS Core Location";

    // save the managed object context (ie commit to database)
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        abort(); // should only do this in testing, not for shipping code
    }
    return error == nil;
}
// store accel data
- (BOOL) didStoreAccelerometerData:(CMAccelerometerData *)accelData {return  NO; }
// store wifi data FIXME: add api for this (lower priority)

// Data Point Retreival: A Classifier would probably want to use this, or the uploader
- (NSArray *)getAllStoredLocationPoints { return nil; } // return of CLLocation objects
- (NSArray *)getAllStoredAccelerometerPoints { return nil; }// return list of CMAccelerometerData



#pragma mark - helpers
+ (NSString *)generateRandomUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef cfString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return [(NSString *)cfString autorelease];;
}

#pragma mark - Core Data Stack
// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreDataUtilityTutorial/Articles/05_createStack.html
- (NSManagedObjectModel *) managedObjectModel {    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    // no need to specify url of model definition. this method searches for it automagically :)
    // could be problematic if there's more than one model def. Should be fine.
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return  _managedObjectModel;
}

+ (NSString *) documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext !=nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    [coordinator release];
    
    NSURL *storeURL = [NSURL fileURLWithPath:[[MobilityLogger documentsDirectory] stringByAppendingPathComponent:@"mobility.sqlite"]];
    NSError *error = nil;
    NSPersistentStore *dataStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (dataStore == nil) {
        // FIXME: never programmatically quit in shipping code. Inform user there's an unrecoverable error
        NSLog(@"error with persistent store: %@", [error localizedDescription]);
        abort();
    }
    return _managedObjectContext;
}

@end
