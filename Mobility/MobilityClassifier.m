//
//  MobilityClassifier.m
//  Mobility
//
//  Created by Derrick Jones on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  This class must get data points from MobilityLogger analyze them,
//  and finally decide wether the activity is for the data points
//  it's output should be packets in the form the Ohmage expects

#import "MobilityClassifier.h"
#import "Location+MJSONSerializable.h"
#import "AccelData+MJSONSerializable.h"

@implementation MobilityClassifier
@synthesize logger;

#pragma mark - API to Callers -
- (NSString *)modeOnlyJSONStringForDataPoints {
    // get location points from database
    NSArray *locationDataPoints = [self.logger storedLocationPoints];


    // convert to datapoints to dictionary representations
    NSMutableArray *serializableDataPoints = [[NSMutableArray alloc] init];
    for (Location *location in locationDataPoints) {
        // this packet should follow the mode_only format
        NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
        [packet setValue:location.uuid forKey:@"id"];
        [packet setValue:location.time forKey:@"time"];
        [packet setValue:location.timezone forKey:@"timezone"];
        [packet setValue:@"valid" forKey:@"location_status"];
        [packet setValue:[location serializableRepresentation] forKey:@"location"];
        [packet setValue:@"mode_only" forKey:@"subtype"];

        // Always guess mobility mode now, becasue we assume server will get it right
        [packet setValue:kMobilityStill forKey:@"mode"];
        [serializableDataPoints addObject:packet];
        [packet release];
    }


    // convert to json data return string
    NSError *error = nil;
    NSString *jsonString = nil;
    NSJSONWritingOptions opts = 0; // no options will produce the most compact json
#ifdef DEBUG
    opts = NSJSONWritingPrettyPrinted;
#endif
    NSData *jsonBytes = [NSJSONSerialization dataWithJSONObject:serializableDataPoints options:opts error:&error];
    if (error) {
        NSLog(@"Failed to convert Data Points to JSON: %@", [error localizedDescription]);
#ifdef DEBUG
        abort();
#endif
    } else {
        jsonString = [[NSString alloc] initWithData:jsonBytes encoding:NSUTF8StringEncoding];
    }


    return [jsonString autorelease];
}

- (NSString *)sensorDataJSONStringForDataPoints {
    // get all every location point, find accel point that goes with it, put in packet
    NSArray *locationPoints = [self.logger storedLocationPoints];
    
    NSMutableArray *serializableDataPoints = [[NSMutableArray alloc] init];
    Location *previousLocation = nil; // keep track of previous location for accel date range queries
    for (Location *location in locationPoints) {
        // dates stored as milliseconds since unix epoch in Location
        NSDate *from = nil;
        if (previousLocation) {
            from = [NSDate dateWithTimeIntervalSince1970:[previousLocation.time doubleValue]/1000.0];
        }
        NSDate *to = [NSDate dateWithTimeIntervalSince1970:[location.time doubleValue]/1000.0];
        NSMutableArray *serializabbleAccelPoints = [[NSMutableArray alloc] init];
        for (AccelData *a in [self.logger storedAccelerometerPointsFromDate:from toDate:to]) {
            [NSJSONSerialization isValidJSONObject:[a serializableRepresentation]];
            [serializabbleAccelPoints addObject:[a serializableRepresentation]];
        }
        // build up Sensor Data Packet
        NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];

        [packet setValue:location.uuid forKey:@"id"];
        [packet setValue:location.time forKey:@"time"];
        [packet setValue:location.timezone forKey:@"timezone"];
        [packet setValue:@"valid" forKey:@"location_status"];
        [packet setValue:[location serializableRepresentation] forKey:@"location"];
        [packet setValue:@"sensor_data" forKey:@"subtype"];
        [packet setValue:kMobilityStill forKey:@"mode"];
        [packet setValue:location.speed forKey:@"speed"];
        
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
        // data object requires "mode" in addition ot the top level packet, just set it the same
        [dataDict setValue:[packet valueForKey:@"mode"] forKey:@"mode"];
        NSDictionary *wifi_data = [NSDictionary
                                   dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedLongLong:[MobilityLogger millisecondsSinceUnixEpoch]],@"time",
                                   @"GMT", @"timezone",
                                   [NSArray array], @"scan",
                                   nil];

        [dataDict setValue:location.speed forKey:@"speed"];
        [dataDict setValue:serializabbleAccelPoints forKey:@"accel_data"];
        [dataDict setValue:wifi_data forKey:@"wifi_data"]; // Set empty array for now.


        [packet setValue:dataDict forKey:@"data"];
        [dataDict release];
        [serializabbleAccelPoints release]; // this get reassigned every iteration of Location Points
        [serializableDataPoints addObject:packet];
        [packet release];
        previousLocation = location;
    }



    NSString *jsonString = nil;
    NSError *error = nil;
    NSJSONWritingOptions opts = 0;

#ifdef DEBUG
    opts = NSJSONWritingPrettyPrinted;
#endif

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serializableDataPoints options:opts error:&error];
    [serializableDataPoints release];
    if (error) {
        NSLog(@"Error parsing json: %@", [error localizedDescription]);
#ifdef DEBUG
        abort();
#endif
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }


    return [jsonString autorelease];
}
#pragma mark -
- (unsigned long long)millisecondsSinceUnixEpoch {
    // timeIntervalSince1970 is in seconds, server expects milliseconds, no decimal
    unsigned long long t = (unsigned long long)([[NSDate date] timeIntervalSince1970] * 1000);
    return t;
}

#pragma mark - Constants
NSString * const kMobilityStill = @"still";
NSString * const kMobilityWalk = @"walk";
NSString * const kMobilityRun = @"run";
NSString * const kMobilityBike = @"bike";
NSString * const kMobiltyDrive = @"drive";
@end
