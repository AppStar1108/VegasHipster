//
//  VH_HotelsListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_HotelsListViewController.h"

@interface VH_HotelsListViewController ()

@end

@implementation VH_HotelsListViewController

- (void)build_user_interface {
    [tblView reloadData];
    CGRect frame = CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, tblView.frame.size.width, tblView.contentSize.height);
    tblView.frame = frame;
    [tblView reloadData];
    
    CGRect contentRect = CGRectZero;
    contentRect = CGRectUnion(contentRect, imageView.frame);
    contentRect = CGRectUnion(contentRect, tblView.frame);
    
    contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, 320, contentRect.size.height);
    
    [scrollView setContentSize:contentRect.size];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    cur_page = 1;
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:scrollView];
    }
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 150)];
        imageView.image = [UIImage imageNamed:@"hdrHotels.jpg"];
        [scrollView addSubview:imageView];
    }
    
    if (!tblView) {
        tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, 320, 500) style:UITableViewStyleGrouped];
        tblView.dataSource = self;
        tblView.delegate = self;
        tblView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:tblView];
    }
    
	[self get_table_data];
    
    if (!showSplashView) {
        showSplashView = YES;
        [self showSplashScreen];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect frame = CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, tblView.frame.size.width, tblView.contentSize.height);
    //tblView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tblView.frame = frame;
	//[tblView setFrame:frame];
    [tblView reloadData];
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in scrollView.subviews)
        contentRect = CGRectUnion(contentRect, view.frame);
    
    contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, 320, contentRect.size.height);
    
    [scrollView setContentSize:contentRect.size];
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
    
    [tblView removeFromSuperview];
    [imageView removeFromSuperview];
    [scrollView removeFromSuperview];
    
    tblView = nil;
    imageView = nil;
    scrollView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)get_table_data {
	//initialize arrays that hold table data
	listArray = [[NSMutableArray alloc] init];
    
    //path to database file
    NSString *databaseName = @"vhipsterdb.sqlite";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    //NSLog(@"Database Path: %@", databasePath);
    
	//open and initialize database
	sqlite3 *db;
    
    if(sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK){
        //NSLog(@"Opened");
    }else{
        //NSLog(@"Not Opened");
    }
    
	sqlite3_stmt *statement;
    NSString *query = [NSString stringWithFormat:@"SELECT count(*) as count FROM hotel_db JOIN prices ON hotel_db.hotel_id = prices.table_id WHERE prices.table_name = 'hotel_db';"];
    
    BOOL results = false;
    
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //NSLog(@"Database Connected For Search Query");
        
        [listArray removeAllObjects];
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
            results = true;
			page_count = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)] intValue];
			page_count = (page_count + 50 -1) / 50;
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    
    //NSLog(@"Total Results: %d", [listOfIds count]);
    
	sqlite3_finalize(statement);
    
	int start = (cur_page * 50) - 50;
	
	//Obtaining data for display
	sqlite3_stmt *statement2;
	query = [[NSString alloc] initWithFormat:@"SELECT hotel_db.hotel_id, hotel_db.name, prices.value FROM hotel_db JOIN prices ON hotel_db.hotel_id = prices.table_id WHERE prices.table_name = 'hotel_db' ORDER BY hotel_db.name ASC Limit %d, 50;", start];
    
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement2, nil) == SQLITE_OK) {
        //NSLog(@"Database Connected For Search Query");
        
        [listArray removeAllObjects];
        
        if (cur_page != 1){
            NSLog(@"%d", cur_page);
            [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Previous", @"id",
                                  @"Previous...", @"name",
                                  @"", @"price", nil]];
		}
        
		while (sqlite3_step(statement2) == SQLITE_ROW) {
            //NSLog(@"ID: %@", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 0)]);
            results = true;
            
			NSString *hId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 0)];
			NSString *hName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 1)];
			int price = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 2)] intValue];
			NSString *value = @"";
			while (price > 0) {
				value = [value stringByAppendingString:@"$"];
				price--;
			}
			if (![value isEqualToString:@""]) {
				value = [[NSString alloc] initWithFormat:@"Price Rating: %@", value];
			}
			
            [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:hId, @"id",
                                   hName, @"name",
                                   value, @"value", nil]];
		}
        
		NSLog(@"Page Count: %d \n Current Page: %d",page_count,cur_page);
		if (cur_page != page_count){
            [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Next", @"id",
                                  @"More...", @"name",
                                  @"", @"price", nil]];
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    
    //NSLog(@"Total Results: %d", [listOfIds count]);
    
	sqlite3_finalize(statement2);
    
    if (!results){
        NSLog(@"No results found");
    }else {
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [listArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
	}
	
	// Configure the cell...
	cell.textLabel.text = [[listArray objectAtIndex:indexPath.row] objectForKey:@"name"];
	cell.detailTextLabel.text = [[listArray objectAtIndex:indexPath.row] objectForKey:@"value"];
	cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
	cell.detailTextLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pagination = [[listArray objectAtIndex:[indexPath row]] objectForKey:@"id"];
	
    if ([pagination isEqualToString:@"Previous"]){
		cur_page = cur_page - 1;
		
		[self get_table_data];
		[self build_user_interface];
        
        [scrollView setContentOffset:CGPointMake(0, scrollView.contentSize.height - self.view.frame.size.height) animated:YES];
	}else if ([pagination isEqualToString:@"Next"]){
		cur_page = cur_page + 1;
		
		[self get_table_data];
		[self build_user_interface];
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
	}else{
        [self performSegueWithIdentifier:@"HotelsDetailsViewSegue" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSString *pagination = [[listArray objectAtIndex:[indexPath row]] objectForKey:@"id"];
	
    if ([pagination isEqualToString:@"Previous"]){
		cur_page = cur_page - 1;
		
		[self get_table_data];
		[self build_user_interface];
        
        [scrollView setContentOffset:CGPointMake(0, scrollView.contentSize.height - self.view.frame.size.height) animated:YES];
	}else if ([pagination isEqualToString:@"Next"]){
		cur_page = cur_page + 1;
		
		[self get_table_data];
		[self build_user_interface];
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
	}else{
        [self performSegueWithIdentifier:@"HotelsDetailsViewSegue" sender:self];
    }
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"HotelsDetailsViewSegue"]) {
        
        // Get reference to the destination view controller
        VH_HotelsDetailsViewController *vc = [segue destinationViewController];
        
        
        // get the selected index
        NSInteger selectedIndex = [[tblView indexPathForSelectedRow] row];
        
        
        // Pass the name and index of our film
        //NSLog(@"%@", [[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]);
        [vc setTheWorkingId:[[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }
}

// Method implementations
- (void) hideTabBar:(UITabBarController *) tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    float fHeight = screenRect.size.height;
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width;
    }
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
    [UIView commitAnimations];
}



- (void) showTabBar:(UITabBarController *) tabbarcontroller
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - tabbarcontroller.tabBar.frame.size.height;
    
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width - tabbarcontroller.tabBar.frame.size.height;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
    [UIView commitAnimations];
}

