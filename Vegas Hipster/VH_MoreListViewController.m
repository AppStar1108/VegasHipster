//
//  VH_AttractionsListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_MoreListViewController.h"

@interface VH_MoreListViewController ()

@end

@implementation VH_MoreListViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:scrollView];
    }
    
    if (!tblView) {
        tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 500) style:UITableViewStylePlain];
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
    [scrollView removeFromSuperview];
    
    tblView = nil;
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
    
    //These are static objects
    [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"0", @"id",
                          @"Attractions", @"name",
                          @"iconAttractions.png", @"image",
                          @"pushAttractionsViewController", @"segue", nil]];
    [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1", @"id",
                          @"Sports", @"name",
                          @"iconSports.png", @"image",
                          @"pushSportsViewController", @"segue", nil]];
    [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"2", @"id",
                          @"Taxi Cabs", @"name",
                          @"iconTaxi.png", @"image",
                          @"pushTaxiViewController", @"segue", nil]];
    [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"3", @"id",
                          @"Blog", @"name",
                          @"iconBlog.png", @"image",
                          @"pushBlogViewController", @"segue", nil]];
    [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"4", @"id",
                          @"Friend Finder", @"name",
                          @"iconFriend.png", @"image",
                          @"pushFriendViewController", @"segue", nil]];
    [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"5", @"id",
                          @"Comment or Corrections", @"name",
                          @"iconContact.png", @"image",
                          @"pushContactViewController", @"segue", nil]];
    [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"6", @"id",
                          @"About Us / FAQ", @"name",
                          @"iconAbout.png", @"image",
                          @"pushAboutViewController", @"segue", nil]];
    [listArray addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"7", @"id",
                          @"Update", @"name",
                          @"iconUpdate.png", @"image",
                          @"pushUpdateViewController", @"segue", nil]];
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
    cell.imageView.image = [UIImage imageNamed:[[listArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
	cell.textLabel.text = [[listArray objectAtIndex:indexPath.row] objectForKey:@"name"];
	cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:[[listArray objectAtIndex:indexPath.row] objectForKey:@"segue"] sender:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:[[listArray objectAtIndex:indexPath.row] objectForKey:@"segue"] sender:self];
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"AttractionsSubListPushSegue"]) {
    }
}

@end
