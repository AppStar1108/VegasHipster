//
//  VH_RestaurantsListViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "VH_AppDelegate.h"
#import "VH_RestaurantsSubListViewController.h"

#define appDelegate (VH_AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface VH_RestaurantsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    IBOutlet UITableView *tblView;
    NSMutableArray *listArray;
}

- (void)get_table_data;

@end
