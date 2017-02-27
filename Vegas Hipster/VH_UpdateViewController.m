//
//  VH_UpdateViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 6/18/13.
//  Copyright (c) 2013 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_UpdateViewController.h"

@interface VH_UpdateViewController ()

@end

@implementation VH_UpdateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor clearColor];
    
	[updateButton setTitle:@"Update" forState: (UIControlState)UIControlStateNormal];
	[updateButton setTitle:@"Updating..." forState: (UIControlState)UIControlStateHighlighted];
	[updateButton addTarget:self action:@selector(inform:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
	[updateButton addTarget:self action:@selector(update:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)inform:(id)sender{
	status_text.text = @"Update in progress.  This may take several minutes.";
	activity.hidden = NO;
	[activity startAnimating];
    //	RunUpdate *updates = [[RunUpdate alloc] init];
    //	[updates update];
}

- (IBAction)update:(id)sender{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_queue_t my_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    
    dispatch_async(my_queue, ^{
        NSString *myRawJson;
        
        // Get data from the web
        NSURL *url = [NSURL URLWithString:@"http://www.vegashipster.com/mobile.php?action=get_data"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error == nil) {
            myRawJson = [[NSString alloc] initWithData:result encoding:
                         NSASCIIStringEncoding];
            NSLog(@"Result: %@", response);
        }else{
            NSLog(@"Error: %@", error);
        }
        
        // If there was no data received return and do nothing else
        if ([myRawJson length] == 0) {
            myRawJson = nil;
            return;
        }
        
        NSDictionary *parsedJson;
        
        // Start parsing the json
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        parsedJson = [[parser objectWithString:myRawJson] copy];
        
        parser = nil;
        
        
        
        NSString *databaseName = @"vhipsterdb.sqlite";
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        NSString *databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
        
        sqlite3 *db;
        
        sqlite3_stmt *dbps;
        char *sql = "INSERT OR REPLACE INTO prices (id, table_name, table_id, value) VALUES (?, ?, ?, ?);";
        sqlite3_stmt *dbps2;
        char *sql2 = "INSERT OR REPLACE INTO clubs (clubs_id, name, phone, location, hotel_id, charge, hours, web, club_type, attire, description, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        sqlite3_stmt *dbps3;
        char *sql3 = "INSERT OR REPLACE INTO club_type_db (club_type_id, type) VALUES (?, ?);";
        sqlite3_stmt *dbps4;
        char *sql4 = "INSERT OR REPLACE INTO hotel_db (hotel_id, name, linkname, address1, address2, local_phone, website, tollfree, reservations, rooms, suites, food, buffet, casino_size, games, casino_phone, discounts, funbook, special, description, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        sqlite3_stmt *dbps5;
        char *sql5 = "INSERT OR REPLACE INTO rest_db (rest_id, hotel_id, name, location, phone, web, breakfast, brunch, lunch, dinner, rating, description, rest_type, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        sqlite3_stmt *dbps6;
        char *sql6 = "INSERT OR REPLACE INTO rest_type_db (rest_type_id, type) VALUES (?, ?);";
        sqlite3_stmt *dbps7;
        char *sql7 = "INSERT OR REPLACE INTO shows_db (shows_id, hotel_id, name, type, price, dark, times, showroom, phone, description, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        sqlite3_stmt *dbps8;
        char *sql8 = "INSERT OR REPLACE INTO show_type_db (show_type_id, type) VALUES (?, ?);";
        sqlite3_stmt *dbps9;
        char *sql9 = "INSERT OR REPLACE INTO sports_db (sports_id, hotel_id, name, type, price, dark, times, showroom, phone, description, userfile, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        sqlite3_stmt *dbps10;
        char *sql10 = "INSERT OR REPLACE INTO sports_type_db (sports_type_id, type) VALUES (?, ?);";
        sqlite3_stmt *dbps11;
        char *sql11 = "INSERT OR REPLACE INTO attractions_db (attractions_id, hotel_id, name, price, dark, times, showroom, phone, description, userfile, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        sqlite3_stmt *dbps12;
        char *sql12 = "Update db_vers Set vers_id=?;";
        //	sqlite3_stmt *dbps13;
        //	char *sql13 = "INSERT OR REPLACE INTO ratings_db (rate_id, rate_type, rating, rate_prop_id, user_id) VALUES (?, ?, ?, ?, ?);";
        sqlite3_stmt *dbps14;
        char *sql14 = "INSERT OR REPLACE INTO taxi_db (taxi_id, taxi_name, taxi_phone, description) VALUES (?, ?, ?, ?);";
        
        //Drop All Tables
        sqlite3_open([databasePath UTF8String], &db);
        
        sqlite3_exec(db, "Drop Table prices;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table clubs;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table club_type_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table hotel_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table rest_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table rest_type_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table shows_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table show_type_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table sports_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table sports_type_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table attractions_db;", NULL, NULL, NULL);
        sqlite3_exec(db, "Drop Table taxi_db;", NULL, NULL, NULL);
        
        sqlite3_exec(db, "CREATE TABLE 'prices' ('id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'table_name' VARCHAR, 'table_id' INTEGER NOT NULL  DEFAULT 0, 'value' INTEGER);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'clubs' ('clubs_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'name' VARCHAR, 'phone' VARCHAR, 'location' VARCHAR, 'hotel_id' INTEGER NOT NULL  DEFAULT 0, 'charge' VARCHAR, 'hours' VARCHAR, 'web' VARCHAR, 'club_type' VARCHAR, 'attire' VARCHAR, 'description' TEXT, 'image_path' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'club_type_db' ('club_type_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'type' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'hotel_db' ('hotel_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'name' VARCHAR, 'linkname' VARCHAR, 'address1' VARCHAR, 'address2' VARCHAR, 'local_phone' VARCHAR, 'website' VARCHAR, 'tollfree' VARCHAR, 'reservations' VARCHAR, 'rooms' VARCHAR, 'suites' VARCHAR, 'food' VARCHAR, 'buffet' TEXT, 'casino_size' VARCHAR, 'games' TEXT, 'casino_phone' VARCHAR, 'discounts' TEXT, 'funbook' TEXT, 'special' TEXT, 'show1' TEXT, 'show2' TEXT, 'show3' TEXT, 'show4' TEXT, 'description' TEXT, 'image_path' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'rest_db' ('rest_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'hotel_id' INTEGER DEFAULT 0, 'name' VARCHAR, 'location' VARCHAR, 'phone' VARCHAR, 'web' VARCHAR, 'breakfast' VARCHAR, 'brunch' VARCHAR, 'lunch' VARCHAR, 'dinner' VARCHAR, 'rating' VARCHAR, 'description' TEXT, 'rest_type' INTEGER, 'image_path' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'rest_type_db' ('rest_type_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'type' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'show_type_db' ('show_type_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'type' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'shows_db' ('shows_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'hotel_id' INTEGER NOT NULL  DEFAULT 0, 'name' VARCHAR, 'type' VARCHAR, 'price' VARCHAR, 'dark' VARCHAR, 'times' VARCHAR, 'showroom' VARCHAR, 'phone' VARCHAR, 'description' TEXT, 'image_path' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'sports_db' ('sports_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'hotel_id' INTEGER NOT NULL  DEFAULT 0, 'name' VARCHAR, 'type' VARCHAR, 'price' VARCHAR, 'dark' VARCHAR, 'times' VARCHAR, 'showroom' VARCHAR, 'phone' VARCHAR, 'description' TEXT, 'userfile' VARCHAR, 'image_path' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'sports_type_db' ('sports_type_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'type' VARCHAR);", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE 'attractions_db' ('attractions_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'hotel_id' INTEGER NOT NULL  DEFAULT 0, 'name' VARCHAR, 'price' VARCHAR, 'dark' VARCHAR, 'times' VARCHAR, 'showroom' VARCHAR, 'phone' VARCHAR, 'description' TEXT, 'userfile' VARCHAR, 'image_path' );", NULL, NULL, NULL);
        sqlite3_exec(db, "CREATE TABLE `taxi_db` (`taxi_id` int unsigned NOT NULL,`taxi_name` varchar(255) NOT NULL,`taxi_phone` varchar(255) NOT NULL,`description` text NOT NULL);", NULL, NULL, NULL);
        
        //Prices
        NSDictionary *price = [parsedJson objectForKey:@"prices"];
        NSEnumerator *enumerator = [price objectEnumerator];
        NSDictionary* item;
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql, -1, &dbps, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps, 1, [[item objectForKey:@"id"] intValue]);
                sqlite3_bind_text(dbps, 2, [[item objectForKey:@"table"] UTF8String], -1, NULL);
                sqlite3_bind_int(dbps, 3, [[item objectForKey:@"table_id"] intValue]);
                sqlite3_bind_int(dbps, 4, [[item objectForKey:@"value"] intValue]);
            }
            sqlite3_step(dbps);
            sqlite3_finalize(dbps);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"table"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        price = nil;
        
        //Clubs
        NSDictionary *clubs = [parsedJson objectForKey:@"clubs"];
        enumerator = [clubs objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql2, -1, &dbps2, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps2, 1, [[item objectForKey:@"clubs_id"] intValue]);
                sqlite3_bind_text(dbps2, 2, [[item objectForKey:@"name"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps2, 3, [[item objectForKey:@"phone"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps2, 4, [[item objectForKey:@"location"] UTF8String], -1, NULL);
                sqlite3_bind_int(dbps2, 5, [[item objectForKey:@"hotel_id"] intValue]);
                sqlite3_bind_text(dbps2, 6, [[item objectForKey:@"charge"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps2, 7, [[item objectForKey:@"hours"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps2, 8, [[item objectForKey:@"web"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps2, 9, [[item objectForKey:@"club_type"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps2, 10, [[item objectForKey:@"attire"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps2, 11, [[item objectForKey:@"description"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps2, 12, [[item objectForKey:@"image_path"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps2);
            sqlite3_finalize(dbps2);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"name"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        clubs = nil;
        
        //Clubs Types
        NSDictionary *club_type_db = [parsedJson objectForKey:@"club_type_db"];
        enumerator = [club_type_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql3, -1, &dbps3, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps3, 1, [[item objectForKey:@"club_type_id"] intValue]);
                sqlite3_bind_text(dbps3, 2, [[item objectForKey:@"type"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps3);
            sqlite3_finalize(dbps3);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"type"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        club_type_db = nil;
        
        //Hotel
        NSDictionary *hotel_db = [parsedJson objectForKey:@"hotel_db"];
        enumerator = [hotel_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql4, -1, &dbps4, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps4, 1, [[item objectForKey:@"hotel_id"] intValue]);
                sqlite3_bind_text(dbps4, 2, [[item objectForKey:@"name"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 3, [[item objectForKey:@"linkname"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 4, [[item objectForKey:@"address1"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 5, [[item objectForKey:@"address2"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 6, [[item objectForKey:@"local_phone"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 7, [[item objectForKey:@"website"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 8, [[item objectForKey:@"tollfree"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 9, [[item objectForKey:@"reservations"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 10, [[item objectForKey:@"rooms"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 11, [[item objectForKey:@"suites"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 12, [[item objectForKey:@"food"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 13, [[item objectForKey:@"buffet"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 14, [[item objectForKey:@"casino_size"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 15, [[item objectForKey:@"games"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 16, [[item objectForKey:@"casino_phone"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 17, [[item objectForKey:@"discounts"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 18, [[item objectForKey:@"funbook"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 19, [[item objectForKey:@"special"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 20, [[item objectForKey:@"description"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps4, 21, [[item objectForKey:@"image_path"] UTF8String], -1, NULL);
            }
            
            sqlite3_step(dbps4);
            sqlite3_finalize(dbps4);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"name"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        hotel_db = nil;
        
        //Restaurants
        NSDictionary *rest_db = [parsedJson objectForKey:@"rest_db"];
        enumerator = [rest_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql5, -1, &dbps5, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps5, 1, [[item objectForKey:@"rest_id"] intValue]);
                sqlite3_bind_int(dbps5, 2, [[item objectForKey:@"hotel_id"] intValue]);
                sqlite3_bind_text(dbps5, 3, [[item objectForKey:@"name"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 4, [[item objectForKey:@"location"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 5, [[item objectForKey:@"phone"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 6, [[item objectForKey:@"web"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 7, [[item objectForKey:@"breakfast"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 8, [[item objectForKey:@"brunch"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 9, [[item objectForKey:@"lunch"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 10, [[item objectForKey:@"dinner"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 11, [[item objectForKey:@"rating"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 12, [[item objectForKey:@"description"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 13, [[item objectForKey:@"rest_type"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps5, 14, [[item objectForKey:@"image_path"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps5);
            sqlite3_finalize(dbps5);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"name"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        rest_db = nil;
        
        //Restaurants Types
        NSDictionary *rest_type_db = [parsedJson objectForKey:@"rest_type_db"];
        enumerator = [rest_type_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql6, -1, &dbps6, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps6, 1, [[item objectForKey:@"rest_type_id"] intValue]);
                sqlite3_bind_text(dbps6, 2, [[item objectForKey:@"type"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps6);
            sqlite3_finalize(dbps6);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"type"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        rest_type_db = nil;
        
        //Shows
        NSDictionary *shows_db = [parsedJson objectForKey:@"shows_db"];
        enumerator = [shows_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql7, -1, &dbps7, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps7, 1, [[item objectForKey:@"shows_id"] intValue]);
                sqlite3_bind_int(dbps7, 2, [[item objectForKey:@"hotel_id"] intValue]);
                sqlite3_bind_text(dbps7, 3, [[item objectForKey:@"name"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps7, 4, [[item objectForKey:@"type"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps7, 5, [[item objectForKey:@"price"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps7, 6, [[item objectForKey:@"dark"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps7, 7, [[item objectForKey:@"times"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps7, 8, [[item objectForKey:@"showroom"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps7, 9, [[item objectForKey:@"phone"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps7, 10, [[item objectForKey:@"description"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps7, 11, [[item objectForKey:@"image_path"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps7);
            sqlite3_finalize(dbps7);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"name"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        shows_db = nil;
        
        //Shows Types
        NSDictionary *shows_type_db = [parsedJson objectForKey:@"show_type_db"];
        enumerator = [shows_type_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql8, -1, &dbps8, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps8, 1, [[item objectForKey:@"show_type_id"] intValue]);
                sqlite3_bind_text(dbps8, 2, [[item objectForKey:@"type"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps8);
            sqlite3_finalize(dbps8);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"type"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        shows_type_db = nil;
        
        //Sports
        NSDictionary *sports_db = [parsedJson objectForKey:@"sports_db"];
        enumerator = [sports_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql9, -1, &dbps9, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps9, 1, [[item objectForKey:@"sports_id"] intValue]);
                sqlite3_bind_int(dbps9, 2, [[item objectForKey:@"hotel_id"] intValue]);
                sqlite3_bind_text(dbps9, 3, [[item objectForKey:@"name"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 4, [[item objectForKey:@"type"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 5, [[item objectForKey:@"price"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 6, [[item objectForKey:@"dark"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 7, [[item objectForKey:@"times"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 8, [[item objectForKey:@"showroom"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 9, [[item objectForKey:@"phone"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 10, [[item objectForKey:@"description"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 11, [[item objectForKey:@"userfile"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps9, 12, [[item objectForKey:@"image_path"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps9);
            sqlite3_finalize(dbps9);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"name"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        sports_db = nil;
        
        //Sports Types
        NSDictionary *sports_type_db = [parsedJson objectForKey:@"sports_type_db"];
        enumerator = [sports_type_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql10, -1, &dbps10, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps10, 1, [[item objectForKey:@"sports_type_id"] intValue]);
                sqlite3_bind_text(dbps10, 2, [[item objectForKey:@"type"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps10);
            sqlite3_finalize(dbps10);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"type"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        sports_type_db = nil;
        
        //Attractions
        NSDictionary *attractions_db = [parsedJson objectForKey:@"attractions_db"];
        enumerator = [attractions_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql11, -1, &dbps11, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps11, 1, [[item objectForKey:@"attractions_id"] intValue]);
                sqlite3_bind_int(dbps11, 2, [[item objectForKey:@"hotel_id"] intValue]);
                sqlite3_bind_text(dbps11, 3, [[item objectForKey:@"name"] UTF8String], -1, NULL);;
                sqlite3_bind_text(dbps11, 4, [[item objectForKey:@"price"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps11, 5, [[item objectForKey:@"dark"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps11, 6, [[item objectForKey:@"times"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps11, 7, [[item objectForKey:@"showroom"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps11, 8, [[item objectForKey:@"phone"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps11, 9, [[item objectForKey:@"description"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps11, 10, [[item objectForKey:@"userfile"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps11, 11, [[item objectForKey:@"image_path"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps11);
            sqlite3_finalize(dbps11);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"name"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        attractions_db = nil;
        
        //Version
        NSDictionary *vers_id = [parsedJson objectForKey:@"vers_id"];
        enumerator = [vers_id objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql12, -1, &dbps12, NULL) == SQLITE_OK) {
                sqlite3_bind_double(dbps12, 1, [[item objectForKey:@"id"] floatValue]);
            }
            sqlite3_step(dbps12);
            sqlite3_finalize(dbps12);
            
            currentValue = @"App Version";
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        vers_id = nil;
        
        //Taxies
        NSDictionary *taxi_db = [parsedJson objectForKey:@"taxi_db"];
        enumerator = [taxi_db objectEnumerator];
        
        sqlite3_open([databasePath UTF8String], &db);
        
        while (item = (NSDictionary*)[enumerator nextObject]) {
            if (sqlite3_prepare_v2(db, sql14, -1, &dbps14, NULL) == SQLITE_OK) {
                sqlite3_bind_int(dbps14, 1, [[item objectForKey:@"taxi_id"] intValue]);
                sqlite3_bind_text(dbps14, 2, [[item objectForKey:@"taxi_name"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps14, 3, [[item objectForKey:@"taxi_phone"] UTF8String], -1, NULL);
                sqlite3_bind_text(dbps14, 4, [[item objectForKey:@"description"] UTF8String], -1, NULL);
            }
            sqlite3_step(dbps14);
            sqlite3_finalize(dbps14);
            
            currentValue = [NSString stringWithFormat:@"%s", [[item objectForKey:@"taxi_name"] UTF8String] ];
            [self performSelectorOnMainThread:@selector(updateUser) withObject:nil waitUntilDone:FALSE];
        }
        taxi_db = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Dispatch Over");
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            [activity stopAnimating];
            activity.hidden = YES;
            status_text.text = @"Update Successful!";
            update_text.text = @"You may have to close and restart the app.";
        });
    });
}

-(void)updateUser{
    update_text.text = [NSString stringWithFormat:@"Updating: %@", currentValue];
}

@end
