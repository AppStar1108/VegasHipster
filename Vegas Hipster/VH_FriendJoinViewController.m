//
//  VH_FriendJoinViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_FriendJoinViewController.h"

@interface VH_FriendJoinViewController ()

@end

@implementation VH_FriendJoinViewController

- (void)build_user_interface {
    CGRect contentRect = CGRectZero;
    contentRect = CGRectUnion(contentRect, headerLabel.frame);
    contentRect = CGRectUnion(contentRect, textLabel.frame);
    contentRect = CGRectUnion(contentRect, group_pin_lbl.frame);
    contentRect = CGRectUnion(contentRect, nameLbl.frame);
    contentRect = CGRectUnion(contentRect, phoneLbl.frame);
    contentRect = CGRectUnion(contentRect, group_pin_txt.frame);
    contentRect = CGRectUnion(contentRect, nameLbl.frame);
    contentRect = CGRectUnion(contentRect, phoneTxt.frame);
    contentRect = CGRectUnion(contentRect, sendBtn.frame);
    
    contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, 320, contentRect.size.height + 20);
    
    [scrollView setContentSize:contentRect.size];
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
    
    if (!headerLabel) {
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 15.0, 300, 25)];
        headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        headerLabel.text = @"Joining a Group";
        headerLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        headerLabel.lineBreakMode = UILineBreakModeWordWrap;
        headerLabel.numberOfLines = 0;
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:headerLabel];
    }
    
    if (!textLabel) {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 55.0, 300, 80)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        textLabel.text = @"Please enter a group pin # and the name you want others to see when viewing you in Friend Finder.  Your phone number is optional.";
        textLabel.lineBreakMode = UILineBreakModeWordWrap;
        textLabel.numberOfLines = 0;
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:textLabel];
    }
    
    if (!group_pin_lbl) {
        group_pin_lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 150.0, 300.0, 20.0)];
        group_pin_lbl.text = @"Group Pin #:";
        group_pin_lbl.font = [UIFont boldSystemFontOfSize:17.0];
        [group_pin_lbl setBackgroundColor:[UIColor clearColor]];
        [group_pin_lbl setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:group_pin_lbl];
    }
    
    if (!group_pin_txt) {
        group_pin_txt = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 175.0, 300.0, 30.0)];
        group_pin_txt.delegate = self;
        group_pin_txt.returnKeyType = UIReturnKeyNext;
        group_pin_txt.borderStyle = UITextBorderStyleRoundedRect;
        group_pin_txt.keyboardType = UIKeyboardTypeNumberPad;
        group_pin_txt.tag = 1;
        [scrollView addSubview:group_pin_txt];
    }
    
    if (!nameLbl) {
        nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 220.0, 300.0, 20.0)];
        nameLbl.text = @"Name:";
        nameLbl.font = [UIFont boldSystemFontOfSize:17.0];
        [nameLbl setBackgroundColor:[UIColor clearColor]];
        [nameLbl setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:nameLbl];
    }
    
    if (!nameTxt) {
        nameTxt = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 245.0, 300.0, 30.0)];
        nameTxt.delegate = self;
        nameTxt.returnKeyType = UIReturnKeyNext;
        nameTxt.borderStyle = UITextBorderStyleRoundedRect;
        nameTxt.tag = 2;
        [scrollView addSubview:nameTxt];
    }
    
    if (!phoneLbl) {
        phoneLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 290.0, 300.0, 20.0)];
        phoneLbl.text = @"Phone:";
        phoneLbl.font = [UIFont boldSystemFontOfSize:17.0];
        [phoneLbl setBackgroundColor:[UIColor clearColor]];
        [phoneLbl setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:phoneLbl];
    }
    
    if (!phoneTxt) {
        phoneTxt = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 315.0, 300.0, 30.0)];
        phoneTxt.delegate = self;
        phoneTxt.returnKeyType = UIReturnKeyDone;
        phoneTxt.borderStyle = UITextBorderStyleRoundedRect;
        phoneTxt.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        phoneTxt.tag = 3;
        [scrollView addSubview:phoneTxt];
    }
    
    if (!sendBtn) {
        sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendBtn.frame = CGRectMake(20.0, 370.0, 280.0, 35.0);
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [sendBtn addTarget:self action:@selector(join_group) forControlEvents:UIControlEventTouchUpInside];
        [sendBtn setTitle:@"Join Group" forState:UIControlStateNormal];
        [scrollView addSubview:sendBtn];
    }
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
    
    [scrollView removeFromSuperview];
    [headerLabel removeFromSuperview];
    [textLabel removeFromSuperview];
    
    [group_pin_lbl removeFromSuperview];
    [nameLbl removeFromSuperview];
    [phoneLbl removeFromSuperview];
    
    [group_pin_txt removeFromSuperview];
    [nameTxt removeFromSuperview];
    [phoneTxt removeFromSuperview];
    
    [sendBtn removeFromSuperview];
    
    scrollView = nil;
    headerLabel = nil;
    textLabel = nil;
    
    group_pin_lbl = nil;
    nameLbl = nil;
    phoneLbl = nil;
    
    group_pin_txt = nil;
    nameTxt = nil;
    phoneTxt = nil;
    
    sendBtn = nil;
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

- (void)join_group {
    NSString *post = [NSString stringWithFormat:@"action=join_group&new_app=1&group_pin=%@&name=%@&phone=%@", [self urlEncodeValue:group_pin_txt.text], [self urlEncodeValue:nameTxt.text], [self urlEncodeValue:phoneTxt.text]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.vegashipster.com/mobile.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSLog(@"Post Data: %@", post);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil) {
        NSString *response = [[NSString alloc] initWithData:result encoding:
                              NSASCIIStringEncoding];
        
        NSLog(@"Response: %@", response);
        
        NSNumber *result = [(NSDictionary*)[response JSONValue] objectForKey:@"Returned"];
        
        //NSLog(@"Result: %@", result);
        
        if ([result intValue] == 1) {
            //path to database file
            NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
            sqlite3 *db;
            sqlite3_open([databasePath UTF8String], &db);
            
            sqlite3_stmt *statement;
            NSString *query = [[NSString alloc] initWithFormat:@"INSERT INTO ff_group (group_num, group_name, user_id) VALUES ('%@','%@','%@');",group_pin_txt.text,[(NSDictionary*)[response JSONValue] objectForKey:@"group_name"],[(NSDictionary*)[response JSONValue] objectForKey:@"uid"]];
            
            NSLog(@"Query: %@", query);
            
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
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submission Response"
                                                                message:@"Could not join group."
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (BOOL) textView: (UITextView*) textView shouldChangeTextInRange: (NSRange) range replacementText: (NSString*) text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self animateTextView: textView up: YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self animateTextView: textView up: NO];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void) animateTextView: (UITextView*) textView up: (BOOL) up
{
    const int movementDistance = 160; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void) showSettings:(id)sender {
    [self performSegueWithIdentifier:@"pushFriendSettingsView" sender:self];
}

@end
