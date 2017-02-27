//
//  VH_RestaurantDetailsViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_RestaurantDetailsViewController.h"
#import "AddThis.h"

@interface VH_RestaurantDetailsViewController ()

@end

@implementation VH_RestaurantDetailsViewController
@synthesize workingId;

- (void)setTheWorkingId:(NSString *)newId {
    workingId = newId;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (!scrollView) {
        gallery_count = 0;
        
        [self get_table_data];
        [self build_user_interface];
        [self get_gallery_count];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    
    imageView = nil;
    scrollView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData	*)theData {
	[receivedData appendData:theData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	gallery_count = [[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding] intValue];
	
	if (gallery_count > 0) {
		tblGallery.layer.cornerRadius = 10;
		tblGallery.delegate = self;
		tblGallery.dataSource = self;
		tblGallery.tag = 4;
		[tblGallery reloadData];
		int gHeight = tblGallery.contentSize.height;
		tblGallery.frame = CGRectMake(20, yaxis, 280, gHeight);
		[scrollView addSubview:tblGallery];
	}
	[self resize_scrollview_to_fit];
}

- (void)get_table_data {
	//initializing all data arrays
	listHotelArray = [[NSMutableArray alloc] init];
	listRestArray = [[NSMutableArray alloc] init];
	listShowsArray = [[NSMutableArray alloc] init];
	listClubsArray = [[NSMutableArray alloc] init];
	
	//path to database file
	NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
    
	//open and initialize database
	sqlite3 *db;
	sqlite3_open([databasePath UTF8String], &db);
	
	//Obtaining hotel data for display
	sqlite3_stmt *statement;
	NSString *query = [[NSString alloc] initWithFormat:@"SELECT name, hotel_id, location, phone, description, image_path FROM rest_db WHERE rest_id = %@;", workingId];
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *hotel_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *rest_location = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			NSString *phone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            
			NSString *description = [self stripTags:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
			
			NSString *rest_image = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            
			if (rest_image == NULL || [rest_image isEqualToString:@""]) {
				header_image = [UIImage imageNamed:@"hdrHotels.jpg"];
			}else{
				NSString *image_path = [rest_image stringByReplacingOccurrencesOfString:@"../" withString:@""];
				if ([image_path isEqualToString:@""]) {
					header_image = [UIImage imageNamed:@"hdrHotels.jpg"];
				}else{
					NSFileManager* fileManager = [NSFileManager defaultManager];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                    NSString *libraryDirectory = [paths objectAtIndex:0];
                    
					NSString *myFilePath = [libraryDirectory stringByAppendingPathComponent:image_path];
                    
					NSLog(@"My File Path: %@", myFilePath);
                    
					BOOL fileExists = [fileManager fileExistsAtPath:myFilePath];
					
					if (fileExists){
						header_image = [UIImage imageWithContentsOfFile:myFilePath];
					}else{
                        [self downloadImage:image_path];
					}
				}
			}
			
			NSString *linkname = [[name stringByReplacingOccurrencesOfString:@" " withString:@"-"] mutableCopy];
            
            self.navigationItem.title = name;
            
            [listRestArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:name, @"name",
                                       hotel_id, @"hotel_id",
                                       rest_location, @"location",
                                       phone, @"phone",
                                       description, @"description",
                                       linkname, @"linkname",
                                       @"share", @"share", nil]];
            
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
	sqlite3_finalize(statement);
	
	//Obtaining restaurant data for table
	sqlite3_stmt *statement2;
    //	sqlite3_stmt *statement5;
	NSString *query2 = [[NSString alloc] initWithFormat: @"SELECT name, address1, address2 FROM hotel_db WHERE hotel_id = %@;", [[listRestArray objectAtIndex:0] objectForKey:@"hotel_id"]];
	if (sqlite3_prepare_v2(db, [query2 UTF8String], -1, &statement2, nil) == SQLITE_OK) {
		while (sqlite3_step(statement2) == SQLITE_ROW) {
			NSString *hotel_name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 0)];
            NSString *add1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 1)];
            NSString *add2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 2)];
            
            [listHotelArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:hotel_name, @"name",
                                       add1, @"address1",
                                       add2, @"address2", nil]];
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    //	sqlite3_finalize(statement5);
	sqlite3_finalize(statement2);
    
	//close database
	sqlite3_close(db);
}

