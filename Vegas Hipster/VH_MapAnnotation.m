//
//  VH_MapAnnotation.m
//  Vegas Hipster
//
//  Created by James Jewell on 11/6/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import "VH_MapAnnotation.h"

@implementation VH_MapAnnotation
@synthesize coordinate     = _coordinate;
@synthesize annotationType = _annotationType;
@synthesize userData       = _userData;
@synthesize url            = _url;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate
		  annotationType:(CSMapAnnotationType) annotationType
				   title:(NSString*)title
                subtitle:(NSString*)subtitle
{
	self = [super init];
	_coordinate = coordinate;
	_title      = title;
	_subtitle = subtitle;
	_annotationType = annotationType;
	
	return self;
}

- (NSString *)title
{
	return _title;
}

- (NSString *)subtitle
{
	return _subtitle;
}

@end
