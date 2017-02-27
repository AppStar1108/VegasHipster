//
//  VH_GroupViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_GroupViewController.h"

@interface VH_GroupViewController ()

@end

@implementation VH_GroupViewController
@synthesize workingId;
@synthesize workingUserId;

- (void)setTheWorkingId:(NSString *)newId forUser:(NSString *)userId {
    workingId = newId;
    workingUserId = userId;
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
    
    if (!emailpinBtn) {
        emailpinBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [emailpinBtn setFrame:CGRectMake(10, 10, 140, 40)];
        [emailpinBtn setTitle:@"Email Pin" forState: (UIControlState)UIControlStateNormal];
        [emailpinBtn addTarget:self action:@selector(email_pin:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:emailpinBtn];
    }
    
    if (!pinLbl) {
        pinLbl = [[UILabel alloc] initWithFrame:CGRectMake(170, 10, 140, 40)];
        [pinLbl setTextColor:[UIColor whiteColor]];
        [pinLbl setBackgroundColor:[UIColor clearColor]];
        [pinLbl setText:workingId];
        [pinLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:28]];
        pinLbl.lineBreakMode = UILineBreakModeWordWrap;
        pinLbl.numberOfLines = 0;
        pinLbl.textAlignment = UITextAlignmentCenter;
        [scrollView addSubview:pinLbl];
    }
    
    if (!tblView) {
        tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320, self.view.bounds.size.height - 60) style:UITableViewStyleGrouped];
        tblView.dataSource = self;
        tblView.delegate = self;
        tblView.backgroundColor = [UIColor clearColor];
        tblView.backgroundView = nil;
        [scrollView addSubview:tblView];
    }
    
    if (!msgBtn) {
        msgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [msgBtn setFrame:CGRectMake(10, self.view.bounds.size.height - 60, 140, 40)];
        [msgBtn setTitle:@"Message Group" forState: (UIControlState)UIControlStateNormal];
        [msgBtn addTarget:self action:@selector(msg_group:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:msgBtn];
    }
    
    if (!leaveBtn) {
        leaveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [leaveBtn setFrame:CGRectMake(170, self.view.bounds.size.height - 60, 140, 40)];
        [leaveBtn setTitle:@"Leave Group" forState: (UIControlState)UIControlStateNormal];
        [leaveBtn addTarget:self action:@selector(leave_group:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:leaveBtn];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self get_table_data];
    
    //CGRect frame = CGRectMake(tblView.frame.origin.x, tblView.frame.origin.y, tblView.frame.size.width, tblView.contentSize.height);
    //tblView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //tblView.frame = frame;
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

- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
    return result;
}

- (void)leave_group:(id *)sender {
    NSString *post = [NSString stringWithFormat:@"action=leave_group&new_app=1&user_id=%@&group_pin=%@", [self urlEncodeValue:workingUserId], [self urlEncodeValue:workingId]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.vegashipster.com/mobile.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    //NSLog(@"Post Data: %@", post);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil) {
        NSString *response = [[NSString alloc] initWithData:result encoding:
                              NSASCIIStringEncoding];
        
        NSNumber *result = [(NSDictionary*)[response JSONValue] objectForKey:@"Returned"];
        
        NSLog(@"Result: %@", result);
        
        if ([result intValue] == 1) {
            //path to database file
            NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
            sqlite3 *db;
            sqlite3_open([databasePath UTF8String], &db);
            
            sqlite3_stmt *statement;
            NSString *query = [[NSString alloc] initWithFormat:@"Delete From ff_group Where group_num = '%@';",workingId];
            
            bool success = false;
            if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
                if(sqlite3_step(statement)){
                    success = true;
                }
            }else{
                //NSLog(@"Can't connect to the db...");
                NSLog(@"Database Error = %s\nQuery = %@", sqlite3_errmsg(db), query);
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
            
            if (success) {
                //[self performSegueWithIdentifier:@"returnFromCreateGroupView" sender:self];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submission Response"
                                                                message:@"Could not leave group."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submission Response"
                                                            message:[(NSDictionary*)[response JSONValue] objectForKey:@"Response"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        NSLog(@"Result: %@", response);
    }else{
        NSLog(@"Error: %@", error);
    }
}

- (void)email_pin:(id *)sender {
    if ([MFMailComposeViewController canSendMail]) {
		NSString *mailStr = [[NSString alloc] initWithFormat:@"I have set up a Friend Finder group using the Vegas Hipster iPhone App. You can join my group by using this PIN: %@", workingId];
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
		mailViewController.mailComposeDelegate = self;
		[mailViewController setSubject:@"Vegas Hipster 'Friend Finder' Pin Code"];
		[mailViewController setMessageBody:mailStr isHTML:NO];
		
		[self presentModalViewController:mailViewController animated:YES];
		
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSLog(@"in didFinishWithResult:");
    UIAlertView *alert = nil;
    
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"sent");
			alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email Sent",@"Email Sent")
                                                            message:@"Email Sent"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Close",@"Close")
                                                  otherButtonTitles:nil];
			[alert show];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Failed");
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error sending email!",@"Error sending email!")
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Bummer",@"Bummer")
                                                  otherButtonTitles:nil];
            [alert show];
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)msg_group:(id *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Note!",@"This option is not yet available.")
                                       message:@"This option is not yet available."
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"Ok",@"Ok")
                             otherButtonTitles:nil];
    [alert show];
}

