//
//  VH_ShowsSubListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_ShowsSubListViewController.h"

@interface VH_ShowsSubListViewController ()

@end

@implementation VH_ShowsSubListViewController
@synthesize showType;

- (void)getShowType:(NSString *)type {
    showType = type;
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
        imageView.image = [UIImage imageNamed:@"hdrShows.jpg"];
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
    
    if ([showType isEqualToString:@"6"]) {
        query = [[NSString alloc] initWithFormat:@"Select count(*) as count From shows_db Where shows_id In (SELECT shows_db.shows_id FROM shows_db JOIN prices ON shows_db.shows_id = prices.table_id WHERE prices.table_name = 'shows_db'  ORDER BY shows_db.name ASC)"];
	}else{
        query = [[NSString alloc] initWithFormat:@"Select count(*) as count From shows_db Where shows_id In (SELECT shows_db.shows_id FROM shows_db JOIN prices ON shows_db.shows_id = prices.table_id WHERE shows_db.type = %@ And prices.table_name = 'shows_db'  ORDER BY shows_db.name ASC)", showType];
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
        
    if ([showType isEqualToString:@"6"]) {
        query2 = [NSString stringWithFormat:@"SELECT shows_db.shows_id, shows_db.name, prices.value FROM shows_db JOIN prices ON shows_db.shows_id = prices.table_id WHERE prices.table_name = 'shows_db'  ORDER BY shows_db.name ASC Limit %d, 50;", start];
	}else{
        query2 = [NSString stringWithFormat:@"SELECT shows_db.shows_id, shows_db.name, prices.value FROM shows_db JOIN prices ON shows_db.shows_id = prices.table_id WHERE shows_db.type = %@ And prices.table_name = 'shows_db'  ORDER BY shows_db.name ASC Limit %d, 50;", showType, start];
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
			int price = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 2)] intValue];
			NSString *value = [[NSString alloc] init];
			while (price > 0) {
				value = [value stringByAppendingString:@"$"];
				price--;
			}
			if (![value isEqualToString:@""]) {
				value = [[NSString alloc] initWithFormat:@"Price Rating: %@", value];
			}
			
            [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:int_row, @"id",
                                  rName, @"name",
                                  value, @"price", nil]];
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
	cell.detailTextLabel.text = [[listArray objectAtIndex:indexPath.row] objectForKey:@"price"];
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
        [self performSegueWithIdentifier:@"ShowsDetailsPushSegue" sender:self];
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
        [self performSegueWithIdentifier:@"ShowsDetailsPushSegue" sender:self];
	}
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowsDetailsPushSegue"]) {
        // Get reference to the destination view controller
        VH_ShowsDetailsViewController *vc = [segue destinationViewController];
        
        
        // get the selected index
        NSInteger selectedIndex = [[tblView indexPathForSelectedRow] row];
        
        
        // Pass the name and index of our film
        //NSLog(@"%@", [[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]);
        [vc setTheWorkingId:[[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }
}

@end
