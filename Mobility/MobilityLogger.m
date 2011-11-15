//
//  MobilityLogger.m
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MobilityLogger.h"

@implementation MobilityLogger

#pragma mark - Memory Management
- (id)init{
    if (self = [super init]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.purpose = @"Mobility logs your location periodically to upload to an Ohmage server later";
        locationManager.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [locationManager release];
}

#pragma mark - API to callers
- (void)startLoggingLocation {
    [locationManager startUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];
    NSLog(@"Started updating location");
}

- (void)stopLoggingLocation {
    NSLog(@"Stopped updating location");
    [locationManager stopUpdatingLocation];
    [locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark - CLLocation Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location manager failed: %@", error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //FIXME: Log using CoreData
    NSLog(@"Got location update: %@", newLocation);
}

@end
