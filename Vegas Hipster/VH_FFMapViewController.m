//
//  VH_FFMapViewController.m
//  Vegas Hipster
//
//  Created by James Jewell on 11/6/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_FFMapViewController.h"

@interface VH_FFMapViewController ()

@end

@implementation VH_FFMapViewController
@synthesize latitude;
@synthesize longitude;
@synthesize userName;
@synthesize userPhone;
@synthesize map;

VH_MapAnnotation *ff_center_annotation = nil;

- (void)setWorkingLatitude:(NSString *)lat withLongitude:(NSString *)lon withName:(NSString *)name  withPhone:(NSString *)phone {
    latitude = lat;
    longitude = lon;
    userName = name;
    userPhone = phone;
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
    
    map = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, self.view.frame.size.height)];
    map.multipleTouchEnabled = YES;
    map.mapType = MKMapTypeHybrid;
    [self.view addSubview:map];
    
    CLLocationCoordinate2D location;
	
	VH_MapAnnotation *annotation = nil;
    
    NSLog(@"Latitude: %@", latitude);
	
	//adding annotations
    location.latitude = [latitude doubleValue];
    location.longitude = [longitude doubleValue];
    
    NSLog(@"Latitude: %f", location.latitude);
    
    annotation = [[VH_MapAnnotation alloc] initWithCoordinate:location annotationType:CSMapAnnotationTypeStart title:userName
 subtitle:userPhone];
    
    [map addAnnotation:annotation];
    ff_center_annotation = annotation;
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {location, span};
    region.center = location;
    
    [map setRegion:region animated:TRUE];
    [map regionThatFits:region];
    
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
	if (ff_center_annotation != nil) {
		[map selectAnnotation:ff_center_annotation animated:YES];
		ff_center_annotation = nil;
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
