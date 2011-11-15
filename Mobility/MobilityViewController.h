//
//  MobilityViewController.h
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobilityViewController : UITableViewController
@property(nonatomic, retain) IBOutlet UITableViewCell *cell;
@property(nonatomic, retain) IBOutlet UISwitch *loggingSwitch;

- (IBAction)userChangedLoggingSwitch:(id)sender;
@end
