//
//  CoreDataObjectTests.m
//  Mobility
//
//  Created by Derrick Jones on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// http://stackoverflow.com/questions/2842258/unit-testing-model-classes-that-inherit-from-nsmanagedobject

#import "CoreDataObjectTests.h"

@implementation CoreDataObjectTests
@synthesize logger, location;

- (void)setUp {
    self.logger = [[MobilityLogger alloc] init];
    
    // location
    self.location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.logger.managedObjectContext];
    self.location.latitude = [NSNumber numberWithDouble:1.0];
    self.location.longitude = self.location.latitude;
    self.location.provider = @"blah";
    self.location.accuracy = self.location.longitude;
    self.location.time = [NSNumber numberWithInt:23];
    self.location.timezone = @"blahtimezone";
}

- (void)tearDown {
    [self.logger.managedObjectContext rollback]; // remove any insertions etc not committed
    // (we dont' want to commit any of the objects added for testing purposes anyway)
    self.logger = nil;
    self.location = nil;
}

- (void)testLocationHasValidJSONSerialization {
    STAssertNotNil([self.location serializableRepresentation],
                   @"Location should conform to JSON Serialization protocol");
    STAssertTrue([NSJSONSerialization isValidJSONObject:[self.location serializableRepresentation]],
                 @"Location should have a valid json serialization representation");
}
@end
