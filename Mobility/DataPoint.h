//
//  DataPoint.h
//  Mobility
//
//  Created by Derrick Jones on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataPoint : NSManagedObject

@property (nonatomic, retain) NSString * accuracy;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * speed;
@property (nonatomic, retain) NSDate * timestamp;

@end
