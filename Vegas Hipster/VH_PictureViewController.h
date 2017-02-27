//
//  VH_PictureViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 11/21/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VH_PictureViewController : UIViewController {
	UIImageView *picture;
	NSString *image_path;
	NSString *caption;
	UILabel *caption_label;
}

@property (nonatomic, retain) IBOutlet UIImageView *picture;
@property (nonatomic, retain) NSString *image_path;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) IBOutlet UILabel *caption_label;

- (void)setImage:(NSString *)theImage withCaption:(NSString *)theCaption;

@end
