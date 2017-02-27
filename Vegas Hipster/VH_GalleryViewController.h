//
//  VH_GalleryViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 11/21/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "json/SBJson.h"

@class VH_PictureViewController;

@interface VH_GalleryViewController : UIViewController {
	int viewing;
	VH_PictureViewController *childController;
	UIScrollView *scrollView;
	NSMutableData *receivedData;
	NSString *page_title;
	NSString *venue_type;
	NSString *type_id;
	UILabel *page_label;
    
	//loading controls
	UIView *loading_view;
    
    NSMutableArray *images;
    
    NSString *selectedPath;
    NSString *selectedCaption;
}

@property int viewing;
@property (nonatomic, retain) VH_PictureViewController *childController;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString *page_title;
@property (nonatomic, retain) NSString *venue_type;
@property (nonatomic, retain) NSString *type_id;
@property (nonatomic, retain) IBOutlet UILabel *page_label;

@property (nonatomic, retain) IBOutlet UIView *loading_view;

- (void)setVenueType:(NSString *)type andtypeId:(NSString *)typeId;

@end
