//
//  Location+MJSONSerializable.h
//  Mobility
//
//  Created by Derrick Jones on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  THis Objective-C category makes Location object conform to our own
//  MJSONSerializable protocol. This should assist in converting the db/core data
//  managed object representation into JSON objects for the server.

#import "Location.h"
#import "MJSONSerializable.h"
@interface Location (MJSONSerializable) <MJSONSerializable>

@end
