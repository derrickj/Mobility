//
//  MobilityLoggerTests.m
//  Mobility
//
//  Created by Derrick Jones on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MobilityLoggerTests.h"
#import "MobilityLogger.h"
@implementation MobilityLoggerTests

- (void)testUUIDGeneration {
    STAssertNotNil([MobilityLogger generateRandomUUID], @"UUID should NOT be nil");
}

@end
