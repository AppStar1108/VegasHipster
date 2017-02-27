//
//  VH_TaxisDetailsViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "VH_AppDelegate.h"
#import "VH_MapViewController.h"
#import "VH_HotelsDetailsViewController.h"

#define appDelegate (VH_AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface VH_TaxisDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    
    NSMutableArray *listHotelArray;
    NSMutableArray *listLocationArray;
    
	UITableView *tblHotel;
	UITableView *tblGallery;
    
	NSString *urlpath;
	NSData *data;
    UIImage *header_image;
    
	NSString *linkUrl;
	NSString *linkTitle;
	NSURL *url;
    
	NSMutableData *receivedData;
	BOOL canGo;
    int yaxis;
    int gallery_count;
    
    NSString *workingId;
}

@property (nonatomic, retain) NSString *workingId;

- (void)get_table_data;
- (void)setTheWorkingId:(NSString *)newId;

-(void)build_user_interface;
-(void)dialPhone:(id)sender;

@end
