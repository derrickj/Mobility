//
//  MobilityLoggerTests.m
//  Mobility
//
//  Created by Derrick Jones on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MobilityLoggerTests.h"
#import "DataPoint.h"

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
}

- (void)testJSONRepresentationForDataPoints {
    NSManagedObjectContext *moc = self.logger.managedObjectContext;
    NSEntityDescription *entity = [[self.logger.managedObjectModel entitiesByName] valueForKey:@"DataPoint"];
    DataPoint *p = [[DataPoint alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    p.longitude = [NSNumber numberWithDouble:12345.67];
    p.latitude = [NSNumber numberWithDouble:543.21];
    NSArray *list = [NSArray arrayWithObject:p];
    
    NSString *result = [self.logger jsonRepresentationForDataPoints:list];
    
    STAssertNotNil(result, @"json representation should not be nil");
    
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    STAssertNil(error, @"Getting an object from JSON data should succeed");
    STAssertEquals([object count], (NSUInteger)1, @"array length should be 1");
    id location = [[object objectAtIndex:0] valueForKey:@"location"];
    STAssertEquals([[location valueForKey:@"longitude"] doubleValue], [p.longitude doubleValue], @"location's longitude should be the same");
    STAssertEquals([[location valueForKey:@"latitude"] doubleValue], [p.latitude doubleValue], @"latitudes should be the same");

}

@end
