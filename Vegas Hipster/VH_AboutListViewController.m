//
//  VH_AboutListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_AboutListViewController.h"

@interface VH_AboutListViewController ()

@end

@implementation VH_AboutListViewController

- (void)build_user_interface {
    CGRect contentRect = CGRectZero;
    contentRect = CGRectUnion(contentRect, imageView.frame);
    contentRect = CGRectUnion(contentRect, headerLabel.frame);
    contentRect = CGRectUnion(contentRect, textLabel.frame);
    
    contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, 320, contentRect.size.height);
    
    [scrollView setContentSize:contentRect.size];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:scrollView];
    }
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 150)];
        imageView.image = [UIImage imageNamed:@"hdrAbout.png"];
        [scrollView addSubview:imageView];
    }
    
    if (!headerLabel) {
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 155.0, 300, 25)];
        headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        headerLabel.text = @"About Us / FAQ";
        headerLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        headerLabel.lineBreakMode = UILineBreakModeWordWrap;
        headerLabel.numberOfLines = 0;
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:headerLabel];
    }
    
    if (!textLabel) {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 185.0, 300, 600)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        textLabel.text = @"Vegas Hipster is dedicated to helping give you the best Las Vegas experience possible.  We have the best deals, reviews, and news on everything Vegas. For more information, check out www.vegashipster.com and www.vegashipster.com/blog.\n\nThe Friend Finder is an addition to the Vegas Hipster App. It may not work in all areas, and quality is subject to the speed of your service provider and wireless data plan. We do not guarantee this feature and please do not use it as a security device.\n\niPhone 3GS and above supports background process for GPS. Friend Finder updates every five minutes, and may experience issues with poor Internet connection. Although we try to keep our database as current as possible, we accept no liability for the content of this app, nor for any actions taken as a result of information provided in this app.\n\n App Version 2.0";
        textLabel.lineBreakMode = UILineBreakModeWordWrap;
        textLabel.numberOfLines = 0;
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:textLabel];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self build_user_interface];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [imageView removeFromSuperview];
    [scrollView removeFromSuperview];
    [textLabel removeFromSuperview];
    
    imageView = nil;
    scrollView = nil;
    textLabel = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openBlog:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.vegashipster.com/blog/"]];
}

@end
