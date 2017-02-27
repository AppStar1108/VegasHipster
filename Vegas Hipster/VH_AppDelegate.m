//
//  VH_AppDelegate.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_AppDelegate.h"
#import "VH_HotelsListViewController.h"

@implementation VH_AppDelegate

@synthesize window;

CLLocationManager *locationManager;
UIBackgroundTaskIdentifier counterTask;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self checkAndCreateDatabase];
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:222/256.0 green:9/256.0 blue:0/256.0 alpha:1.0]];
    
	window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkgTile.png"]];
    
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];time_flag = TRUE;
	
	timer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(send_coords) userInfo:nil repeats:YES];
    
    return YES;
}
/*
// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    const void *devTokenBytes = [devToken bytes];
    //self.registered = YES;
    //[self sendProviderDeviceToken:devTokenBytes]; // custom method
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}
*/
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
	sqlite3 *db;
	sqlite3_open([databasePath UTF8String], &db);
	sqlite3_stmt *statement;
	NSString *query = [[NSString alloc] initWithFormat:@"SELECT value FROM settings WHERE name = 'backgroundTask';"];
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		if(sqlite3_step(statement)){
			NSString *bTask = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			
			if ([bTask isEqualToString:@"yes"]) {
				UIApplication *app = [UIApplication sharedApplication];
				
				counterTask = [app beginBackgroundTaskWithExpirationHandler:^{
					/*
					 [app endBackgroundTask:counterTask];
					 counterTask = UIBackgroundTaskInvalid;
					 */
				}];
				
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					timer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(send_coords) userInfo:nil repeats:YES];
					/*
					 [app endBackgroundTask:bgTask];
					 
					 bgTask = UIBackgroundTaskInvalid;
					 */
				});
			}else{
				timer = [NSTimer scheduledTimerWithTimeInterval:30000.0 target:self selector:@selector(send_coords) userInfo:nil repeats:YES];
			}
		}
	}
	sqlite3_finalize(statement);
	sqlite3_close(db);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)checkAndCreateDatabase {
	// First, test for existence.
    //NSLog(@"Testing Database.");
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success){
        //NSLog(@"Database exists.");
		return;
	}
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

-(CGRect)getScreenBoundsForCurrentOrientation {
    return [self getScreenBoundsForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

-(CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation {
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.
    
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation ==  UIInterfaceOrientationLandscapeLeft){
        CGRect temp = CGRectZero;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }
    
    return fullScreenRect;
}

-(void)send_coords {
	//path to database file
	NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
	
	//open and initialize database
	sqlite3 *db;
	sqlite3_open([databasePath UTF8String], &db);
	sqlite3_stmt *statement;
	NSString *query = [[NSString alloc] initWithFormat:@"SELECT group_num FROM ff_group LIMIT 1;"];
    NSLog(@"Query: %@", query);
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			locationManager = [[CLLocationManager alloc] init];
			locationManager.delegate = self;
			locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			[locationManager startUpdatingLocation];
			[self performSelector:@selector(flag_toggle) withObject:nil afterDelay:300.0];
		}
	}
	sqlite3_finalize(statement);
}

-(void)flag_toggle {
	time_flag = TRUE;
	[self send_coords];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	if (time_flag){
		//path to database file
		NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
        
		//open and initialize database
		sqlite3 *db;
		sqlite3_open([databasePath UTF8String], &db);
		sqlite3_stmt *statement;
		NSString *query = [[NSString alloc] initWithFormat:@"SELECT group_num,user_id FROM ff_group LIMIT 1;"];
		if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
				NSString *group_num = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
				NSString *user_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				NSString *lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
				NSString *longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
                
				NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.vegashipster.com/mobile.php?action=send_coords&lat=%f&long=%f&gnum=%@&uid=%@", [lat floatValue], [longitude floatValue], group_num, user_id]];
				NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
				if ([[NSURLConnection alloc] initWithRequest:request delegate:nil]) {
                    
                }
			}
		}
		sqlite3_finalize(statement);
		time_flag = FALSE;
	}
}

@end
