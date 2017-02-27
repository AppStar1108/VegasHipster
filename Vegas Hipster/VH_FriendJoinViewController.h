//
//  VH_FriendJoinViewController.h
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

@interface VH_FriendJoinViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *headerLabel;
    IBOutlet UILabel *textLabel;
    
    IBOutlet UILabel *group_pin_lbl;
    IBOutlet UILabel *nameLbl;
    IBOutlet UILabel *phoneLbl;
    
    IBOutlet UITextField *group_pin_txt;
    IBOutlet UITextField *nameTxt;
    IBOutlet UITextField *phoneTxt;
    
    IBOutlet UIButton *sendBtn;
}

@end