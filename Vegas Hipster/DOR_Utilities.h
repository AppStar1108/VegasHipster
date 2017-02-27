//
//  DOR_Utilities.h
//  Dining Out Right
//
//  Created by James on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DOR_Utilities : NSObject {
    
}

// Methods
- (void) cacheImage: (NSString *) ImageURLString :(NSString *) filename;
- (UIImage *) getCachedImage: (NSString *) ImageURLString :(NSString *) filename;
- (UIImage *) roundCorners: (UIImage*) img;

@end