-(void)showSplashScreen {
    [self hideTabBar:self.tabBarController];
    [self.navigationController setNavigationBarHidden:YES];
    
    splashView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    splashView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bkgSplash.png"]];
    
	//create frame
	CGRect frame = CGRectMake(0, 0, 320, 480);
    
    //create dice subimage
	UIImageView *dice = [[UIImageView alloc] initWithFrame:frame];
	dice.frame = CGRectMake(110, 165, 206, 166);
	dice.image = [UIImage imageNamed:@"dice.png"];
	[splashView addSubview:dice];
	
	//animate dice subimage
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationDuration:0.5];
    dice.transform = CGAffineTransformMakeScale(1.1,1.1);
    [UIView commitAnimations];
	
	//create buttons
	UIButton *hotels = [UIButton buttonWithType:UIButtonTypeCustom];
	hotels.tag = 1;
	[hotels addTarget:self action:@selector(gotoview:) forControlEvents:UIControlEventTouchUpInside];
	UIButton *dining = [UIButton buttonWithType:UIButtonTypeCustom];
	dining.tag = 2;
	[dining addTarget:self action:@selector(gotoview:) forControlEvents:UIControlEventTouchUpInside];
	UIButton *shows = [UIButton buttonWithType:UIButtonTypeCustom];
	shows.tag = 3;
	[shows addTarget:self action:@selector(gotoview:) forControlEvents:UIControlEventTouchUpInside];
	UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
	more.tag = 4;
	[more addTarget:self action:@selector(gotoview:) forControlEvents:UIControlEventTouchUpInside];
	
	//set button positions
	hotels.frame = CGRectMake(-10, 305, 96, 107);
	dining.frame = CGRectMake(72, 315, 96, 103);
	shows.frame = CGRectMake(152, 315, 96, 103);
	more.frame = CGRectMake(233, 305, 96, 107);
	
	//set button images
	[hotels setBackgroundImage:[UIImage imageNamed:@"btn01Hotels.png"] forState:UIControlStateNormal];
	[dining setBackgroundImage:[UIImage imageNamed:@"btn02Dining.png"] forState:UIControlStateNormal];
	[shows setBackgroundImage:[UIImage imageNamed:@"btn03Shows.png"] forState:UIControlStateNormal];
	[more setBackgroundImage:[UIImage imageNamed:@"btn04More.png"] forState:UIControlStateNormal];
	
	//add button to views
	[splashView addSubview:hotels];
	[splashView addSubview:dining];
	[splashView addSubview:shows];
	[splashView addSubview:more];
    
    [self.view addSubview:splashView];
	
    [self checkVersion];
}

