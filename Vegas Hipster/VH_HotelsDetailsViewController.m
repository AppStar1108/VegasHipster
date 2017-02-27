//
//  VH_HotelsDetailsViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_HotelsDetailsViewController.h"
#import "AddThis.h"

@interface VH_HotelsDetailsViewController ()

@end

@implementation VH_HotelsDetailsViewController
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
		tblGallery.tag = 6;
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
    listSportsArray = [[NSMutableArray alloc] init];
    listAttractionsArray = [[NSMutableArray alloc] init];
	
	//path to database file
	NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
    
	//open and initialize database
	sqlite3 *db;
	sqlite3_open([databasePath UTF8String], &db);
	
	//Obtaining hotel data for display
	sqlite3_stmt *statement;
	NSString *query = [[NSString alloc] initWithFormat:@"SELECT name, address1, address2, local_phone, description, image_path, linkname FROM hotel_db WHERE hotel_id = %@;", workingId];
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *hotel_name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *hotel_add1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *hotel_add2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			NSString *hotel_phone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            
			NSString *hotel_description = [self stripTags:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
            
			NSString *hotel_image = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
			
            
			if (hotel_image == NULL || [hotel_image isEqualToString:@""]) {
				header_image = [UIImage imageNamed:@"hdrHotels.jpg"];
			}else{
				NSString *image_path = [hotel_image stringByReplacingOccurrencesOfString:@"../" withString:@""];
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
			
			NSString *hotel_linkname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
			hotel_linkname = [[hotel_linkname stringByReplacingOccurrencesOfString:@" " withString:@"-"] mutableCopy];
            
            self.navigationItem.title = hotel_name;
            
            [listHotelArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:hotel_name, @"name",
                                       hotel_add1, @"address1",
                                       hotel_add2, @"address2",
                                       hotel_phone, @"phone",
                                       hotel_description, @"description",
                                       hotel_linkname, @"linkname",
                                       @"share", @"share", nil]];
            
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
	sqlite3_finalize(statement);
	
	//Obtaining restaurant data for table
	sqlite3_stmt *statement2;
	NSString *query2 = [[NSString alloc] initWithFormat: @"SELECT name, rest_id FROM rest_db WHERE hotel_id = %@ ORDER BY name ASC;", workingId];
	if (sqlite3_prepare_v2(db, [query2 UTF8String], -1, &statement2, nil) == SQLITE_OK) {
		while (sqlite3_step(statement2) == SQLITE_ROW) {
			NSString *rName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 0)];
			NSString *rID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 1)];
            
			sqlite3_stmt *statement5;
			NSString *query5 = [[NSString alloc] initWithFormat: @"SELECT value FROM prices WHERE table_name = 'rest_db' and table_id = %d;", [rID intValue]];
            
            NSString *value = @"";
            
			if (sqlite3_prepare_v2(db, [query5 UTF8String], -1, &statement5, nil) == SQLITE_OK) {
				if (sqlite3_step(statement5) == SQLITE_ROW) {
					int price = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement5, 0)] intValue];
                    
					while (price > 0) {
						value = [value stringByAppendingString:@"$"];
						price--;
					}
					if (![value isEqualToString:@""]) {
						value = [[NSString alloc] initWithFormat:@"Price Rating: %@", value];
					}
				}
			}
            
            [listRestArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:rID, @"id",
                                       rName, @"name",
                                       value, @"value", nil]];
            
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    //	sqlite3_finalize(statement5);
	sqlite3_finalize(statement2);
    
	//Obtaining shows data for table
	sqlite3_stmt *statement3;
	NSString *query3 = [[NSString alloc] initWithFormat: @"SELECT name, shows_id FROM shows_db WHERE hotel_id = %@ ORDER BY name ASC;", workingId];
	if (sqlite3_prepare_v2(db, [query3 UTF8String], -1, &statement3, nil) == SQLITE_OK) {
		while (sqlite3_step(statement3) == SQLITE_ROW) {
			NSString *sName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement3, 0)];
			NSString *sID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement3, 1)];
            
			sqlite3_stmt *statement6;
			NSString *query6 = [[NSString alloc] initWithFormat: @"SELECT value FROM prices WHERE table_name = 'shows_db' and table_id = %d;", [sID intValue]];
            
            NSString *value = @"";
            
			if (sqlite3_prepare_v2(db, [query6 UTF8String], -1, &statement6, nil) == SQLITE_OK) {
				if (sqlite3_step(statement6) == SQLITE_ROW) {
					int price = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement6, 0)] intValue];
					while (price > 0) {
						value = [value stringByAppendingString:@"$"];
						price--;
					}
					if (![value isEqualToString:@""]) {
						value = [[NSString alloc] initWithFormat:@"Price Rating: %@", value];
					}
				}
			}
            
            [listShowsArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:sID, @"id",
                                      sName, @"name",
                                      value, @"value", nil]];
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    //	sqlite3_finalize(statement6);
	sqlite3_finalize(statement3);
    
	//obtaining clubs data for display
	sqlite3_stmt *statement4;
	NSString *query4 = [[NSString alloc] initWithFormat: @"SELECT name, clubs_id FROM clubs WHERE hotel_id = %@ ORDER BY name ASC;", workingId];
	if (sqlite3_prepare_v2(db, [query4 UTF8String], -1, &statement4, nil) == SQLITE_OK) {
		while (sqlite3_step(statement4) == SQLITE_ROW) {
			NSString *cName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement4, 0)];
			NSString *cID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement4, 1)];
            
			sqlite3_stmt *statement7;
			NSString *query7 = [[NSString alloc] initWithFormat: @"SELECT value FROM prices WHERE table_name = 'clubs' and table_id = %d;", [cID intValue]];
            
            NSString *value = @"";
            
			if (sqlite3_prepare_v2(db, [query7 UTF8String], -1, &statement7, nil) == SQLITE_OK) {
				if (sqlite3_step(statement7) == SQLITE_ROW) {
					int price = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement7, 0)] intValue];
					while (price > 0) {
						value = [value stringByAppendingString:@"$"];
						price--;
					}
					if (![value isEqualToString:@""]) {
						value = [[NSString alloc] initWithFormat:@"Price Rating: %@", value];
					}
				}
			}
            
            [listClubsArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:cID, @"id",
                                       cName, @"name",
                                       value, @"value", nil]];
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    
	sqlite3_finalize(statement4);
    
	//Obtaining attractions data for table
	sqlite3_stmt *statement8;
	NSString *query8 = [[NSString alloc] initWithFormat: @"SELECT name, attractions_id FROM attractions_db WHERE hotel_id = %@ ORDER BY name ASC;", workingId];
    
	if (sqlite3_prepare_v2(db, [query8 UTF8String], -1, &statement8, nil) == SQLITE_OK) {
		while (sqlite3_step(statement8) == SQLITE_ROW) {
			NSString *aName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement8, 0)];
			NSString *aID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement8, 1)];
            
			sqlite3_stmt *statement9;
			NSString *query9 = [[NSString alloc] initWithFormat: @"SELECT value FROM prices WHERE table_name = 'attractions_db' and table_id = %d;", [aID intValue]];
            
            NSString *value = @"";
            
			if (sqlite3_prepare_v2(db, [query9 UTF8String], -1, &statement9, nil) == SQLITE_OK) {
				if (sqlite3_step(statement9) == SQLITE_ROW) {
					int price = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement9, 0)] intValue];
					while (price > 0) {
						value = [value stringByAppendingString:@"$"];
						price--;
					}
					if (![value isEqualToString:@""]) {
						value = [[NSString alloc] initWithFormat:@"Price Rating: %@", value];
					}
				}
			}
            
            [listAttractionsArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:aID, @"id",
                                       aName, @"name",
                                       value, @"value", nil]];
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    //	sqlite3_finalize(statement6);
	sqlite3_finalize(statement8);
    
	//Obtaining sports data for table
	sqlite3_stmt *statement10;
	NSString *query10 = [[NSString alloc] initWithFormat: @"SELECT name, sports_id FROM sports_db WHERE hotel_id = %@ ORDER BY name ASC;", workingId];
    
	if (sqlite3_prepare_v2(db, [query10 UTF8String], -1, &statement10, nil) == SQLITE_OK) {
		while (sqlite3_step(statement10) == SQLITE_ROW) {
			NSString *s2Name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement10, 0)];
			NSString *s2ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement10, 1)];
            
			sqlite3_stmt *statement11;
			NSString *query11 = [[NSString alloc] initWithFormat: @"SELECT value FROM prices WHERE table_name = 'sports_db' and table_id = %d;", [s2ID intValue]];
            
            NSString *value = @"";
            
			if (sqlite3_prepare_v2(db, [query11 UTF8String], -1, &statement11, nil) == SQLITE_OK) {
				if (sqlite3_step(statement11) == SQLITE_ROW) {
					int price = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement11, 0)] intValue];
					while (price > 0) {
						value = [value stringByAppendingString:@"$"];
						price--;
					}
					if (![value isEqualToString:@""]) {
						value = [[NSString alloc] initWithFormat:@"Price Rating: %@", value];
					}
				}
			}
            
            [listSportsArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:s2ID, @"id",
                                             s2Name, @"name",
                                             value, @"value", nil]];
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    
    //	sqlite3_finalize(statement6);
	sqlite3_finalize(statement10);
    
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
    
	tblRest = [[UITableView alloc] init];
	tblShows = [[UITableView alloc] init];
	tblClubs = [[UITableView alloc] init];
    tblAttractions = [[UITableView alloc] init];
    tblSports = [[UITableView alloc] init];
	tblGallery = [[UITableView alloc] init];
	
	//Add map and call buttons
	if (![[[listHotelArray objectAtIndex:0] objectForKey:@"address1"] isEqualToString:@""]) {
		UIButton *map_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[map_button setFrame:CGRectMake(20, yaxis, 100, 40)];
		[map_button setTitle:@"Map" forState:UIControlStateNormal];
		[map_button addTarget:self action:@selector(openMap:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView addSubview:map_button];
	}
	
	if (![[[listHotelArray objectAtIndex:0] objectForKey:@"phone"] isEqualToString:@""]) {
		UIButton *call_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[call_button setFrame:CGRectMake(130, yaxis, 170, 40)];
		[call_button setTitle:[[listHotelArray objectAtIndex:0] objectForKey:@"phone"] forState:UIControlStateNormal];
		[call_button addTarget:self action:@selector(dialPhone:) forControlEvents:UIControlEventTouchUpInside];
		[scrollView addSubview:call_button];
	}
    
	if (![[[listHotelArray objectAtIndex:0] objectForKey:@"share"] isEqualToString:@""]){
        UIBarButtonItem *share_button = [[UIBarButtonItem alloc] initWithTitle:@""  style:UIBarButtonItemStylePlain target:self action:@selector(shareThis:)];
		UIImage *img = [UIImage imageNamed:@"shareBtn.png"];
		[share_button setImage:img];
		
		self.navigationItem.rightBarButtonItem = share_button;
	}
    
	if ((![[[listHotelArray objectAtIndex:0] objectForKey:@"address1"] isEqualToString:@""] && ![[[listHotelArray objectAtIndex:0] objectForKey:@"address2"] isEqualToString:@""]) || (![[[listHotelArray objectAtIndex:0] objectForKey:@"phone"] isEqualToString:@""])) {
		yaxis += 55;
	}
	
	
	//Add hotel information
	UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 25)];
	[name setTextColor:[UIColor whiteColor]];
	[name setBackgroundColor:[UIColor clearColor]];
	[name setText:[[listHotelArray objectAtIndex:0] objectForKey:@"name"]];
	[name setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
	[scrollView addSubview:name];
	yaxis += 18;
	
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
	[desc setText:[[listHotelArray objectAtIndex:0] objectForKey:@"description"]];
	[desc sizeToFit];
	[desc_background setFrame:CGRectMake(20, yaxis, 280, (desc.bounds.size.height + 10))];
	[desc_background addSubview:desc];
	[scrollView addSubview:desc_background];
    
	
	yaxis += (desc_background.bounds.size.height + 10);
	
	//table settings
	if ([listRestArray count] > 0) {
		//create title
		UILabel *lblRest = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 22)];
		[scrollView addSubview:lblRest];
		[lblRest setText:@"Restaurants"];
		[lblRest setTextColor:[UIColor whiteColor]];
		[lblRest setBackgroundColor:[UIColor clearColor]];
		[lblRest setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
		yaxis += 25;
        
		//create table
		tblRest.layer.cornerRadius = 10;
		tblRest.delegate = self;
		tblRest.dataSource = self;
		tblRest.tag = 1;
		[tblRest reloadData];
		int rHeight = tblRest.contentSize.height;
		tblRest.frame = CGRectMake(20, yaxis, 280, rHeight);
		yaxis += (rHeight + 10);
		[scrollView addSubview:tblRest];
	}
    
	if ([listShowsArray count] > 0) {
		//create title
		UILabel *lblShows = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 22)];
		[scrollView addSubview:lblShows];
		[lblShows setText:@"Shows"];
		[lblShows setTextColor:[UIColor whiteColor]];
		[lblShows setBackgroundColor:[UIColor clearColor]];
		[lblShows setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
		yaxis += 25;
        
		//create table
		tblShows.layer.cornerRadius = 10;
		tblShows.delegate = self;
		tblShows.dataSource = self;
		tblShows.tag = 2;
		[tblShows reloadData];
		int sHeight = tblShows.contentSize.height;
		tblShows.frame = CGRectMake(20, yaxis, 280, sHeight);
		yaxis += (sHeight + 10);
		[scrollView addSubview:tblShows];
	}
    
	if ([listClubsArray count] > 0) {
		//create title
		UILabel *lblClubs = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 22)];
		[scrollView addSubview:lblClubs];
		[lblClubs setText:@"Clubs"];
		[lblClubs setTextColor:[UIColor whiteColor]];
		[lblClubs setBackgroundColor:[UIColor clearColor]];
		[lblClubs setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
		yaxis += 25;
        
		//create table
		tblClubs.layer.cornerRadius = 10;
		tblClubs.delegate = self;
		tblClubs.dataSource = self;
		tblClubs.tag = 3;
		[tblClubs reloadData];
		int cHeight = tblClubs.contentSize.height;
		tblClubs.frame = CGRectMake(20, yaxis, 280, cHeight);
		yaxis += (cHeight + 10);
		[scrollView addSubview:tblClubs];
	}
    
	if ([listAttractionsArray count] > 0) {
		//create title
		UILabel *lblAttractions = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 22)];
		[scrollView addSubview:lblAttractions];
		[lblAttractions setText:@"Attractions"];
		[lblAttractions setTextColor:[UIColor whiteColor]];
		[lblAttractions setBackgroundColor:[UIColor clearColor]];
		[lblAttractions setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
		yaxis += 25;
        
		//create table
		tblAttractions.layer.cornerRadius = 10;
		tblAttractions.delegate = self;
		tblAttractions.dataSource = self;
		tblAttractions.tag = 4;
		[tblAttractions reloadData];
		int cHeight = tblAttractions.contentSize.height;
		tblAttractions.frame = CGRectMake(20, yaxis, 280, cHeight);
		yaxis += (cHeight + 10);
		[scrollView addSubview:tblAttractions];
	}
    
	if ([listSportsArray count] > 0) {
		//create title
		UILabel *lblSports = [[UILabel alloc] initWithFrame:CGRectMake(20, yaxis, 280, 22)];
		[scrollView addSubview:lblSports];
		[lblSports setText:@"Sports"];
		[lblSports setTextColor:[UIColor whiteColor]];
		[lblSports setBackgroundColor:[UIColor clearColor]];
		[lblSports setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:18]];
		yaxis += 25;
        
		//create table
		tblSports.layer.cornerRadius = 10;
		tblSports.delegate = self;
		tblSports.dataSource = self;
		tblSports.tag = 5;
		[tblSports reloadData];
		int cHeight = tblSports.contentSize.height;
		tblSports.frame = CGRectMake(20, yaxis, 280, cHeight);
		yaxis += (cHeight + 10);
		[scrollView addSubview:tblSports];
	}
	
	//scrollview settings
	scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkgTile.png"]];
	[self resize_scrollview_to_fit];
	
	//add scrollview with subviews
	[self.view addSubview:scrollView];
}

