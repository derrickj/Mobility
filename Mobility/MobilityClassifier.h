//
//  MobilityClassifier.h
//  Mobility
//
//  Created by Derrick Jones on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  Classifier Will retreive data points from MobilityLogger, perform necessary calculations
//  and output JSON strings suitable for upload to Ohmage Server, when the appropriate method is called of course

#import <Foundation/Foundation.h>

@interface MobilityClassifier : NSObject

#pragma mark - API to Callers
- (NSString *)modeOnlyJSONStringForDataPoints;
- (NSString *)sensorDataJSONStringForDataPoints;


#pragma mark - Constants
// http://stackoverflow.com/questions/538996/constants-in-objective-c
extern NSString * const kMobilityStill;
extern NSString * const kMobilityWalk;
extern NSString * const kMobilityRun;
extern NSString * const kMobilityBike;
extern NSString * const kMobiltyDrive;
@end
