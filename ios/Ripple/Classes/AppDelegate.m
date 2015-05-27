/*******************************************************************************
 * This is the copyright work of The MITRE Corporation, and was produced for the 
 * U. S. Government under Contract Number DTFAWA-10-C-00080, as well as subject 
 * to the Apache Licence, Version 2.0 dated January 2004. 
 * 
 * For further information, please contact The MITRE Corporation, Contracts Office, 
 * 7515 Colshire Drive, McLean, VA  22102-7539, (703) 983-6000.
 * 
 * Copyright 2011 The MITRE Corporation
 * 
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 * 
 *        http://www.apache.org/licenses/LICENSE-2.0
 * 
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 ******************************************************************************/



#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize expired;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString* audioAlerts = [[NSUserDefaults standardUserDefaults] stringForKey:@"AudioAlerts"];
	NSString* runwayAlerts = [[NSUserDefaults standardUserDefaults] stringForKey:@"RunwayAlerts"];
    
	lastLoc = nil;
	lastHdg = 0;
	
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	if(![audioAlerts isEqualToString:@"NO"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"AudioAlerts"];		
	}
	if(![runwayAlerts isEqualToString:@"NO"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"RunwayAlerts"];
	}
	
    // Add the view controller's view to the window and display.
	//viewController = [[RippleViewController alloc] initWithRootViewController:nil];
    
    //[self.window addSubview:viewController.view];
    //[self.window makeKeyAndVisible];
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
	
	long long currentDate = round(1000.0 * [[NSDate date] timeIntervalSince1970]);
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:1];
	[comps setMonth:9];
	[comps setYear:2012];
	NSDate* jan2012 = [[NSCalendar currentCalendar] dateFromComponents:comps];
	long long expirationDate = round(1000.0 * [jan2012 timeIntervalSince1970]);
	
	if(currentDate > expirationDate) {
        UIAlertView* expiredView = [[UIAlertView alloc] initWithTitle:@"Expired Ripple App" message:@"The Ripple App was designated to expire Oct 1, 2012. If you have any questions about this, please contact the MITRE Corp. at ripple@mitre.org. The app will now terminate." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [expiredView show];	
        expired = YES;
    } else {
        expired = NO;
        NSString* folder = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        NSString* name= @"listening.wav";
        NSString* path = [folder stringByAppendingPathComponent:name];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:url error:nil];

        folder = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        name= @"recording.wav";
        path = [folder stringByAppendingPathComponent:name];
        url = [NSURL fileURLWithPath:path];
        [fileManager removeItemAtURL:url error:nil];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    NSLog(@"Resigning active...");
    RippleViewController* rvc = (RippleViewController*) [self.window rootViewController];
    
    if(rvc.headerView.listening) {
        [rvc.headerView manageMics];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    if(alert != nil) {
		if(alert.activeAlert) {
			//NSLog(@"Closing Alert b/c System.exit");
			[alert logClosingAlertWithLocation:lastLoc heading:lastHdg reason:2];
		}
	}

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

- (AlertRecord*) getAlertRecord {
	if(alert == nil)
		alert = [[AlertRecord alloc] init];
	
	return alert;
}

- (void) setLastVitals:(CLLocation*)loc heading:(double)h {
	lastLoc = loc;
	lastHdg = h;
}

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

- (void)alertView : (UIAlertView *)alertView1 clickedButtonAtIndex : (NSInteger)buttonIndex {
    exit(0);
}

@end