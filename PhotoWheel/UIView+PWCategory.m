//
//  UIView+PWCategory.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/13/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "UIView+PWCategory.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (PWCategory)

- (UIImage *)pw_imageSnapshot
{
   UIGraphicsBeginImageContextWithOptions([self bounds].size, YES, 0.0f);
   [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
   return image;
}

@end
