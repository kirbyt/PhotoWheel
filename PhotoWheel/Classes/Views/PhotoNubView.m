//
//  PhotoWheelImageView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/31/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoNubView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIBezierPath+ShadowPath.h"


@implementation PhotoNubView

- (id)init 
{
   self = [super init];
   if (self) {

   }
   return self;
}

- (void)setImage:(UIImage *)image
{
   // Add border and shadow.
   CALayer *layer = [self layer];
   [layer setContents:(id)[image CGImage]];
   [layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:1.0].CGColor];
   [layer setBorderWidth:5.0];
   [layer setShadowOffset:CGSizeMake(0, 3)];
   [layer setShadowOpacity:0.7];
   [layer setShouldRasterize:YES];
   
   UIBezierPath *path = [UIBezierPath bezierPathWithCurvedShadowForRect:[self bounds]];
   [layer setShadowPath:[path CGPath]];
}


@end
