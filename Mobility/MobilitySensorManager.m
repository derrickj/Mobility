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
@synthesize loggingLocation, logger, loggingAccelerometer;

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    // store the location. (maybe add an adaptive algorithm to improve power consumption later)
    [self.logger didStoreLocation:newLocation withProvider:[self provider]];

    // grab accelerometer data while (we're running in the background)
    // need about 25 points, over 1 seconds, let's see if we can get that.
    for (int i = 0; i < 25; i++){
        [self.logger didStoreAccelerometerData:[motionManager accelerometerData]];
    }
    
    // get current battery state and ask logger to save it
    // note make sure device.batteryLoggingEnable = YES;
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [self.logger didLogCurrentBatteryLevel:([[UIDevice currentDevice] batteryLevel] * 100)];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"Location Manager failed with error: %@", [error localizedDescription]);
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

- (void)setLoggingAccelerometer:(BOOL)newLoggingPreference {
    loggingAccelerometer = newLoggingPreference;
    if (newLoggingPreference == NO) {
        [motionManager stopAccelerometerUpdates];
    } else {
        [motionManager startAccelerometerUpdates];
    }
}

- (NSString *)provider {
    CLLocationAccuracy acc = locationManager.desiredAccuracy;
    NSString *defaultBase = @"iOS-";
    NSString *accuracy = @"";

    if (acc == kCLLocationAccuracyBestForNavigation) {
        accuracy = @"kCLLocationAccuracyBestForNavigation";
    } else if (acc == kCLLocationAccuracyBest) {
        accuracy = @"kCLLocationAccuracyBest";
    } else if (acc == kCLLocationAccuracyNearestTenMeters) {
        accuracy = @"kCLLocationAccuracyNearestTenMeters";
    } else if (acc == kCLLocationAccuracyHundredMeters) {
        accuracy = @"kCLLocationAccuracyHundredMeters";
    } else if (acc == kCLLocationAccuracyKilometer) {
        accuracy = @"kCLLocationAccuracyKilometer";
    } else if (acc == kCLLocationAccuracyThreeKilometers){
        accuracy = @"kCLLocationAccuracyThreeKilometers";
    }
    return [[[defaultBase stringByAppendingString:accuracy] retain] autorelease];
}
#pragma mark - Memory Management
- (id) init {
    if (self = [super init]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.purpose = @"Mobility logs your location periodically to upload to an Ohmage server later";

        locationManager.distanceFilter = 10;// measured in meters
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

        motionManager = [[CMMotionManager alloc] init];
        
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    return self;
}
- (void) dealloc {
    [locationManager release];
    [motionManager release];
    self.logger = nil;
    [super dealloc];
}
@end
