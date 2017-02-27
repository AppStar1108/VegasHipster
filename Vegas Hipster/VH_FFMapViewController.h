//
//  VH_FFMapViewController.h
//  Vegas Hipster
//
//  Created by James Jewell on 11/6/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import "VH_MapAnnotation.h"

@interface VH_FFMapViewController : UIViewController <MKMapViewDelegate> {
	NSString *latitude;
	NSString *longitude;
	NSString *userName;
	NSString *userPhone;
	MKMapView *map;
}

@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userPhone;
@property (nonatomic, retain) IBOutlet MKMapView *map;

- (void)setWorkingLatitude:(NSString *)lat withLongitude:(NSString *)lon withName:(NSString *)name  withPhone:(NSString *)phone;

@end
