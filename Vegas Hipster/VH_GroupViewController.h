//
//  VH_GroupViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "VH_AppDelegate.h"
#import "json/SBJson.h"
#import "VH_FFMapViewController.h"

#define appDelegate (VH_AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface VH_GroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITableView *tblView;
    NSMutableArray *listArray;
    
    IBOutlet UIButton *emailpinBtn;
    IBOutlet UILabel *pinLbl;
    
    IBOutlet UILabel *titleLbl;
    IBOutlet UILabel *messageLbl;
    
    IBOutlet UIButton *msgBtn;
    IBOutlet UIButton *leaveBtn;
    
    NSString *latitude;
    NSString *longitude;
    NSString *userName;
    NSString *userPhone;
}

@property (nonatomic, retain) NSString *workingId;
@property (nonatomic, retain) NSString *workingUserId;

- (void)get_table_data;
- (void)setTheWorkingId:(NSString *)newId forUser:(NSString *)userId;

@end
