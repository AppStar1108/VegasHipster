//
//  VH_ContactListViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_ContactListViewController.h"

@interface VH_ContactListViewController ()

@end

@implementation VH_ContactListViewController

- (void)build_user_interface {
    CGRect contentRect = CGRectZero;
    contentRect = CGRectUnion(contentRect, imageView.frame);
    contentRect = CGRectUnion(contentRect, headerLabel.frame);
    contentRect = CGRectUnion(contentRect, textLabel.frame);
    contentRect = CGRectUnion(contentRect, subjectLbl.frame);
    contentRect = CGRectUnion(contentRect, subjectTxt.frame);
    contentRect = CGRectUnion(contentRect, emailLbl.frame);
    contentRect = CGRectUnion(contentRect, emailTxt.frame);
    contentRect = CGRectUnion(contentRect, msgLbl.frame);
    contentRect = CGRectUnion(contentRect, msgTxt.frame);
    contentRect = CGRectUnion(contentRect, sendBtn.frame);
    
    contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, 320, contentRect.size.height + 20);
    
    [scrollView setContentSize:contentRect.size];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:scrollView];
    }
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 150)];
        imageView.image = [UIImage imageNamed:@"hdrAbout.png"];
        [scrollView addSubview:imageView];
    }
    
    if (!headerLabel) {
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 155.0, 300, 25)];
        headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        headerLabel.text = @"Contact Us";
        headerLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        headerLabel.lineBreakMode = UILineBreakModeWordWrap;
        headerLabel.numberOfLines = 0;
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:headerLabel];
    }
    
    if (!textLabel) {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 185.0, 300, 60)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        textLabel.text = @"Thank you for contacting us.  Let us know if you have any Vegas questions or if we are missing something.";
        textLabel.lineBreakMode = UILineBreakModeWordWrap;
        textLabel.numberOfLines = 0;
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:textLabel];
    }
    
    if (!subjectLbl) {
        subjectLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 280.0, 300.0, 20.0)];
        subjectLbl.text = @"Subject:";
        subjectLbl.font = [UIFont boldSystemFontOfSize:17.0];
        [subjectLbl setBackgroundColor:[UIColor clearColor]];
        [subjectLbl setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:subjectLbl];
    }
    
    if (!subjectTxt) {
        subjectTxt = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 305.0, 300.0, 30.0)];
        subjectTxt.delegate = self;
        subjectTxt.returnKeyType = UIReturnKeyNext;
        subjectTxt.borderStyle = UITextBorderStyleRoundedRect;
        subjectTxt.tag = 1;
        [scrollView addSubview:subjectTxt];
    }
    
    if (!emailLbl) {
        emailLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 345.0, 300.0, 20.0)];
        emailLbl.text = @"Email:";
        emailLbl.font = [UIFont boldSystemFontOfSize:17.0];
        [emailLbl setBackgroundColor:[UIColor clearColor]];
        [emailLbl setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:emailLbl];
    }
    
    if (!emailTxt) {
        emailTxt = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 370.0, 300.0, 30.0)];
        emailTxt.delegate = self;
        emailTxt.returnKeyType = UIReturnKeyNext;
        emailTxt.keyboardType = UIKeyboardTypeEmailAddress;
        emailTxt.borderStyle = UITextBorderStyleRoundedRect;
        emailTxt.tag = 2;
        [scrollView addSubview:emailTxt];
    }
    
    if (!msgLbl) {
        msgLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 410.0, 300.0, 20.0)];
        msgLbl.text = @"Message:";
        msgLbl.font = [UIFont boldSystemFontOfSize:17.0];
        [msgLbl setBackgroundColor:[UIColor clearColor]];
        [msgLbl setTextColor:[UIColor whiteColor]];
        [scrollView addSubview:msgLbl];
    }
    
    if (!msgTxt) {
        msgTxt = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 435.0, 300.0, 80.0)];
        msgTxt.delegate = self;
        msgTxt.returnKeyType = UIReturnKeyDone;
        msgTxt.layer.borderWidth = 1.0f;
        msgTxt.layer.borderColor = [[UIColor blackColor] CGColor];
        msgTxt.tag = 3;
        [scrollView addSubview:msgTxt];
    }
    
    if (!sendBtn) {
        sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendBtn.frame = CGRectMake(20.0, 525.0, 280.0, 35.0);
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [sendBtn addTarget:self action:@selector(send_message) forControlEvents:UIControlEventTouchUpInside];
        [sendBtn setTitle:@"Leave A Message" forState:UIControlStateNormal];
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
    
    [imageView removeFromSuperview];
    [scrollView removeFromSuperview];
    [textLabel removeFromSuperview];
    
    imageView = nil;
    scrollView = nil;
    textLabel = nil;
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

- (void)send_message {
    /*
	email = [[MFMailComposeViewController alloc] init];
	email.mailComposeDelegate = self;
	
	NSString *sub = subjectTxt.text;
	NSString *body = msgTxt.text;
	
	[email setToRecipients:[NSArray arrayWithObject:@"admin@vegashipster.com"]];
	[email setSubject:sub];
	[email setMessageBody:body isHTML:NO];
	
    [self presentModalViewController:email animated:YES];
    */
    
    NSString *post = [NSString stringWithFormat:@"vers=2.0&subject=%@&email=%@&msg=%@", [self urlEncodeValue:subjectTxt.text], [self urlEncodeValue:emailTxt.text], [self urlEncodeValue:msgTxt.text]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.vegashipster.com/appContact.php"];
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
            subjectTxt.text = @"";
            emailTxt.text = @"";
            msgTxt.text = @"";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submission Response"
                                                        message:[(NSDictionary*)[response JSONValue] objectForKey:@"Response"]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
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

@end
