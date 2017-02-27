//
//  VH_MapAnnotation.h
//  Vegas Hipster
//
//  Created by James Jewell on 11/6/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// types of annotations for which we will provide annotation views.
typedef enum {
	CSMapAnnotationTypeStart = 0,
	CSMapAnnotationTypeEnd   = 1,
	CSMapAnnotationTypeImage = 2
} CSMapAnnotationType;

@interface VH_MapAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D _coordinate;
	CSMapAnnotationType    _annotationType;
	NSString*              _title;
	NSString*			   _subtitle;
	NSString*              _userData;
	NSURL*                 _url;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate
		  annotationType:(CSMapAnnotationType) annotationType
				   title:(NSString*)title
                subtitle:(NSString*)subtitle;

@property CSMapAnnotationType annotationType;
@property (nonatomic, retain) NSString* userData;
@property (nonatomic, retain) NSURL* url;

@end
