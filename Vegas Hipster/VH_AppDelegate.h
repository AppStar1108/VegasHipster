//
//  VH_AppDelegate.h
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "json/SBJson.h"
#import <CoreLocation/CoreLocation.h>

@interface VH_AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
	bool *time_flag;
	NSTimer *timer;
}

@property (strong, nonatomic) UIWindow *window;

-(CGRect)getScreenBoundsForCurrentOrientation;
-(CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation;

-(void)send_coords;

@end
