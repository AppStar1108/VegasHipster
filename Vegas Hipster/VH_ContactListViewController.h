//
//  VH_ContactListViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "json/SBJson.h"
#import "VH_AppDelegate.h"

#define appDelegate (VH_AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface VH_ContactListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *headerLabel;
    IBOutlet UILabel *textLabel;
    IBOutlet UILabel *subjectLbl;
    IBOutlet UILabel *emailLbl;
    IBOutlet UILabel *msgLbl;
    IBOutlet UITextField *emailTxt;
    IBOutlet UITextField *subjectTxt;
    IBOutlet UITextView *msgTxt;
    IBOutlet UIButton *sendBtn;
    
    //MFMailComposeViewController *email;
}

@end