//
//  VH_SportsSubListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_SportsSubListViewController.h"

@interface VH_SportsSubListViewController ()

@end

@implementation VH_SportsSubListViewController
@synthesize categoryType;

- (void)getTypeId:(NSString *)type {
    categoryType = type;
}

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
    
	//initialize arrays that hold table data
	listArray = [[NSMutableArray alloc] init];
    
    cur_page = 1;
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:scrollView];
    }
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 150)];
        imageView.image = [UIImage imageNamed:@"hdrSports.jpg"];
        [scrollView addSubview:imageView];
    }
    
    if (!tblView) {
        tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, 320, 500) style:UITableViewStyleGrouped];
        tblView.dataSource = self;
        tblView.delegate = self;
        [scrollView addSubview:tblView];
    }
    
	[self get_table_data];
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
	
	//Obtaining data for display
	sqlite3_stmt *statement;
	NSString *query;
    
    if ([categoryType isEqualToString:@"4"]) {
        query = [[NSString alloc] initWithFormat:@"Select count(*) as count From sports_db"];
	}else{
        query = [[NSString alloc] initWithFormat:@"Select count(*) as count From sports_db Where sports_id In (SELECT sports_db.sports_id FROM sports_db WHERE sports_db.type = %@)", categoryType];
    }
    
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
    
    sqlite3_stmt *statement2;
    
    NSString *query2 = [[NSString alloc] init];
        
    if ([categoryType isEqualToString:@"4"]) {
        query2 = [NSString stringWithFormat:@"SELECT sports_db.sports_id, sports_db.name FROM sports_db ORDER BY sports_db.name ASC Limit %d, 50;", start];
	}else{
        query2 = [NSString stringWithFormat:@"SELECT sports_db.sports_id, sports_db.name FROM sports_db  WHERE sports_db.type = %@ ORDER BY sports_db.name ASC Limit %d, 50;", categoryType, start];
    }
    
	if (sqlite3_prepare_v2(db, [query2 UTF8String], -1, &statement2, nil) == SQLITE_OK) {
        //NSLog(@"Database Connected For Search Query");
        
        [listArray removeAllObjects];
        
        if (cur_page != 1){
            [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Previous", @"id",
                                  @"Previous...", @"name",
                                  @"", @"price", nil]];
		}
        
		while (sqlite3_step(statement2) == SQLITE_ROW) {
            NSString *int_row = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 0)];
			NSString *rName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 1)];
			
            [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:int_row, @"id",
                                  rName, @"name",
                                  @"", @"price", nil]];
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
	cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
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
        [self performSegueWithIdentifier:@"SportsDetailsPushSegue" sender:self];
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
        [self performSegueWithIdentifier:@"SportsDetailsPushSegue" sender:self];
	}
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"SportsDetailsPushSegue"]) {
        // Get reference to the destination view controller
        VH_SportsDetailsViewController *vc = [segue destinationViewController];
        
        
        // get the selected index
        NSInteger selectedIndex = [[tblView indexPathForSelectedRow] row];
        
        
        // Pass the name and index of our film
        //NSLog(@"%@", [[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]);
        [vc setTheWorkingId:[[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }
}

@end
