//
//  Location+HandWrittenMethods.h
//  Mobility
//
//  Created by Derrick Jones on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import <CoreLocation/CoreLocation.h>
@interface Location (HandWrittenMethods)
- (void)setFieldsFromCLLocation:(CLLocation *)location withProvider:(NSString *)theProvider;
@end
