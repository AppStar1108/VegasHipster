//
//  VH_FriendListViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "VH_AppDelegate.h"
#import "VH_GroupViewController.h"

#define appDelegate (VH_AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface VH_FriendListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITableView *tblView;
    NSMutableArray *listArray;
    
    IBOutlet UILabel *titleLbl;
    IBOutlet UILabel *messageLbl;
    
    IBOutlet UIButton *createBtn;
    IBOutlet UIButton *joinBtn;
    
    CLLocationManager *locationManager;
}

- (bool)get_table_data;

@end
