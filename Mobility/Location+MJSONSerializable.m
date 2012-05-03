//
//  Location+MJSONSerializable.m
//  Mobility
//
//  Created by Derrick Jones on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Location+MJSONSerializable.h"

@implementation Location (MJSONSerializable)
- (id)serializableRepresentation {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:self.accuracy forKey:@"accuracy"];
    [d setValue:self.latitude forKey:@"latitude"];
    [d setValue:self.longitude forKey:@"longitude"];
    [d setValue:self.provider forKey:@"provider"];
    [d setValue:self.time forKey:@"time"];
    [d setValue:self.timezone forKey:@"timezone"];

    // omitting self.uuid becasue Ohmage server doesn't expect it inside location object.
    // classifier uses the uuid to make it's own packets
    // omitting self.speed as well, because it's expected outside of the location object by server
    return [d autorelease];
}
@end
