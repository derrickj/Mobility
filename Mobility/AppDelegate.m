//
//  AppDelegate.m
//  Mobility
//
//  Created by Derrick Jones on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MobilityViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[[MobilityViewController alloc] initWithNibName:@"MobilityViewController" bundle:nil] autorelease];
    [self.window makeKeyAndVisible];

    NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (url) {
        //FIXME: validate url!!! SECURITY RISK IF NOT CAREFUL
        UILocalNotification *note = [[UILocalNotification alloc] init];
        note.alertBody = [NSString stringWithFormat:@"Launched with: %@", url];
        [application presentLocalNotificationNow:note];
        [note release];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - URL Schemes
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSString *msg = [NSString stringWithFormat:@"Launched with: %@", url];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"url" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [view show];
    [view release];

    // write data to a file and present it.
   //NSURL *fileURL = [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:NSTemporaryDirectory(),@"data.txt", nil]];

   // NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"data.txt"]];
    NSURL *fileURL = [[NSURL alloc] initWithScheme:@"file" host:nil path:[NSDocumentDirectory stringByAppendingPathComponent:@"data.txt"]];
    NSError *error = nil;
    [[NSURL description] writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"error writing file: %@", error);
        abort();
    }
    
    // wrote data needed to file. now let's ask user to open it in another app.
    UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    controller.UTI = @"public.plain-text";
    controller.delegate = self;
    
    NSLog(@"file URL: %@", fileURL);
    UIView *currentView = self.window;
    
    
    if (![controller presentOpenInMenuFromRect:CGRectZero inView:currentView animated:YES]) {
        perror("\n\nWTF");
        abort();
    }
    return YES;
}

@end
