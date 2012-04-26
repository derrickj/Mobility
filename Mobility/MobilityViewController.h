//
//  MobilityViewController.h
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobilityLogger.h"
#import "MobilitySensorManager.h"
@interface MobilityViewController : UITableViewController {
    MobilityLogger *logger;
}
@property(nonatomic, retain) IBOutlet UITableViewCell *locationCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *accelerometerCell;
@property(nonatomic, retain) IBOutlet UISwitch *locationSwitch;
@property(nonatomic, retain) IBOutlet UISwitch *accelerometerSwitch;
@property (nonatomic, retain) IBOutlet MobilitySensorManager *sensorManager;

- (IBAction)userChangedLoggingSwitch:(id)sender;
@end
