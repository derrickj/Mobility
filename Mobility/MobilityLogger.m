//
//  MobilityLogger.m
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MobilityLogger.h"
#import "DataPoint.h"

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



- (NSString *)jsonRepresentationForDataPoints:(NSArray *)points {
    NSMutableArray *dataPointList = [NSMutableArray array];
    for (DataPoint *d in points) {
        NSLog(@"datapoint: %@", d.latitude);
        NSMutableDictionary *packet = [NSMutableDictionary dictionary];
        NSMutableDictionary *location = [NSMutableDictionary dictionary];
        NSDate *date = d.timestamp;
        NSTimeInterval timeSinceEpoch = [date timeIntervalSince1970];
        NSLog(@"timeinterval: %f", timeSinceEpoch);
        [packet setValue:[NSNumber numberWithDouble:timeSinceEpoch] forKey:@"time"];
        [packet setValue:@"America/LosAngeles" forKey:@"timezone"]; //FIXME: don't use hardcoded timezone
        
        [location setValue:d.latitude forKey:@"latitude"];
        [location setValue:d.longitude forKey:@"longitude"];
        [location setValue:d.accuracy forKey:@"accuracy"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        NSLog(@"Date format: %@", [dateFormatter stringFromDate:date]);
        [location setValue:[dateFormatter stringFromDate:date] forKey:@"timestamp"];
        [dateFormatter release];
        
        [packet setValue:location forKey:@"location"];
        
        [dataPointList addObject:packet];
    }
    NSLog(@"valid Json: %d", [NSJSONSerialization isValidJSONObject:dataPointList]);
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataPointList options:0 error:&error];
    if (error) {
        NSLog(@"derror: %@", error);
    }
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSLog(@"SJONS data: %@", JSONString);
    return [JSONString autorelease];
}

- (NSString *)jsonRepresentationForDB {
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"DataPoint"];
    NSError *error = nil;
    NSArray *rawDataPoints = [self.managedObjectContext executeFetchRequest:fetchReq error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return [self jsonRepresentationForDataPoints:rawDataPoints];
}

#pragma mark - CLLocation Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location manager failed: %@", error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    //FIXME: Log using CoreData
//    NSLog(@"Got location update: %@, with Acceleromter data: %@", newLocation, [motionManager accelerometerData]);
//    
//    NSEntityDescription *entity = [[self.managedObjectModel entitiesByName] valueForKey:@"DataPoint"];
//
//    DataPoint *dataPoint = [[DataPoint alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
//    if (dataPoint == nil)
//        abort();
//
//    dataPoint.latitude = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
//    dataPoint.longitude = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
//    dataPoint.accuracy = [NSNumber numberWithDouble:newLocation.horizontalAccuracy];
//    dataPoint.timestamp = newLocation.timestamp;
//    [dataPoint release];

    NSEntityDescription *entity = [NSEntityDescription entityForName:SensorDataEntity inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *sensorData = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];

    // set accelerometer data
    entity = [NSEntityDescription entityForName:AccelData inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *accel = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    CMAccelerometerData *caData = [motionManager accelerometerData];
    CMAcceleration acceleration = [caData acceleration];
    [accel setValue:[NSNumber numberWithDouble:acceleration.x] forKey:@"x"];
    [accel setValue:[NSNumber numberWithDouble:acceleration.y] forKey:@"y"];
    [accel setValue:[NSNumber numberWithDouble:acceleration.z] forKey:@"z"];
    [sensorData setValue:accel forKey:@"accel_data"];
    [accel release];


    // set location data
    entity = [NSEntityDescription entityForName:LocationEntity inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *location = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    [location setValue:[NSNumber numberWithFloat:newLocation.coordinate.latitude] forKey:@"latitude"];
    [location setValue:[NSNumber numberWithFloat:newLocation.coordinate.longitude] forKey:@"longitude"];
    [location setValue:[NSNumber numberWithFloat:newLocation.horizontalAccuracy] forKey:@"accuracy"];
    [location setValue:@"iOSCoreLocation" forKey:@"provider"];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    [location setValue:[NSNumber numberWithDouble:timeInterval] forKey:@"time"]; // should be time seconds since unix epoch
    [location setValue:@"PST" forKey:@"timezone"]; //FIXME: get proper timezone
    [sensorData setValue:location forKey:@"location"];
    [location release];
    
    // location_status
    [sensorData setValue:@"valid" forKey:@"location_status"]; //FIXME: proper status

    // set subtype
    [sensorData setValue:@"sensor_data" forKey:@"subtype"];

    // set mode
    [sensorData setValue:@"still" forKey:@"mode"]; //FIXME:  this is not always right. Don't want to implement activity classification on-device

    //set speed
    [sensorData setValue:[NSNumber numberWithDouble:[newLocation speed]] forKey:@"speed"];

    //set wifi_data (Later, unless server requires it)

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    [sensorData release];
    if (error) {
        NSLog(@"error saving data point: %@", error);
        abort();
    }
}
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
