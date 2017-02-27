//
//  VH_HotelsDetailsViewController.h
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
#import "VH_GalleryViewController.h"
#import "VH_RestaurantDetailsViewController.h"
#import "VH_ShowsDetailsViewController.h"
#import "VH_ClubsDetailsViewController.h"
#import "VH_AttractionsDetailsViewController.h"
#import "VH_SportsDetailsViewController.h"
#import "DOR_Utilities.h"

#define appDelegate (VH_AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface VH_HotelsDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    
    NSMutableArray *listHotelArray;
    NSMutableArray *listRestArray;
    NSMutableArray *listShowsArray;
    NSMutableArray *listClubsArray;
    NSMutableArray *listSportsArray;
    NSMutableArray *listAttractionsArray;
    
	UITableView *tblRest;
	UITableView *tblShows;
	UITableView *tblClubs;
	UITableView *tblGallery;
    UITableView *tblSports;
    UITableView *tblAttractions;
    
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
    
    DOR_Utilities *utility;
}

@property (nonatomic, retain) NSString *workingId;

- (void)get_table_data;
- (void)setTheWorkingId:(NSString *)newId;

-(void)downloadImage:(id)image_path;

-(void)build_user_interface;
-(void)dialPhone:(id)sender;
-(void)openMap:(id)sender;
/*
-(BOOL)dataIsValidPNG:(NSData *)imageData;
-(BOOL)dataIsValidJPEG:(NSData *)imageData;
-(BOOL)dataIsValidGIF:(NSData *)imageData;

-(BOOL)imageIsValid:(NSData *)imageData withExtension:(NSString *)extension;
*/
@end
