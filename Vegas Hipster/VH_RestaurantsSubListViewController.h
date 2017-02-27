//
//  VH_RestaurantsSubListViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "VH_AppDelegate.h"
#import "VH_RestaurantDetailsViewController.h"

#define appDelegate (VH_AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface VH_RestaurantsSubListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    IBOutlet UITableView *tblView;
    NSMutableArray *listArray;
    
    NSString *categoryType;
	int page_count;
	int cur_page;
}

@property (nonatomic, retain) NSString *categoryType;

- (void)get_table_data;
- (void)getRestaurantType:(NSString *)type;

@end
