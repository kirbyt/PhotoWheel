//
//  PhotoWheelViewNub.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/25/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelViewNub.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoWheelViewNub

- (void)setImage:(UIImage *)image
{
   // Add border and shadow.
   CALayer *layer = [self layer];
   id imageRef = objc_unretainedObject([image CGImage]);
   [layer setContents:imageRef];
   [layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:1.0].CGColor];
   [layer setBorderWidth:5.0];
   [layer setShadowOffset:CGSizeMake(0, 3)];
   [layer setShadowOpacity:0.7];
   [layer setShouldRasterize:YES];
}

@end
