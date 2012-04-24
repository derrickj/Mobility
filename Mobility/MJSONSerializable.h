//
//  MJSONSerializable.h
//  Mobility
//
//  Created by Derrick Jones on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  Objects that conform to this protocol should be able to be converted
//  to NSJSON objects. Since the built-in JSON conversion is finicky,
//  (cannot convert non-Foundation objects, or it will fail) this will
//  allow custom classes to provide a compatible representation of itsself
//  which is serialiable
#import <Foundation/Foundation.h>

@protocol MJSONSerializable <NSObject>
// returns an object which should always be capable of beign converted to a JSON Object
// +[NSJSONSerialization isValidJSONObject:[id<MJSONSerializable> serializableRepresentation]] should always return YES
- (id)serializableRepresentation;
@end
