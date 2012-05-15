//
//  MobilityLogger.m
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MobilityLogger.h"
#import "Location.h"
#import "Location+HandWrittenMethods.h"
#import "AccelData.h"

// entity names defined here to avoid typos from repeatingly typing literal nsstring
NSString *AccelDataEntity = @"AccelData";
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
    [l setFieldsFromCLLocation:location];

    // save the managed object context (ie commit to database)
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"error for storing location: %@", [error localizedDescription]);
    }
    return error == nil;
}
// store accel data
- (BOOL) didStoreAccelerometerData:(CMAccelerometerData *)accelData {
    NSLog(@"Storing Accel Data: %@", accelData);
    AccelData *a = [NSEntityDescription insertNewObjectForEntityForName:AccelDataEntity
                                                 inManagedObjectContext:self.managedObjectContext];
    a.timestamp = [NSDate date];
    CMAcceleration cma = accelData.acceleration;
    a.x = [NSNumber numberWithDouble:cma.x];
    a.y = [NSNumber numberWithDouble:cma.y];
    a.z = [NSNumber numberWithDouble:cma.z];

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
#ifdef DEBUG
        NSLog(@"AccelError : %@", [error localizedDescription]);
#endif
    }

    return error == nil; // return YES if no error
}

// store wifi data FIXME: add api for this (lower priority)

// Data Point Retreival: A Classifier would probably want to use this, or the uploader
- (NSArray *)storedLocationPoints {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:LocationEntity];
    NSSortDescriptor *sortByTime = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    [fetchReq setSortDescriptors:[NSArray arrayWithObject:sortByTime]];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchReq error:&error];
    if (error) {
        NSLog(@"Error executing fetch request: %@", [error localizedDescription]);
    }
    return [[results retain] autorelease];
}

// return ALL stored accel points
- (NSArray *)storedAccelerometerPoints {
    return [[[self storedAccelerometerPointsFromDate:nil toDate:nil] retain] autorelease];
}

// return stored accel points from earliestdate (inclusive) to latest (exclusive)
// nil earliest places no lower bound on date range, likewise for latest
- (NSArray *)storedAccelerometerPointsFromDate:(NSDate *)earliest toDate:(NSDate *)latest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:AccelDataEntity];
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
   
    NSPredicate *dateRangePredicate = nil;
    if (earliest != nil && latest != nil) {
        dateRangePredicate = [NSPredicate predicateWithFormat:@"(timestamp >= %@) AND (timestamp < %@)", earliest, latest];
    } else if (earliest != nil) {
        dateRangePredicate = [NSPredicate predicateWithFormat:@"timestamp >= %@", earliest];
    } else if (latest != nil) {
        dateRangePredicate = [NSPredicate predicateWithFormat:@"timestamp < %@", latest];
    }
    if (dateRangePredicate) {
        [fetchRequest setPredicate:dateRangePredicate];
    }

    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByDate]];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
#ifdef DEBUG
        NSLog(@"Couldn't fetch Acclerometer points: %@", [error localizedDescription]);
#endif
    }
    return [[results retain] autorelease];
}


#pragma mark - helpers
+ (NSString *)generateRandomUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef cfString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return [(NSString *)cfString autorelease];;
}

+ (unsigned long long)millisecondsSinceUnixEpoch {
    // timeIntervalSince1970 is in seconds, typdefed to double, server expects milliseconds, no decimal point
    return (unsigned long long)([[NSDate date] timeIntervalSince1970] * 1000);
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
    }
    return _managedObjectContext;
}

@end
