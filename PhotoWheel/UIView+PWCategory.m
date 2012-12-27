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
   UIGraphicsBeginImageContext([self bounds].size);
   [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
   return image;
}

@end
