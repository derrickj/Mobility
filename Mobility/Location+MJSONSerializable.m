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
    [d setValue:self.uuid forKey:@"id"]; // NOTE: use "id" for the key, because that's what Ohmage server expects
    return [d autorelease];
}
@end
