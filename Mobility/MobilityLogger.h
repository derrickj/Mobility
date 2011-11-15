//
//  MobilityLogger.h
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface MobilityLogger : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *manager;
}

- (void)startLoggingLocation;
- (void)stopLoggingLocation;
@end
