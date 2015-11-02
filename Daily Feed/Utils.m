//
//  Utils.m
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
    
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}

+ (CIContext *)getCIContext{
    
    static CIContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:[NSNumber numberWithBool:NO]}];
    });
    return context;
}


@end