- (void)build_user_interface {
	//initialize subviews
	yaxis = 160;
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:scrollView];
    }
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 150)];
        imageView.image = header_image;
        [scrollView addSubview:imageView];
    }
    
	tblHotel = [[UITableView alloc] init];
	tblGallery = [[UITableView alloc] init];
	
	//Add map and call buttons
	if ([listHotelArray count] && ![[[listHotelArray objectAtIndex:0] objectForKey:@"address1"] isEqualToString:@""]) {
		UIButton *map_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[map_button setFrame:CGRectMake(20, yaxis, 100, 40)];
		[map_button setTitle:@"Map" forState:UIControlStateNormal];
		[map_button addTarget:self action:@selector(openMap:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView addSubview:map_button];
	}
	
	if ([listRestArray count] && ![[[listRestArray objectAtIndex:0] objectForKey:@"phone"] isEqualToString:@""]) {
		UIButton *call_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[call_button setFrame:CGRectMake(130, yaxis, 170, 40)];
		[call_button setTitle:[[listRestArray objectAtIndex:0] objectForKey:@"phone"] forState:UIControlStateNormal];
		[call_button addTarget:self action:@selector(dialPhone:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView addSubview:call_button];
	}
    
	if ([listRestArray count] && ![[[listRestArray objectAtIndex:0] objectForKey:@"share"] isEqualToString:@""]){
        UIBarButtonItem *share_button = [[UIBarButtonItem alloc] initWithTitle:@""  style:UIBarButtonItemStylePlain target:self action:@selector(shareThis:)];
		UIImage *img = [UIImage imageNamed:@"shareBtn.png"];
		[share_button setImage:img];
		
		self.navigationItem.rightBarButtonItem = share_button;
	}
    
	if (([listHotelArray count] && (![[[listHotelArray objectAtIndex:0] objectForKey:@"address1"] isEqualToString:@""] && ![[[listHotelArray objectAtIndex:0] objectForKey:@"address2"] isEqualToString:@""])) || (![[[listRestArray objectAtIndex:0] objectForKey:@"phone"] isEqualToString:@""])) {
		yaxis += 55;
	}
	
	
	//Add Restaurant information
	UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 25)];
	[name setTextColor:[UIColor whiteColor]];
	[name setBackgroundColor:[UIColor clearColor]];
	[name setText:[[listRestArray objectAtIndex:0] objectForKey:@"name"]];
	[name setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
	[scrollView addSubview:name];
	yaxis += 18;
	
	//Add location information in restaurant database if it isn't blank
	//otherwise we add the hotel address information
	if ([[listRestArray objectAtIndex:0] objectForKey:@"location"] == nil || [[[listRestArray objectAtIndex:0] objectForKey:@"location"] isEqualToString:@""]) {
        if ([listHotelArray count]) {
            UILabel *add1 = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 25)];
            [add1 setTextColor:[UIColor whiteColor]];
            [add1 setBackgroundColor:[UIColor clearColor]];
            [add1 setText:[[listHotelArray objectAtIndex:0] objectForKey:@"address1"]];
            [add1 setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
            [scrollView addSubview:add1];
            yaxis += 18;
            
            UILabel *add2 = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 25)];
            [add2 setTextColor:[UIColor whiteColor]];
            [add2 setBackgroundColor:[UIColor clearColor]];
            [add2 setText:[[listHotelArray objectAtIndex:0] objectForKey:@"address2"]];
            [add2 setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
            [scrollView addSubview:add2];
            yaxis += 40;
        }
	}else{
		UILabel *add1 = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 25)];
		[add1 setTextColor:[UIColor whiteColor]];
		[add1 setBackgroundColor:[UIColor clearColor]];
		[add1 setText:[[listRestArray objectAtIndex:0] objectForKey:@"location"]];
		[add1 setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
		[scrollView addSubview:add1];
		yaxis += 18;
		
		UILabel *add2 = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 25)];
		[add2 setTextColor:[UIColor whiteColor]];
		[add2 setBackgroundColor:[UIColor clearColor]];
		[add2 setText:@"Las Vegas, Nevada"];
		[add2 setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
		[scrollView addSubview:add2];
		yaxis += 40;
	}
    
	//add hotel if restaurant isn't standalone
	if ([listHotelArray count]) {
		//create title
		UILabel *lblHotel = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 22)];
		[scrollView addSubview:lblHotel];
		[lblHotel setText:@"Located In:"];
		[lblHotel setTextColor:[UIColor whiteColor]];
		[lblHotel setBackgroundColor:[UIColor clearColor]];
		[lblHotel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
		yaxis += 25;
		//create table
		tblHotel.layer.cornerRadius = 10;
		tblHotel.delegate = self;
		tblHotel.dataSource = self;
		tblHotel.tag = 1;
		[tblHotel reloadData];
		int hHeight = tblHotel.contentSize.height;
		tblHotel.frame = CGRectMake(20, yaxis, 280, hHeight);
		yaxis += (hHeight + 10);
		[scrollView addSubview:tblHotel];
	}
	
	//formatting description layout and text
	//hotel_description = [hotel_description stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
	
	UILabel *desc_title = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 25)];
	[desc_title setTextColor:[UIColor whiteColor]];
	[desc_title setBackgroundColor:[UIColor clearColor]];
	[desc_title setText:@"Information:"];
	[desc_title setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
	[scrollView addSubview:desc_title];
	yaxis += 25;
	
	UIView *desc_background = [[UIView alloc] init];
	desc_background.layer.cornerRadius = 10;
	[desc_background setBackgroundColor:[UIColor whiteColor]];
	UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 260, 100)];
	[desc setFont:[UIFont fontWithName:@"TrebuchetMS" size:18]];
	[desc setNumberOfLines:0];
	[desc setLineBreakMode:UILineBreakModeWordWrap];
	[desc setText:[[listRestArray objectAtIndex:0] objectForKey:@"description"]];
	[desc sizeToFit];
	[desc_background setFrame:CGRectMake(20, yaxis, 280, (desc.bounds.size.height + 10))];
	[desc_background addSubview:desc];
	[scrollView addSubview:desc_background];
    
	
	yaxis += (desc_background.bounds.size.height + 10);
	
	//scrollview settings
	scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkgTile.png"]];
	[self resize_scrollview_to_fit];
	
	//add scrollview with subviews
	[self.view addSubview:scrollView];
}