- (IBAction)gotoview:(UIButton *)sender {
    [self showTabBar:self.tabBarController];
    [self.navigationController setNavigationBarHidden:NO];
    
	if (sender.tag == 1) {
        NSLog(@"Tag 1");
        [self.tabBarController setSelectedIndex:0];
	}else if(sender.tag == 2) {
        NSLog(@"Tag 2");
        [self.tabBarController setSelectedIndex:1];
	}else if(sender.tag == 3) {
        NSLog(@"Tag 3");
        [self.tabBarController setSelectedIndex:2];
	}else if(sender.tag == 4) {
        NSLog(@"Tag 4");
        [self.tabBarController setSelectedIndex:4];
	}
    
    [splashView removeFromSuperview];
}

- (void) checkVersion {
    NSString *myRawJson;
    
    // Get data from the web
    NSURL *url = [NSURL URLWithString:@"http://vegashipster.com/mobile.php?new_app=1&action=get_vers"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil) {
        myRawJson = [[NSString alloc] initWithData:result encoding:
                     NSASCIIStringEncoding];
        NSLog(@"Result: %@", myRawJson);
    }else{
        NSLog(@"Error: %@", error);
    }
    
    // If there was no data received return and do nothing else
    if ([myRawJson length] == 0) {
        myRawJson = nil;
        return;
    }
    
    // Start parsing the json
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    parsedJson = [[parser objectWithString:myRawJson] copy];
    
    parser = nil;
	
	//path to database file
	NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
	
	//open and initialize database
	sqlite3 *db;
	sqlite3_open([databasePath UTF8String], &db);
	
	//Obtaining hotel data for display
	sqlite3_stmt *statement;
	NSString *query = @"SELECT vers_id FROM db_vers limit 1;";
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *vers = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			
			float my_vers = [vers floatValue];
            
            NSLog(@"%@", parsedJson);
			
			NSString *vers_id = [parsedJson objectForKey:@"vers_id"];
			
			float cur_vers = [vers_id floatValue];
			
			if (cur_vers > my_vers){
				alertWithYesNoButtons = [[UIAlertView alloc] initWithTitle:@"Database Update"
																   message:@"There is a database update available, which could take up to 6 minutes.  Download now?"
																  delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
				
				[alertWithYesNoButtons show];
			}
		}
	}else{
		NSLog(@"Error with if statement.");
	}
	sqlite3_finalize(statement);
}

- (void)alertView : (UIAlertView *)alertView clickedButtonAtIndex : (NSInteger)buttonIndex {
	if(alertView == alertWithYesNoButtons){
		if(buttonIndex == 0){
			NSLog(@"no button was pressed\n");
		}else{
			NSLog(@"yes button was pressed\n");
            
            [self showTabBar:self.tabBarController];
            [self.navigationController setNavigationBarHidden:NO];
            
            [splashView removeFromSuperview];
			
            [self performSegueWithIdentifier:@"pushUpdateViewController" sender:self];
		}
	}
}

@end
