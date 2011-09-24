//
//  WheelView.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "WheelView.h"
#import <QuartzCore/QuartzCore.h>

@implementation WheelView

@synthesize dataSource = _dataSource;
@synthesize style = _style;

- (void)setAngle:(CGFloat)angle
{
   // The following code is inspired by the carousel example at
   // http://stackoverflow.com/questions/5243614/3d-carousel-effect-on-the-ipad
   
   CGPoint center = CGPointMake(CGRectGetMidX([self bounds]), 
                                CGRectGetMidY([self bounds]));
   CGFloat radiusX = MIN([self bounds].size.width, 
                         [self bounds].size.height) * 0.35;
   CGFloat radiusY = radiusX;
   if ([self style] == WheelViewStyleCarousel) {
      radiusY = radiusX * 0.30;
   }
   
   NSInteger cellCount = [[self dataSource] wheelViewNumberOfCells:self];
   float angleToAdd = 360.0f / cellCount;
   
   for (NSInteger index = 0; index < cellCount; index++)
   {
      WheelViewCell *cell = [[self dataSource] wheelView:self cellAtIndex:index];
      if ([cell superview] == nil) {
         [self addSubview:cell];
      }
      
      float angleInRadians = (angle + 180.0) * M_PI / 180.0f;
      
      // Get a position based on the angle
      float xPosition = center.x + (radiusX * sinf(angleInRadians)) 
      - (CGRectGetWidth([cell frame]) / 2);
      float yPosition = center.y + (radiusY * cosf(angleInRadians)) 
      - (CGRectGetHeight([cell frame]) / 2);
      
      float scale = 0.75f + 0.25f * (cosf(angleInRadians) + 1.0);
      
      // Apply location and scale
      if ([self style] == WheelViewStyleCarousel) {
         [cell setTransform:CGAffineTransformScale(
                  CGAffineTransformMakeTranslation(xPosition, yPosition), 
                  scale, 
                  scale)];         
         // Tweak alpha using the same system as applied for scale, 
         // this time with 0.3 as the minimum and a semicircle range 
         // of 0.5
         [cell setAlpha:(0.3f + 0.5f * (cosf(angleInRadians) + 1.0))];
         
      } else {
         [cell setTransform:CGAffineTransformMakeTranslation(xPosition, 
                                                             yPosition)];
         [cell setAlpha:1.0];
      }
      
      [[cell layer] setZPosition:scale];         
      
      // Work out what the next angle is going to be
      angle += angleToAdd;
   }
}

- (void)layoutSubviews
{
   [self setAngle:0];
}

// Add to the bottom of the WheelView implementation.
- (void)setStyle:(WheelViewStyle)newStyle
{
   if (_style != newStyle) {
      _style = newStyle;
      
      [UIView beginAnimations:@"WheelViewStyleChange" context:nil];
      [self setAngle:0];
      [UIView commitAnimations];
   }
}

@end


@implementation WheelViewCell
@end
