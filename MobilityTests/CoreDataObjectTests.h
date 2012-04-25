//
//  CoreDataObjectTests.h
//  Mobility
//
//  Created by Derrick Jones on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  This will test all the NSManagedObject subclasses
//  they will share this file because many of them require a managed object
//  context, that I don't feel like setting up every time for each test.
//  trying not to waste too much effort, with little gain

#import <SenTestingKit/SenTestingKit.h>
#import "MobilityLogger.h"
#import "Location.h"
#import "Location+MJSONSerializable.h"
#import "AccelData+MJSONSerializable.h"

@interface CoreDataObjectTests : SenTestCase

@property (nonatomic, retain) MobilityLogger *logger; // this will be used to get a context
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) AccelData *accel;
@end