- (void)get_table_data {
	//initialize arrays that hold table data
	listArray = [[NSMutableArray alloc] init];
    
    //http://www.vegashipster.com/mobile.php?action=get_contacts&num=%@",group_num
    
    NSString *post = [NSString stringWithFormat:@"action=get_contacts&new_app=1&group_num=%@", workingId];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.vegashipster.com/mobile.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    //NSLog(@"Post Data: %@", post);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil) {
        NSString *response = [[NSString alloc] initWithData:result encoding:
                              NSASCIIStringEncoding];
        
        //NSLog(@"Response: %@", response);
        
        NSNumber *result = [(NSDictionary*)[response JSONValue] objectForKey:@"Returned"];
        
        //NSLog(@"Result: %@", result);
        
        if ([result intValue] == 1) {
            listArray = [(NSDictionary*)[response JSONValue] objectForKey:@"Response"];
            
            //NSLog(@"Response Array: %@", [[listArray objectAtIndex:0] objectForKey:@"name"]);
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submission Response"
                                                            message:[(NSDictionary*)[response JSONValue] objectForKey:@"Response"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        //NSLog(@"Result: %@", response);
    }else{
        NSLog(@"Error: %@", error);
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
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [[listArray objectAtIndex:indexPath.row] objectForKey:@"date"]];
    
	cell.detailTextLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    latitude = [[listArray objectAtIndex:indexPath.row] objectForKey:@"latitude"];
    longitude = [[listArray objectAtIndex:indexPath.row] objectForKey:@"longitude"];
    userName = [[listArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    userPhone = [[listArray objectAtIndex:indexPath.row] objectForKey:@"phone"];
    
    [self performSegueWithIdentifier:@"pushMapView" sender:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    latitude = [[listArray objectAtIndex:indexPath.row] objectForKey:@"latitude"];
    longitude = [[listArray objectAtIndex:indexPath.row] objectForKey:@"longitude"];
    userName = [[listArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    userPhone = [[listArray objectAtIndex:indexPath.row] objectForKey:@"phone"];
    
    [self performSegueWithIdentifier:@"pushMapView" sender:self];
}

- (void) showSettings:(id)sender {
    [self performSegueWithIdentifier:@"pushFriendSettingsView" sender:self];
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"pushMapView"]) {
        // Get reference to the destination view controller
        VH_FFMapViewController *vc = [segue destinationViewController];
        [vc setWorkingLatitude:latitude withLongitude:longitude withName:userName withPhone:userPhone];
    }
}

@end