- (void)shareThis:(id)sender {
    //Show addthis menu
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
    
    linkUrl = [NSString stringWithFormat:@"http://www.vegashipster.com/restaurants/%@.php",[[listRestArray objectAtIndex:0] objectForKey:@"linkname"]];
	linkTitle = [NSString stringWithFormat:@"You should check out %@!",[[listRestArray objectAtIndex:0] objectForKey:@"name"]];
    
    [AddThisSDK setFavoriteMenuServices:@"facebook",@"twitter",nil];
    
    [AddThisSDK setAddThisPubId:@"ra-51ffe583468b203f"];
    
    [AddThisSDK presentAddThisMenuForURL:linkUrl withTitle:linkTitle description:@"Check out this restaurant I've found using Vegas Hipster's iPhone app!"];
}

-(void)downloadImage:(id)image_path {
    NSString *urlString = [NSString stringWithFormat: @"http://www.vegashipster.com/%@",image_path];
    
    NSURL *imageURL = [NSURL URLWithString:urlString];
    
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    NSString *hotelsPath = [libraryDirectory stringByAppendingPathComponent:@"images/restaurant"];
    NSString *myFilePath = [libraryDirectory stringByAppendingPathComponent:image_path];
    
    NSLog(@"saving jpg %@",myFilePath);
    UIImage *image = [[UIImage alloc] initWithData:imageData];//1.0f = 100% quality
    header_image = image;
    
    BOOL isDir;
    NSError *error;
    if (!([[NSFileManager defaultManager] fileExistsAtPath:hotelsPath isDirectory:&isDir] && isDir)) {
        NSLog(@"Directory doesn't exist.  Creating directory.");
        if (![[NSFileManager defaultManager] createDirectoryAtPath:hotelsPath withIntermediateDirectories:true attributes:nil error:&error]){
            NSLog(@"Directory not created.  Error: %@",error);
        }
    }
    
    if (![[NSFileManager defaultManager] createFileAtPath:myFilePath contents:imageData attributes:nil]){
        NSLog(@"Not Saved!!!!");
    }
    
    NSLog(@"saving image done");
}

- (NSString *) stripTags:(NSString *)str
{
    NSMutableString *ms = [NSMutableString stringWithCapacity:[str length]];
    NSString *temp = NULL;
    
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    NSString *s = nil;
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:&s];
        if (s != nil)
            [ms appendString:s];
        [scanner scanUpToString:@">" intoString:&temp];
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation]+1];
        if ([temp isEqualToString:@"br/"] || [temp isEqualToString:@"br"] || [temp isEqualToString:@"br /"] || [temp isEqualToString:@"p"]){
            [ms appendString:@"\n"];
        }
        s = nil;
        temp = nil;
    }
    
    return ms;
}

- (void)resize_scrollview_to_fit {
	CGFloat scrollViewHeight = 0.0f;
	for (UIView *view in scrollView.subviews) {
		scrollViewHeight += view.frame.size.height;
	}
	scrollViewHeight += 100;
	[scrollView setContentSize:(CGSizeMake(320, scrollViewHeight))];
}

