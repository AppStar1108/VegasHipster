//
//  VH_SplashViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 8/5/13.
//  Copyright (c) 2013 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "json/SBJson.h"

@interface VH_SplashViewController : UIViewController {
	NSDictionary *parsedJson;
	UIAlertView *alertWithYesNoButtons;
}

@end
