//
//  AccelData+MJSONSerializable.m
//  Mobility
//
//  Created by Derrick Jones on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccelData+MJSONSerializable.h"

@implementation AccelData (MJSONSerializable)
- (id)serializableRepresentation {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:self.x forKey:@"x"];
    [d setValue:self.y forKey:@"y"];
    [d setValue:self.z forKey:@"z"];
    [d setValue:self.timestamp forKey:@"timestamp"];
    return [d autorelease];
}
@end
