//
//  VH_FriendListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_FriendListViewController.h"

@interface VH_FriendListViewController ()

@end

@implementation VH_FriendListViewController

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSString *lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
    NSString *string_url = [NSString stringWithFormat:@"http://www.vegashipster.com/mobile.php?action=send_coords&lat=%f&long=%f&gnum=%@&uid=%@", [lat floatValue], [longitude floatValue], [[listArray objectAtIndex:0] objectForKey:@"group_num"], [[listArray objectAtIndex:0] objectForKey:@"user_id"]];
    NSLog(@"URL: %@", string_url);
    NSURL * url = [NSURL URLWithString:string_url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    if ([[NSURLConnection alloc] initWithRequest:request delegate:nil]) {
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    UIImage *settingsImg = [UIImage imageNamed:@"cogwheel_3.png"];
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsBtn.bounds = CGRectMake( 0, 0, settingsImg.size.width, settingsImg.size.height );
    [settingsBtn setImage:settingsImg forState:UIControlStateNormal];
    UIBarButtonItem *settingsNavBtn = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
    self.navigationItem.rightBarButtonItem = settingsNavBtn;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:scrollView];
    }
    
    if ([self get_table_data]) {
        if (!tblView) {
            tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height - 100) style:UITableViewStyleGrouped];
            tblView.dataSource = self;
            tblView.delegate = self;
            tblView.backgroundColor = [UIColor clearColor];
            tblView.backgroundView = nil;
            [scrollView addSubview:tblView];
        }
        
        if (titleLbl) {
            [titleLbl removeFromSuperview];
            titleLbl = nil;
        }
        
        if (messageLbl) {
            [messageLbl removeFromSuperview];
            messageLbl = nil;
        }
    }else{
        if (!titleLbl) {
            titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 280, 70)];
            [titleLbl setTextColor:[UIColor whiteColor]];
            [titleLbl setBackgroundColor:[UIColor clearColor]];
            [titleLbl setText:@"You are not part of any groups."];
            [titleLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:28]];
            titleLbl.lineBreakMode = UILineBreakModeWordWrap;
            titleLbl.numberOfLines = 0;
            titleLbl.textAlignment = UITextAlignmentCenter;
            [scrollView addSubview:titleLbl];
        }
        
        if (!messageLbl) {
            messageLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 280, 75)];
            [messageLbl setTextColor:[UIColor whiteColor]];
            [messageLbl setBackgroundColor:[UIColor clearColor]];
            [messageLbl setText:@"Use the buttons below to create or join a group to see where friends and family are in the park."];
            [messageLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:16]];
            messageLbl.lineBreakMode = UILineBreakModeWordWrap;
            messageLbl.numberOfLines = 0;
            messageLbl.textAlignment = UITextAlignmentCenter;
            [scrollView addSubview:messageLbl];
        }
        
        if (tblView) {
            [tblView removeFromSuperview];
            tblView = nil;
        }
    }
    
    if (!createBtn) {
        createBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [createBtn setFrame:CGRectMake(10, self.view.bounds.size.height - 80, 140, 60)];
        [createBtn setTitle:@"Create a Group" forState: (UIControlState)UIControlStateNormal];
        [createBtn addTarget:self action:@selector(createGroup:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:createBtn];
    }
    
    if (!joinBtn) {
        joinBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [joinBtn setFrame:CGRectMake(170, self.view.bounds.size.height - 80, 140, 60)];
        [joinBtn setTitle:@"Join a Group" forState: (UIControlState)UIControlStateNormal];
        [joinBtn addTarget:self action:@selector(joinGroup:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:joinBtn];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tblView reloadData];
    
    //CGRect frame = CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, tblView.frame.size.width, tblView.contentSize.height);
    //tblView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //tblView.frame = frame;
	//[tblView setFrame:frame];
    //[tblView reloadData];
    
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
    [scrollView removeFromSuperview];
    
    tblView = nil;
    scrollView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (bool)get_table_data {
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
    
    bool results = false;
    
    if(sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK){
        //NSLog(@"Opened");
    }else{
        //NSLog(@"Not Opened");
    }
	
	//Obtaining data for display
	sqlite3_stmt *statement;
	NSString *query = @"SELECT user_id, group_num, group_name FROM ff_group;";
    //NSLog(@"Query: %@", query);
    
	if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //NSLog(@"Database Connected For Search Query");
        
        [listArray removeAllObjects];
        
        bool process = NO;
        
		while (sqlite3_step(statement) == SQLITE_ROW) {
            process = YES;
            //NSLog(@"ID: %@", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]);
            results = true;
            
			NSString *user_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			NSString *group_num = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *group_name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			
            [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:user_id, @"user_id",
                                  group_num, @"group_num",
                                  group_name, @"group_name", nil]];
		}
        
        if (process) {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [locationManager startUpdatingLocation];
        }
	}else{
        //NSLog(@"Can't connect to the db...");
        NSLog(@"Database Error = %s", sqlite3_errmsg(db));
    }
    
    //NSLog(@"Total Results: %d", [listOfIds count]);
    
	sqlite3_finalize(statement);
    
    if (!results){
        NSLog(@"No results found");
    }
    
    return results;
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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}
	
	// Configure the cell...
	cell.textLabel.text = [[listArray objectAtIndex:indexPath.row] objectForKey:@"group_name"];
	cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
	cell.detailTextLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"pushFriendGroupView" sender:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"pushFriendGroupView" sender:self];
}

- (void) createGroup:(id)sender {
    [self performSegueWithIdentifier:@"pushCreateGroupView" sender:self];
}

- (void) joinGroup:(id)sender {
    [self performSegueWithIdentifier:@"pushJoinGroupView" sender:self];
}

- (void) showSettings:(id)sender {
    [self performSegueWithIdentifier:@"pushFriendSettingsView" sender:self];
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"pushFriendGroupView"]) {
        // Get reference to the destination view controller
        VH_GroupViewController *vc = [segue destinationViewController];
        
        
        // get the selected index
        NSInteger selectedIndex = [[tblView indexPathForSelectedRow] row];
        
        
        // Pass the name and index of our film
        NSLog(@"%@", [[listArray objectAtIndex:selectedIndex] objectForKey:@"group_num"]);
        [vc setTheWorkingId:[[listArray objectAtIndex:selectedIndex] objectForKey:@"group_num"] forUser:[[listArray objectAtIndex:selectedIndex] objectForKey:@"user_id"]];
    }
}

@end