-(void)dialPhone:(id)sender {
	NSMutableString *strippedString = [[NSMutableString alloc] initWithString:@""];
	
	NSScanner *phoneScanner = [NSScanner scannerWithString:[[listRestArray objectAtIndex:0] objectForKey:@"phone"]];
	NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
	
	while ([phoneScanner isAtEnd] == NO) {
		NSString *buffer;
		if ([phoneScanner scanCharactersFromSet:numbers intoString:&buffer]) {
			[strippedString appendString:buffer];
		}
		else {
			[phoneScanner setScanLocation:([phoneScanner scanLocation] + 1)];
		}
	}
	
	strippedString = [NSString stringWithFormat:@"tel://%@", strippedString];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:strippedString]];
}

-(void)openMap:(id)sender {
    
    [self performSegueWithIdentifier:@"pushMapView" sender:self];
}

-(void)threadDone:(NSNotification*)arg {
	NSLog(@"Exiting");
	canGo = TRUE;
}

- (void)get_gallery_count {
	NSString *NSURLString = [[NSString alloc] initWithFormat:@"http://www.vegashipster.com/mobile.php?action=gallery_count&type=restaurantId&id=%@", workingId];
    
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:NSURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
	if (theConnection) {
        receivedData = [NSMutableData data];
	} 	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (tableView.tag == 1) {
		return [listHotelArray count];
	}
	else if (tableView.tag == 4) {
		return 1;
	}else{
        return 0;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
	
	// Configure the cell...
	if (tableView.tag == 1) {
		cell.textLabel.text = [[listHotelArray objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.detailTextLabel.text = [[listHotelArray objectAtIndex:indexPath.row] objectForKey:@"value"];
	}
	else if (tableView.tag == 4) {
		cell.textLabel.text = @"Photo Gallery";
		cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d images", gallery_count];
	}
    
	cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
	cell.detailTextLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    
	if (tableView.tag == 4){
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}else{
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog ( @"You selected row: %d", indexPath.row);
    
    if (tableView == tblGallery) {
        [self performSegueWithIdentifier:@"GalleryPushSegue" sender:self];
    }else if (tableView == tblHotel) {
        [self performSegueWithIdentifier:@"HotelsDetailsViewSegue" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tblGallery) {
        [self performSegueWithIdentifier:@"GalleryPushSegue" sender:self];
    }else if (tableView == tblHotel) {
        [self performSegueWithIdentifier:@"HotelsDetailsViewSegue" sender:self];
    }
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"pushMapView"]) {
        //add pin for current restaurant
        NSString *add1 = @"";
        NSString *add2 = @"";
        
        if ([[listRestArray objectAtIndex:0] objectForKey:@"location"] == nil || [[[listRestArray objectAtIndex:0] objectForKey:@"location"] isEqualToString:@""]) {
            add1 = [[[listHotelArray objectAtIndex:0] objectForKey:@"address1"] stringByReplacingOccurrencesOfString:@"." withString:@""];
            add1 = [add1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            add1 = [add1 stringByReplacingOccurrencesOfString:@"," withString:@""];
            add1 = [add1 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            add2 = [[[listHotelArray objectAtIndex:0] objectForKey:@"address2"] stringByReplacingOccurrencesOfString:@"." withString:@""];
            add2 = [add2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            add2 = [add2 stringByReplacingOccurrencesOfString:@"," withString:@""];
            add2 = [add2 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        }else{
            add1 = [[[listRestArray objectAtIndex:0] objectForKey:@"location"] stringByReplacingOccurrencesOfString:@"." withString:@""];
            add1 = [add1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            add1 = [add1 stringByReplacingOccurrencesOfString:@"," withString:@""];
            add1 = [add1 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            add2 = @"Las Vegas, Nevada";
            add2 = [add2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            add2 = [add2 stringByReplacingOccurrencesOfString:@"," withString:@""];
            add2 = [add2 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        }
        
        NSString *theUrl = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps/geo?q=%@+%@&output=csv", add1, add2];
        
        // Get reference to the destination view controller
        VH_MapViewController *vc = [segue destinationViewController];
        
        [vc setWorkingVariables:@"rest_db" withIdentifier:@"rest_id" withId:workingId withUrl:theUrl];
    }else if ([[segue identifier] isEqualToString:@"GalleryPushSegue"]) {
        
        
        // Get reference to the destination view controller
        VH_GalleryViewController *vc = [segue destinationViewController];
        
        [vc setVenueType:@"restaurantId" andtypeId:workingId];
    }else if ([[segue identifier] isEqualToString:@"HotelsDetailsViewSegue"]) {
            
            // Get reference to the destination view controller
            VH_HotelsDetailsViewController *vc = [segue destinationViewController];
            
            // Pass the name and index of our film
            //NSLog(@"%@", [[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]);
            [vc setTheWorkingId:[[listRestArray objectAtIndex:0] objectForKey:@"hotel_id"]];
        }
}

@end
