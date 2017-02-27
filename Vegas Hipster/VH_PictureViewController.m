//
//  VH_PictureViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 11/21/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_PictureViewController.h"

@interface VH_PictureViewController ()

@end

@implementation VH_PictureViewController
@synthesize image_path;
@synthesize picture;
@synthesize caption_label;
@synthesize caption;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setImage:(NSString *)theImage withCaption:(NSString *)theCaption {
    image_path = theImage;
    caption = theCaption;
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor clearColor];
    
	NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_path]];
	UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    if (!picture) {
        picture = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 320)];
        picture.image = [UIImage imageNamed:@"hdrDining.jpg"];
        [self.view addSubview:picture];
    }
    
    if (!caption_label) {
        caption_label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 330.0, 320, 20)];
        caption_label.textAlignment = NSTextAlignmentCenter;
        caption_label.textColor = [UIColor whiteColor];
        caption_label.backgroundColor = [UIColor clearColor];
        [self.view addSubview:caption_label];
    }
    
	picture.image = image;
	caption_label.text = caption;
    
    self.title = caption;
	[super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
