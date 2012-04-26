//
//  MobilitySensorManager.h
//  Mobility
//
//  Created by Derrick Jones on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobilityLogger.h"
#import <CoreLocation/CLLocationManager.h>
#import <CoreMotion/CMMotionManager.h>

@interface MobilitySensorManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CMMotionManager *motionManager;

}

#pragma mark - API To callers
@property (nonatomic, assign, getter=isLoggingLocation) BOOL loggingLocation;
// callers can check if location logging is on or off. The sensor manager should intelligently manage the actual use of
// location services when on, but the USER may want to turn of location logging manually for batter reasons etc.
@property (nonatomic, assign, getter=isLoggingAccelerometer) BOOL loggingAccelerometer;
@property (nonatomic, retain) MobilityLogger *logger; // Whoever instatiates this sensor manager is responsible for supplying the logger
@end
