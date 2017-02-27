//
//  main.m
//  Vegas Hipster
//
//  Created by James Jewell on 10/25/12.
//  Copyright (c) 2012 Atomic Computers and Design, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VH_AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        setenv("CLASSIC", "0", 1);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([VH_AppDelegate class]));
    }
}
