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

#pragma mark - UIDocumentInteractionControllerDelegate
- (void) documentInteractionController: (UIDocumentInteractionController *) controller didEndSendingToApplication: (NSString *) application {
    [controller release];
}

#pragma mark - URL Schemes
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
 
    // write data to a file and present it.
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"data.txt"]];

    NSError *error = nil;
    MobilityLogger *logger = [[MobilityLogger alloc] init];
    [[logger jsonRepresentationForDB] writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [logger release];
    if (error) {
        NSLog(@"error writing file: %@", error);
        abort();
    }
    
    // wrote data needed to file. now let's ask user to open it in another app.
    UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    [controller retain];
    controller.UTI = @"public.plain-text";
    controller.delegate = self;

    UIView *currentView = self.window.rootViewController.view;
    CGRect rect = CGRectMake(40, 40, 200, 400);
    
    if (![controller presentOpenInMenuFromRect:rect inView:currentView animated:YES]) {
        NSLog(@"Failed to open doc in another app");
        abort();
    }
    return YES;
}

@end
