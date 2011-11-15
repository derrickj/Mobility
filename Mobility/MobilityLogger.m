//
//  MobilityLogger.m
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MobilityLogger.h"

@implementation MobilityLogger
- (id)init{
    if (self = [super init]) {
        manager = [[CLLocationManager alloc] init];
        manager.purpose = @"Mobility logs your location periodically to upload to an Ohmage server later";
    }
    return self;
}

- (void)dealloc {
    [manager release];
}
@end
