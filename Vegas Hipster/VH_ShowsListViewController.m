//
//  VH_ShowsListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_ShowsListViewController.h"

@interface VH_ShowsSubListViewController ()

@end

@implementation VH_ShowsListViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor clearColor];
    
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
	
	//Obtaining data for display
	sqlite3_stmt *statement;
	NSString *query = [[NSString alloc] initWithFormat:@"SELECT show_type_id, type FROM show_type_db ORDER BY type ASC;"];
    
    BOOL results = false;
    
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //NSLog(@"Database Connected For Search Query");
        
        [listArray removeAllObjects];
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
            //NSLog(@"ID: %@", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]);
            results = true;
            
			NSString *typeId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *typeName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			
            [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:typeId, @"id",
                                   typeName, @"name", nil]];
		}
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    
    //NSLog(@"Total Results: %d", [listOfIds count]);
    
	sqlite3_finalize(statement);
    
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
    [self performSegueWithIdentifier:@"ShowsSubListPushSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ShowsSubListPushSegue" sender:self];
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowsSubListPushSegue"]) {
        
        // Get reference to the destination view controller
        VH_ShowsSubListViewController *vc = [segue destinationViewController];
        
        
        // get the selected index
        NSInteger selectedIndex = [[tblView indexPathForSelectedRow] row];
        
        
        // Pass the name and index of our film
        //NSLog(@"%@", [[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]);
        [vc getShowType:[[listArray objectAtIndex:selectedIndex] objectForKey:@"id"]];
    }
}

@end
