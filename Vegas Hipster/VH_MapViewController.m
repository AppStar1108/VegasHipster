//
//  VH_MapViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 11/6/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_MapViewController.h"

@interface VH_MapViewController ()

@end

@implementation VH_MapViewController
@synthesize table_name;
@synthesize table_identifier;
@synthesize main_id;
@synthesize map;
@synthesize url;

VH_MapAnnotation *center_annotation = nil;

- (void)setWorkingVariables:(NSString *)the_table_name withIdentifier:(NSString *)the_table_identifier withId:(NSString *)the_main_id  withUrl:(NSString *)the_url{
    table_name = the_table_name;
    table_identifier = the_table_identifier;
    main_id = the_main_id;
    url = the_url;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor clearColor];
    
    double lat = 0.0;
    double longitude = 0.0;
    
    map = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, self.view.frame.size.height)];
    map.multipleTouchEnabled = YES;
    map.mapType = MKMapTypeHybrid;
    [self.view addSubview:map];
    
    CLLocationCoordinate2D location;
	
	VH_MapAnnotation *annotation = nil;
	
	//path to database file
	NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"vhipsterdb.sqlite"];
	
	//open and initialize database
	sqlite3 *db;
	sqlite3_open([databasePath UTF8String], &db);
	
    
	//adding annotations
	if ([table_name isEqualToString:@"hotel_db"]) {
		sqlite3_stmt *statement;
		NSString *query = [[NSString alloc] initWithFormat:@"SELECT hotel_db.name,hotel_db.address1,hotel_db.address2,coordinates.coords FROM hotel_db JOIN coordinates ON hotel_db.hotel_id = coordinates.table_id WHERE coordinates.table_name = 'hotel_db' AND hotel_db.hotel_id = %@;",main_id];
		if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
			while (sqlite3_step(statement) == SQLITE_ROW) {
				NSString *n = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
				NSString *a1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				NSString *a2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
				NSString *coords = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				NSArray *loc_items = [coords componentsSeparatedByString:@","];
				
				lat = 0.0;
				longitude = 0.0;
				
				if ([loc_items count] >= 2) {
					lat = [[loc_items objectAtIndex:1] doubleValue];
					longitude = [[loc_items objectAtIndex:0] doubleValue];
				}
				
				location.latitude = lat;
				location.longitude = longitude;
				
				annotation = [[VH_MapAnnotation alloc] initWithCoordinate:location annotationType:CSMapAnnotationTypeStart title:n subtitle:[[NSString alloc] initWithFormat:@"%@ %@",a1,a2]];
				
				[map addAnnotation:annotation];
				center_annotation = annotation;
				MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
				MKCoordinateRegion region = {location, span};
				region.center = location;
                
				[map setRegion:region animated:TRUE];
				[map regionThatFits:region];
			}
		}
		sqlite3_finalize(statement);
	}
	else if ([table_name isEqualToString:@"rest_db"] || [table_name isEqualToString:@"clubs"]) {
		sqlite3_stmt *statement;
		
		NSString *query = [[NSString alloc] initWithFormat:@"SELECT %@.name, hotel_db.name AS hotel_name, hotel_db.address1, hotel_db.address2, coordinates.coords FROM '%@' INNER JOIN hotel_db ON %@.hotel_id = hotel_db.hotel_id JOIN coordinates ON hotel_db.hotel_id = coordinates.table_id WHERE coordinates.table_name = 'hotel_db' AND %@.%@ = %@;",table_name,table_name,table_name,table_name,table_identifier,main_id];
		if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
			if (sqlite3_step(statement) == SQLITE_ROW) {
				
				NSString *n = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
				
				//NSString *hotel_name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				NSString *add1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
				NSString *add2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				
				if (sqlite3_column_text(statement, 4) != NULL) {
					NSString *coords = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
					NSArray *loc_items = [coords componentsSeparatedByString:@","];
                    
					lat = 0.0;
					longitude = 0.0;
                    
					if ([loc_items count] >= 2) {
						lat = [[loc_items objectAtIndex:1] doubleValue];
						longitude = [[loc_items objectAtIndex:0] doubleValue];
					}
					
					location.latitude = lat;
					location.longitude = longitude;
                    
					annotation = [[VH_MapAnnotation alloc] initWithCoordinate:location annotationType:CSMapAnnotationTypeStart title:n subtitle:[[NSString alloc] initWithFormat:@"%@ %@",add1, add2]];
                    
					[map addAnnotation:annotation];
					center_annotation = annotation;
					MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
					MKCoordinateRegion region = {location, span};
					region.center = location;
					[map setRegion:region animated:TRUE];
					[map regionThatFits:region];
				}
			}
			else {
				sqlite3_stmt *statement2;
				NSString *query2 = [[NSString alloc] initWithFormat:@"SELECT location, name FROM '%@' WHERE %@ = %@;",table_name,table_identifier,main_id];
				
				if (sqlite3_prepare_v2(db, [query2 UTF8String], -1, &statement2, nil) == SQLITE_OK) {
					while (sqlite3_step(statement2) == SQLITE_ROW) {
						if (sqlite3_column_text(statement2, 0) != NULL) {
							NSString *loc = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 0)];
							NSString *n2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 1)];
							NSString *loc_string = loc;
							loc_string = [loc_string stringByReplacingOccurrencesOfString:@"." withString:@""];
							loc_string = [loc_string stringByReplacingOccurrencesOfString:@"-" withString:@""];
							loc_string = [loc_string stringByReplacingOccurrencesOfString:@"," withString:@""];
							loc_string = [loc_string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
							
							NSString *thisUrl = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps/geo?q=%@+Las+Vegas+Nevada&output=csv", loc_string];
							
							NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:thisUrl] encoding:NSASCIIStringEncoding error:NULL];
							NSArray *listItems = [locationString componentsSeparatedByString:@","];
							
							lat = 0.0;
							longitude = 0.0;
							
							if ([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
								lat = [[listItems objectAtIndex:2] doubleValue];
								longitude = [[listItems objectAtIndex:3] doubleValue];
							}
							
							location.latitude = lat;
							location.longitude = longitude;
							
							annotation = [[VH_MapAnnotation alloc] initWithCoordinate:location annotationType:CSMapAnnotationTypeStart title:n2 subtitle:[[NSString alloc] initWithFormat:@"%@ Las Vegas, Nevada",loc]];
							
							[map addAnnotation:annotation];
							center_annotation = annotation;
							MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
							MKCoordinateRegion region = {location, span};
							region.center = location;
                            
							[map setRegion:region animated:TRUE];
							[map regionThatFits:region];
						}
					}
				}
				sqlite3_finalize(statement2);
			}
		}
		sqlite3_finalize(statement);
	}
	else {
		sqlite3_stmt *statement;
		NSString *query = [[NSString alloc] initWithFormat:@"SELECT %@.name, hotel_db.address1, hotel_db.address2, coordinates.coords FROM '%@' INNER JOIN hotel_db ON %@.hotel_id = hotel_db.hotel_id JOIN coordinates ON hotel_db.hotel_id = coordinates.table_id WHERE coordinates.table_name = 'hotel_db' AND %@.%@ = %@;",table_name,table_name,table_name,table_name,table_identifier,main_id];
        
		if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
			if (sqlite3_step(statement) == SQLITE_ROW) {
				NSString *n = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
				NSString *add1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				NSString *add2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
				
				NSString *coords = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				NSArray *loc_items = [coords componentsSeparatedByString:@","];
                
				lat = 0.0;
				longitude = 0.0;
                
				if ([loc_items count] >= 2) {
					lat = [[loc_items objectAtIndex:1] doubleValue];
					longitude = [[loc_items objectAtIndex:0] doubleValue];
				}
                
				location.latitude = lat;
				location.longitude = longitude;
                
				annotation = [[VH_MapAnnotation alloc] initWithCoordinate:location annotationType:CSMapAnnotationTypeStart title:n subtitle:[[NSString alloc] initWithFormat:@"%@ %@",add1, add2]];
				[map addAnnotation:annotation];
				center_annotation = annotation;
				MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
				MKCoordinateRegion region = {location, span};
				region.center = location;
                
				[map setRegion:region animated:TRUE];
				[map regionThatFits:region];
			}
			else {
				sqlite3_stmt *statement2;
				NSString *query2 = [[NSString alloc] initWithFormat:@"SELECT showroom, name FROM '%@' WHERE %@ = %@;",table_name,table_identifier,main_id];
				
				if (sqlite3_prepare_v2(db, [query2 UTF8String], -1, &statement2, nil) == SQLITE_OK) {
					while (sqlite3_step(statement2) == SQLITE_ROW) {
						if (sqlite3_column_text(statement2, 0) != NULL) {
							NSString *loc = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 0)];
							NSString *n2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 1)];
							NSString *loc_string = loc;
							loc_string = [loc_string stringByReplacingOccurrencesOfString:@"." withString:@""];
							loc_string = [loc_string stringByReplacingOccurrencesOfString:@"-" withString:@""];
							loc_string = [loc_string stringByReplacingOccurrencesOfString:@"," withString:@""];
							loc_string = [loc_string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
							
							NSString *thisUrl = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps/geo?q=%@+Las+Vegas+Nevada&output=csv", loc_string];
							
							NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:thisUrl] encoding:NSASCIIStringEncoding error:NULL];
							NSArray *listItems = [locationString componentsSeparatedByString:@","];
							
							lat = 0.0;
							longitude = 0.0;
							
							if ([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
								lat = [[listItems objectAtIndex:2] doubleValue];
								longitude = [[listItems objectAtIndex:3] doubleValue];
							}
							
							location.latitude = lat;
							location.longitude = longitude;
							
							annotation = [[VH_MapAnnotation alloc] initWithCoordinate:location annotationType:CSMapAnnotationTypeStart title:n2 subtitle:[[NSString alloc] initWithFormat:@"%@ Las Vegas, Nevada",loc]];
							
							[map addAnnotation:annotation];
							center_annotation = annotation;
							MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
							MKCoordinateRegion region = {location, span};
							region.center = location;
                            
							[map setRegion:region animated:TRUE];
						 	[map regionThatFits:region];
						}				
					}
				}
				sqlite3_finalize(statement2);
			}
		}
		sqlite3_finalize(statement);	
	}			
	sqlite3_close(db);		
    
	[super viewWillAppear:animated];	
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

- (void)viewWillDisappear:(BOOL)animated{
	NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
	for (id annotation in map.annotations)
		if (annotation != map.userLocation)
			[toRemove addObject:annotation];
	[map removeAnnotations:toRemove];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	if (center_annotation != nil) {
		[map selectAnnotation:center_annotation animated:YES];
		center_annotation = nil;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webview:(UIWebView *)web didFailLoadWithError:(NSError *)error {
	
}

@end
