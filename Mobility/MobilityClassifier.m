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

@implementation MobilityClassifier
#pragma mark - API to Callers -
- (NSString *)modeOnlyJSONStringForDataPoints {
    //FIXME: Implement
    // get location points from database
    // convert to datapoints to dictionary representations
    // include fake classification, don't classify for now, just "guess" the mode
    // convert to json data return string
    return nil;
}

- (NSString *)sensorDataJSONStringForDataPoints { return nil; } //FIXME: Implement


#pragma mark - Constants
NSString * const kMobilityStill = @"still";
NSString * const kMobilityWalk = @"walk";
NSString * const kMobilityRun = @"run";
NSString * const kMobilityBike = @"bike";
NSString * const kMobiltyDrive = @"drive";
@end
