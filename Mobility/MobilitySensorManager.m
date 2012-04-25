//
//  MobilitySensorManager.m
//  Mobility
//
//  Created by Derrick Jones on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  This class is responsible for managing all the sensors and storing
//  the data collecting them
#import "MobilitySensorManager.h"

@implementation MobilitySensorManager
@synthesize loggingLocation, logger;

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    // store the location. (maybe add an adaptive algorithm to improve power consumption later)
    [self.logger didStoreLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"Location Manger failed with error: %@", [error localizedDescription]);
    abort();
#endif
}

#pragma mark -
- (void)setLoggingLocation:(BOOL)newLoggingPreference {
    loggingLocation = newLoggingPreference;
    if (newLoggingPreference == NO ) {
        [locationManager stopUpdatingLocation];
        [locationManager stopMonitoringSignificantLocationChanges];
        NSLog(@"lstopping location updates");
    } else {
        [locationManager startUpdatingLocation];
        NSLog(@"starting location updating");
    }
}

#pragma mark - Memory Management
- (id) init {
    if (self = [super init]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.purpose = @"Mobility logs your location periodically to upload to an Ohmage server later";
    }
    return self;
}
- (void) dealloc {
    [locationManager release];
    self.logger = nil;
    [super dealloc];
}
@end
