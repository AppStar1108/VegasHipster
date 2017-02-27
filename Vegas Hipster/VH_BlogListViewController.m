//
//  VH_BlogListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_BlogListViewController.h"

@interface VH_BlogListViewController ()

@end

@implementation VH_BlogListViewController

- (void)build_user_interface {
    CGRect contentRect = CGRectZero;
    contentRect = CGRectUnion(contentRect, imageView.frame);
    contentRect = CGRectUnion(contentRect, textLabel.frame);
    contentRect = CGRectUnion(contentRect, blogButton.frame);
    
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
        imageView.image = [UIImage imageNamed:@"hdrBlog.png"];
        [scrollView addSubview:imageView];
    }
    
    if (!textLabel) {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 155.0, 300, 170)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        textLabel.text = @"Visit our Blog at http://www.vegashipster.com/blog\n\nWe have all the latest news on what's happening in and around Las Vegas, and we search for the best promos and deals for your trip there so you don't have to. Updated daily!";
        textLabel.lineBreakMode = UILineBreakModeWordWrap;
        textLabel.numberOfLines = 0;
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:textLabel];
    }
    
    if (!blogButton) {
        blogButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        blogButton.frame = CGRectMake(30.0, 340.0, 260.0, 37.0);
        blogButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [blogButton addTarget:self action:@selector(openBlog:) forControlEvents:UIControlEventTouchUpInside];
        [blogButton setTitle:@"Visit Blog" forState:UIControlStateNormal];
        [scrollView addSubview:blogButton];
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
