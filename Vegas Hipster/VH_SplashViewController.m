//
//  VH_SplashViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 8/5/13.
//  Copyright (c) 2013 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_SplashViewController.h"
#import "VH_HotelsListViewController.h"
#import "VH_RestaurantsListViewController.h"
#import "VH_ShowsListViewController.h"
#import "VH_MoreListViewController.h"
#import "VH_UpdateViewController.h"

@interface VH_SplashViewController ()

@end

@implementation VH_SplashViewController

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
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bkgSplash.png"]];
    
	//create frame
	CGRect frame = CGRectMake(0, 0, 320, 480);
    
    //create dice subimage
	UIImageView *dice = [[UIImageView alloc] initWithFrame:frame];
	dice.frame = CGRectMake(110, 165, 206, 166);
	dice.image = [UIImage imageNamed:@"dice.png"];
	[self.view addSubview:dice];
	
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
	[self.view addSubview:hotels];
	[self.view addSubview:dining];
	[self.view addSubview:shows];
	[self.view addSubview:more];
	
    [self checkVersion];
}

- (IBAction)gotoview:(UIButton *)sender {
	if (sender.tag == 1) {
        NSLog(@"Tag 1");
        [self performSegueWithIdentifier:@"pushTabBarController" sender:self];
	}else if(sender.tag == 2) {
        NSLog(@"Tag 2");
        [self performSegueWithIdentifier:@"pushTabBarController" sender:self];
	}else if(sender.tag == 3) {
        NSLog(@"Tag 3");
        [self performSegueWithIdentifier:@"pushTabBarController" sender:self];
	}else if(sender.tag == 4) {
        NSLog(@"Tag 4");
        [self.tabBarController setSelectedIndex:4];
        //[self performSegueWithIdentifier:@"pushTabBarController" sender:self];
	}
    
    [self dismissModalViewControllerAnimated:YES];
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
			
            [self performSegueWithIdentifier:@"pushUpdateViewController" sender:self];
			//			[self update];
		}
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
