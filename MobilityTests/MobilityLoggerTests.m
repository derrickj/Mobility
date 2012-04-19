//
//  MobilityLoggerTests.m
//  Mobility
//
//  Created by Derrick Jones on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MobilityLoggerTests.h"
#import <CoreLocation/CoreLocation.h>

@implementation MobilityLoggerTests

@synthesize logger;
- (void)setUp {
    self.logger = [[[MobilityLogger alloc] init] autorelease];
}
- (void)tearDown {
    self.logger = nil;
}

- (void)testUUIDGeneration {
    STAssertNotNil([MobilityLogger generateRandomUUID], @"UUID should NOT be nil");
    STAssertEquals([[MobilityLogger generateRandomUUID] length], (NSUInteger)36, @"UUID should be 36 characters long");
}

- (void)testLocationLogging {
    CLLocation *location  = [[CLLocation alloc] initWithLatitude:1.10 longitude:3.30];
    
    STAssertTrue([self.logger didStoreLocation:location], @"Logger Should Successfully store a given location");
    [location release];
    
}

@end
