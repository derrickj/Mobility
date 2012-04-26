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

@implementation MobilityClassifier
@synthesize logger;

#pragma mark - API to Callers -
- (NSString *)modeOnlyJSONStringForDataPoints {
    // get location points from database
    NSArray *locationDataPoints = [self.logger getAllStoredLocationPoints];


    // convert to datapoints to dictionary representations
    NSMutableArray *serializableDataPoints = [[NSMutableArray alloc] init];
    for (Location *location in locationDataPoints) {
        // this packet should follow the mode_only format
        NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
        [packet setValue:location.uuid forKey:@"id"];
        // timeIntervalSince1970 is in seconds, server expects milliseconds, no decimal
        unsigned long long t = (unsigned long long)([[NSDate date] timeIntervalSince1970] * 1000);
        [packet setValue:[NSNumber numberWithUnsignedLongLong:t] forKey:@"time"];
        [packet setValue:@"GMT" forKey:@"timezone"]; // NSDate timeIntervalSince1970 is based on GMT
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

- (NSString *)sensorDataJSONStringForDataPoints { return nil; } //FIXME: Implement


#pragma mark - Constants
NSString * const kMobilityStill = @"still";
NSString * const kMobilityWalk = @"walk";
NSString * const kMobilityRun = @"run";
NSString * const kMobilityBike = @"bike";
NSString * const kMobiltyDrive = @"drive";
@end
