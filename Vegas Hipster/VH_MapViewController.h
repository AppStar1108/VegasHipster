//
//  VH_MapViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 11/6/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import "VH_MapAnnotation.h"

@interface VH_MapViewController : UIViewController <MKMapViewDelegate> {
	NSString *table_name;
	NSString *table_identifier;
	NSString *main_id;
	MKMapView *map;
	NSString *url;
}

@property (nonatomic, retain) NSString *table_name;
@property (nonatomic, retain) NSString *table_identifier;
@property (nonatomic, retain) NSString *main_id;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) NSString *url;

- (void)setWorkingVariables:(NSString *)the_table_name withIdentifier:(NSString *)the_table_identifier withId:(NSString *)the_main_id withUrl:(NSString *)the_url;

@end
