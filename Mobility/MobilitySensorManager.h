//
//  MobilitySensorManager.h
//  Mobility
//
//  Created by Derrick Jones on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobilitySensorManager : NSObject {
    // add location manager, etc
    //        locationManager.purpose = @"Mobility logs your location periodically to upload to an Ohmage server later";
}


// turn on/off location logging //FIXME: make locationLogging a property (low priority)
- (void)startLoggingLocation;
- (void)stopLoggingLocation;
@end
