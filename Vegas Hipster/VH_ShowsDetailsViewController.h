//
//  VH_ShowsDetailsViewController.h
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

@interface VH_ShowsDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    
    NSMutableArray *listHotelArray;
    NSMutableArray *listRestArray;
    NSMutableArray *listLocationArray;
    NSMutableArray *listClubsArray;
    
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

-(void)downloadImage:(id)image_path;

-(void)build_user_interface;
-(void)dialPhone:(id)sender;
-(void)openMap:(id)sender;

@end
