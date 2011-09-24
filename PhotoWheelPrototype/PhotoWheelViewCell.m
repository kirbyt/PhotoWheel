//
//  PhotoWheelViewCell.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoWheelViewCell

- (void)setImage:(UIImage *)newImage
{
   // Add the image to the layer's contents.
   CALayer *layer = [self layer];
   id imageRef = (__bridge id)[newImage CGImage];
   [layer setContents:imageRef];
   
   // Add border and shadow.
   [layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:1.0].CGColor];
   [layer setBorderWidth:5.0];
   [layer setShadowOffset:CGSizeMake(0, 3)];
   [layer setShadowOpacity:0.7];
   [layer setShouldRasterize:YES];   
}

@end
