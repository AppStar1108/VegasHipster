//
//  VH_UpdateViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 6/18/13.
//  Copyright (c) 2013 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "json/SBJson.h"
#import "VH_AppDelegate.h"

@interface VH_UpdateViewController : UIViewController {
	IBOutlet UILabel *status_text;
	IBOutlet UILabel *update_text;
	IBOutlet UIButton *updateButton;
    
	NSMutableData *receivedData;
    
	IBOutlet UIActivityIndicatorView *activity;
    
    NSString *currentValue;
}

@end