-(void)downloadImage:(id)image_path {
    NSString *urlString = [NSString stringWithFormat: @"http://www.vegashipster.com/%@",image_path];
    
    NSURL *imageURL = [NSURL URLWithString:urlString];
    
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    NSString *hotelsPath = [libraryDirectory stringByAppendingPathComponent:@"images/hotels"];
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
	
	NSScanner *phoneScanner = [NSScanner scannerWithString:[[listHotelArray objectAtIndex:0] objectForKey:@"phone"]];
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
	NSString *NSURLString = [[NSString alloc] initWithFormat:@"http://www.vegashipster.com/mobile.php?action=gallery_count&type=hotelId&id=%@", workingId];
    
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
		return [listRestArray count];
	}else if (tableView.tag == 2) {
		return [listShowsArray count];
	}else if (tableView.tag == 3) {
		return [listClubsArray count];
	}else if (tableView.tag == 4) {
		return [listAttractionsArray count];
	}else if (tableView.tag == 5) {
		return [listSportsArray count];
	}else if (tableView.tag == 6) {
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
		cell.textLabel.text = [[listRestArray objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.detailTextLabel.text = [[listRestArray objectAtIndex:indexPath.row] objectForKey:@"value"];
	}
	else if (tableView.tag == 2) {
		cell.textLabel.text = [[listShowsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.detailTextLabel.text = [[listShowsArray objectAtIndex:indexPath.row] objectForKey:@"value"];
	}
	else if (tableView.tag == 3) {
		cell.textLabel.text = [[listClubsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.detailTextLabel.text = [[listClubsArray objectAtIndex:indexPath.row] objectForKey:@"value"];
	}
	else if (tableView.tag == 4) {
		cell.textLabel.text = [[listAttractionsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.detailTextLabel.text = [[listAttractionsArray objectAtIndex:indexPath.row] objectForKey:@"value"];
        NSLog(@"%@",[[listAttractionsArray objectAtIndex:indexPath.row] objectForKey:@"name"]);
	}
	else if (tableView.tag == 5) {
		cell.textLabel.text = [[listSportsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.detailTextLabel.text = [[listSportsArray objectAtIndex:indexPath.row] objectForKey:@"value"];
	}
	else if (tableView.tag == 6) {
		cell.textLabel.text = @"Photo Gallery";
		cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d images", gallery_count];
	}
    
	cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
	cell.detailTextLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    
	if (tableView.tag == 6){
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
    }else if (tableView == tblRest) {
        [self performSegueWithIdentifier:@"RestaurantDetailsPushSegue" sender:self];
    }else if (tableView == tblShows) {
        [self performSegueWithIdentifier:@"ShowsDetailsPushSegue" sender:self];
    }else if (tableView == tblClubs) {
        [self performSegueWithIdentifier:@"ClubsDetailsPushSegue" sender:self];
    }else if (tableView == tblAttractions) {
        [self performSegueWithIdentifier:@"AttractionsDetailsPushSegue" sender:self];
    }else if (tableView == tblSports) {
        [self performSegueWithIdentifier:@"SportsDetailsPushSegue" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tblGallery) {
        [self performSegueWithIdentifier:@"GalleryPushSegue" sender:self];
    }else if (tableView == tblRest) {
        [self performSegueWithIdentifier:@"RestaurantDetailsPushSegue" sender:self];
    }else if (tableView == tblShows) {
        [self performSegueWithIdentifier:@"ShowsDetailsPushSegue" sender:self];
    }else if (tableView == tblClubs) {
        [self performSegueWithIdentifier:@"ClubsDetailsPushSegue" sender:self];
    }else if (tableView == tblAttractions) {
        [self performSegueWithIdentifier:@"AttractionsDetailsPushSegue" sender:self];
    }else if (tableView == tblSports) {
        [self performSegueWithIdentifier:@"SportsDetailsPushSegue" sender:self];
    }
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"pushMapView"]) {
        //add pin for current hotel
        NSString *hotel_add1 = [[[listHotelArray objectAtIndex:0] objectForKey:@"address1"] stringByReplacingOccurrencesOfString:@"." withString:@""];
        hotel_add1 = [hotel_add1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
        hotel_add1 = [hotel_add1 stringByReplacingOccurrencesOfString:@"," withString:@""];
        hotel_add1 = [hotel_add1 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *hotel_add2 = [[[listHotelArray objectAtIndex:0] objectForKey:@"address2"] stringByReplacingOccurrencesOfString:@"." withString:@""];
        hotel_add2 = [hotel_add2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
        hotel_add2 = [hotel_add2 stringByReplacingOccurrencesOfString:@"," withString:@""];
        hotel_add2 = [hotel_add2 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *theUrl = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps/geo?q=%@+%@&output=csv", hotel_add1, hotel_add2];
        
        // Get reference to the destination view controller
        VH_MapViewController *vc = [segue destinationViewController];
        
        [vc setWorkingVariables:@"hotel_db" withIdentifier:@"hotel_id" withId:workingId withUrl:theUrl];
    }else if ([[segue identifier] isEqualToString:@"GalleryPushSegue"]) {
        // Get reference to the destination view controller
        VH_GalleryViewController *vc = [segue destinationViewController];
        
        [vc setVenueType:@"hotelId" andtypeId:workingId];
    }else if ([[segue identifier] isEqualToString:@"RestaurantDetailsPushSegue"]) {
        // Get reference to the destination view controller
        VH_RestaurantDetailsViewController *vc = [segue destinationViewController];
        
        // get the selected index
        NSInteger selectedIndex = [[tblRest indexPathForSelectedRow] row];
        
        [vc setTheWorkingId:[[listRestArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }else if ([[segue identifier] isEqualToString:@"ShowsDetailsPushSegue"]) {
        // Get reference to the destination view controller
        VH_ShowsDetailsViewController *vc = [segue destinationViewController];
        
        // get the selected index
        NSInteger selectedIndex = [[tblShows indexPathForSelectedRow] row];
        
        [vc setTheWorkingId:[[listShowsArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }else if ([[segue identifier] isEqualToString:@"ClubsDetailsPushSegue"]) {
        // Get reference to the destination view controller
        VH_ClubsDetailsViewController *vc = [segue destinationViewController];
        
        // get the selected index
        NSInteger selectedIndex = [[tblClubs indexPathForSelectedRow] row];
        
        [vc setTheWorkingId:[[listClubsArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }else if ([[segue identifier] isEqualToString:@"AttractionsDetailsPushSegue"]) {
        // Get reference to the destination view controller
        VH_AttractionsDetailsViewController *vc = [segue destinationViewController];
        
        // get the selected index
        NSInteger selectedIndex = [[tblAttractions indexPathForSelectedRow] row];
        
        [vc setTheWorkingId:[[listAttractionsArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }else if ([[segue identifier] isEqualToString:@"SportsDetailsPushSegue"]) {
        // Get reference to the destination view controller
        VH_SportsDetailsViewController *vc = [segue destinationViewController];
        
        // get the selected index
        NSInteger selectedIndex = [[tblSports indexPathForSelectedRow] row];
        
        [vc setTheWorkingId:[[listSportsArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }
}

- (void)shareThis:(id)sender {
    //Show addthis menu
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
    
    linkUrl = [NSString stringWithFormat:@"http://www.vegashipster.com/hotel/%@.php",[[listHotelArray objectAtIndex:0] objectForKey:@"linkname"]];
	linkTitle = [NSString stringWithFormat:@"You should check out %@!",[[listHotelArray objectAtIndex:0] objectForKey:@"name"]];
    
    [AddThisSDK setFavoriteMenuServices:@"facebook",@"twitter",nil];
    
    [AddThisSDK setAddThisPubId:@"ra-51ffe583468b203f"];
    
    [AddThisSDK presentAddThisMenuForURL:linkUrl withTitle:linkTitle description:@"Check out this hotel I've found using Vegas Hipster's iPhone app!"];
}
@end