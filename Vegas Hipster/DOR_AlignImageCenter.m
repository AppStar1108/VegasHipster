//
//  DOR_AlignImageCenter.m
//  Dining Out Right
//
//  Created by James on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DOR_AlignImageCenter.h"

#define MARGIN 10

@implementation DOR_AlignImageCenter

- (void) layoutSubviews {
[super layoutSubviews];
CGRect cvf = self.contentView.frame;
self.imageView.frame = CGRectMake(0.0,
                                  0.0,
                                  cvf.size.height-1,
                                  cvf.size.height-1);
self.imageView.contentMode = UIViewContentModeScaleAspectFit;

CGRect frame = CGRectMake(cvf.size.height + MARGIN,
                          self.textLabel.frame.origin.y,
                          cvf.size.width - cvf.size.height - 2*MARGIN,
                          self.textLabel.frame.size.height);
self.textLabel.frame = frame;

frame = CGRectMake(cvf.size.height + MARGIN,
                   self.detailTextLabel.frame.origin.y,
                   cvf.size.width - cvf.size.height - 2*MARGIN,
                   self.detailTextLabel.frame.size.height);
self.detailTextLabel.frame = frame;
}


@end
