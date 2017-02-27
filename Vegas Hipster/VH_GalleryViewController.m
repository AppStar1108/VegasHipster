//
//  VH_GalleryViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 11/21/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_GalleryViewController.h"
#import "VH_PictureViewController.h"

@interface VH_GalleryViewController ()

@end

@implementation VH_GalleryViewController
@synthesize viewing;
@synthesize scrollView;
@synthesize receivedData;
@synthesize page_title;
@synthesize venue_type;
@synthesize type_id;
@synthesize page_label;
@synthesize childController;
@synthesize loading_view;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setVenueType:(NSString *)type andtypeId:(NSString *)typeId {
    venue_type = type;
    type_id = typeId;
}

- (void)getImageData {int img_rows = 0;
	int x = 20;
	int y = -50;
	
	self.navigationItem.title = page_title;
    
    for (UIView* view in scrollView.subviews) {
		if (view.tag != 99) {
			[view removeFromSuperview];
		}
	}
    
    NSString *post = [NSString stringWithFormat:@"action=newGallery&type=%@&id=%@", venue_type, type_id];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.vegashipster.com/mobile.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    //NSLog(@"Post Data: %@", postData);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil) {
        // Create new SBJSON parser object
        NSString *response = [[NSString alloc] initWithData:result encoding:
                              NSASCIIStringEncoding];
        
        // parse the JSON response into an object
        // Here we're using NSArray since we're parsing an array of JSON status objects
        NSArray *tblData = [(NSDictionary*)[response JSONValue] objectForKey:@"response"];
        
        // Each element in statuses is a single status
        // represented as a NSDictionary
        int i = 0;
        for (NSDictionary *data in tblData)
        {
            // You can retrieve individual values using objectForKey on the status NSDictionary
            // This will print the tweet and username to the console
            if (![[NSString stringWithFormat:@"%@",[data objectForKey:@"directory"]] isEqualToString:@"<null>"]){
                NSArray *split = [[data objectForKey:@"directory"] componentsSeparatedByString:@"."];
                NSString *first = [[NSString alloc] initWithFormat:@"%@_tn", [split objectAtIndex:0]];
                NSString *thumb = [[NSString alloc] initWithFormat:@"%@.%@", first, [split objectAtIndex:1]];
                
                //[title addObject:[[[data objectForKey:@"title"] stringByReplacingOccurrencesOfString:@"\\" withString:@""] stringByDecodingHTMLEntities]];
                
                
                NSString *img_path = [[NSString alloc] initWithFormat:@"http://www.vegashipster.com/%@", thumb];
                NSString *big_path = [[NSString alloc] initWithFormat:@"http://www.vegashipster.com/%@", [data objectForKey:@"directory"]];
                
                [images addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:big_path, @"image",
                                      [data objectForKey:@"caption"], @"caption", nil]];
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:img_path]];
                
                UIImage *current_image = [[UIImage alloc] initWithData:imageData];
                UIButton *current_image_button = [[UIButton alloc] init];
                [current_image_button setBackgroundImage:current_image forState:UIControlStateNormal];
                current_image_button.layer.cornerRadius = 10;
                current_image_button.layer.masksToBounds = YES;
                
                current_image_button.tag = i;
                
                if (img_rows < 4 && img_rows > 0) {
                    x += 72;
                }
                else {
                    img_rows = 0;
                    x = 20;
                    y += 72;
                }
                
                [current_image_button addTarget:self action:@selector(enlarge:) forControlEvents: UIControlEventTouchUpInside];
                
                CGRect iFrame = CGRectMake(x, y, 64, 64);
                [current_image_button setFrame:iFrame];
                [scrollView addSubview:current_image_button];
                img_rows++;
                i++;
            }
        }
    }else{
        NSLog(@"Error: %@", error);
    }
    
	[loading_view removeFromSuperview];
	
	CGFloat scrollViewHeight = y + 100;
	[scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor clearColor];
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:scrollView];
    }
    
	[scrollView addSubview:loading_view];
	if (viewing != 1) {
		for (UIView* view in scrollView.subviews) {
			if (view.tag != 99) {
				[view removeFromSuperview];
			}
		}
        
		[scrollView addSubview:loading_view];
		loading_view.layer.cornerRadius = 10;
		images = [[NSMutableArray alloc] init];
		page_label.text = page_title;
        
		[self getImageData];
	}
	else {
		[loading_view removeFromSuperview];
	}
    
	viewing = 0;
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



- (IBAction)enlarge:(UIButton *)sender {
    
	selectedPath = [[images objectAtIndex:sender.tag] objectForKey:@"image"];
	selectedCaption = [[images objectAtIndex:sender.tag] objectForKey:@"caption"];
    
    [self performSegueWithIdentifier:@"GalleryImagePushSegue" sender:self];
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     // Make sure we're referring to the correct segue
     if ([[segue identifier] isEqualToString:@"GalleryImagePushSegue"]) {
     
         // Get reference to the destination view controller
         VH_PictureViewController *vc = [segue destinationViewController];
         
         
         // Pass the name and index of our film
         //NSLog(@"%@", [[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]);
         [vc setImage:selectedPath withCaption:selectedCaption];
     }
}

@end
