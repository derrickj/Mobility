//
//  MobilityLogger.m
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MobilityLogger.h"


@implementation MobilityLogger

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;



#pragma mark - Memory Management
- (id)init{
    if (self = [super init]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.purpose = @"Mobility logs your location periodically to upload to an Ohmage server later";
        locationManager.delegate = self;

        motionManager = [[CMMotionManager alloc] init];
        
    }
    return self;
}

- (void)dealloc {
    [locationManager release];
    [motionManager release];

    [_managedObjectContext release];
    [_managedObjectModel release];
    [super dealloc];
}

#pragma mark - API to callers
- (void)startLoggingLocation {
    [locationManager startUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];

    //FIXME: decouple accelerometer updating?
    [motionManager startAccelerometerUpdates];
    NSLog(@"Started updating location");
}

- (void)stopLoggingLocation {
    NSLog(@"Stopped updating location");
    [locationManager stopUpdatingLocation];
    [locationManager stopMonitoringSignificantLocationChanges];

    //FIXME: decouple accelerometer updating?
    [motionManager stopAccelerometerUpdates];
}

- (NSString *)jsonRepresentationForDB {
    NSMutableArray *dataPointList = [NSMutableArray array];
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"DataPoint"];
    NSError *error = nil;
    NSArray *rawDataPoints = [self.managedObjectContext executeFetchRequest:fetchReq error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    for (NSManagedObject *d in rawDataPoints) {
        NSLog(@"datapoint: %@", [d valueForKey:@"latitude"]);
        NSMutableDictionary *packet = [NSMutableDictionary dictionary];
        NSMutableDictionary *location = [NSMutableDictionary dictionary];
        NSDate *date = (NSDate *)[d valueForKey:@"timestamp"];
        int timeInMillis = [date timeIntervalSince1970] * 1000;
        
        
        
        [packet setValue:[NSNumber numberWithInt:timeInMillis] forKey:@"time"];
        [packet setValue:@"America/LosAngeles" forKey:@"timezone"]; //FIXME: don't use hardcoded timezone
        
        [location setValue:[d valueForKey:@"latitude"]forKey:@"latitude"];
        [location setValue:[d valueForKey:@"longitude"] forKey:@"longitude"];
        [location setValue:[d valueForKey:@"accuracy"] forKey:@"accuracy"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        NSLog(@"Date format: %@", [dateFormatter stringFromDate:date]);
        [location setValue:[dateFormatter stringFromDate:date] forKey:@"timestamp"];
        [dateFormatter release];
        
        [packet setValue:location forKey:@"location"];
        
        [dataPointList addObject:packet];
    }
    NSLog(@"valid Json: %d", [NSJSONSerialization isValidJSONObject:dataPointList]);
    error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataPointList options:0 error:&error];
    if (error) {
        NSLog(@"derror: %@", error);
    }
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSLog(@"SJONS data: %@", JSONString);
    return [JSONString autorelease];
}

#pragma mark - CLLocation Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location manager failed: %@", error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //FIXME: Log using CoreData
    NSLog(@"Got location update: %@, with Acceleromter data: %@", newLocation, [motionManager accelerometerData]);
    
    NSEntityDescription *entity = [[self.managedObjectModel entitiesByName] valueForKey:@"DataPoint"];

    NSManagedObject *dataPoint = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    if (dataPoint == nil)
        abort();
    [dataPoint setValue:[[NSNumber numberWithDouble:newLocation.coordinate.latitude] stringValue]forKey:@"latitude"];
    [dataPoint setValue:[[NSNumber numberWithDouble:newLocation.coordinate.longitude] stringValue] forKey:@"longitude"];
    [dataPoint setValue:[[NSNumber numberWithDouble:newLocation.horizontalAccuracy] stringValue] forKey:@"accuracy"];
    [dataPoint setValue:newLocation.timestamp forKey:@"timestamp"];
    [dataPoint release];
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"error saving data point: %@", error);
        abort();
    }
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
