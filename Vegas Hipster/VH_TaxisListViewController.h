//
//  VH_TaxisListViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "VH_AppDelegate.h"
#import "VH_TaxisDetailsViewController.h"

#define appDelegate (VH_AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface VH_TaxisListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    IBOutlet UITableView *tblView;
    NSMutableArray *listArray;
    
	int page_count;
	int cur_page;
}

@property (nonatomic, retain) NSString *categoryType;

- (void)get_table_data;

@end
