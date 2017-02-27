//
//  DOR_Utilities.m
//  Dining Out Right
//
//  Created by James on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DOR_Utilities.h"
#define TMP NSTemporaryDirectory()

@implementation DOR_Utilities

- (void) cacheImage: (NSString *) ImageURLString :(NSString *) filename
{
    NSURL *ImageURL = [NSURL URLWithString: ImageURLString];
    
    // Generate a unique path to a resource representing the image you want
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *uniquePath = [libraryDirectory stringByAppendingPathComponent: filename];
    
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // The file doesn't exist, we should get a copy of it
        
        // Fetch image
        NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
        UIImage *image = [[UIImage alloc] initWithData: data];
        
        // Do we want to round the corners?
        //image = [self roundCorners: image];
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([filename rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [filename rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound || 
                [filename rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
        else if ([filename rangeOfString: @".gif" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            filename = [NSString stringWithFormat:@"%@.png",[filename substringToIndex:filename.length - 4]];
            NSString *uniquePath = [libraryDirectory stringByAppendingPathComponent: filename];
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
    }
}

- (UIImage *) getCachedImage: (NSString *) ImageURLString :(NSString *) filename
{
    NSString *origninalFilename = filename;
    if ([filename rangeOfString: @".gif" options: NSCaseInsensitiveSearch].location != NSNotFound)
    {
        filename = [NSString stringWithFormat:@"%@.png",[filename substringToIndex:filename.length - 4]];
        //NSLog(@"Filename = %@", filename);
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *uniquePath = [libraryDirectory stringByAppendingPathComponent: filename];
    
    UIImage *image;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        //NSLog(@"Image was cached.");
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
    else
    {
        //NSLog(@"Image was not cached. Filename: %@", origninalFilename);
        // get a new one
        [self cacheImage: ImageURLString : origninalFilename];
        image = [UIImage imageWithContentsOfFile: uniquePath];
    }
    
    return image;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (UIImage *) roundCorners: (UIImage*) img
{
    int w = img.size.width;
    int h = img.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    addRoundedRectToPath(context, rect, 5, 5);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithCGImage:imageMasked];
}

@end
