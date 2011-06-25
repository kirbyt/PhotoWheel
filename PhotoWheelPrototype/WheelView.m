//
//  WheelView.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "WheelView.h"
#import <QuartzCore/QuartzCore.h>


@interface WheelView ()
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) CGFloat lastAngle;
- (void)setAngle:(CGFloat)angle;
@end

@implementation WheelView

@synthesize dataSource = dataSource_;
@synthesize currentAngle = currentAngle_;
@synthesize lastAngle = lastAngle_;
@synthesize style = style_;

- (void)commonInit
{
   [self setCurrentAngle:0.0];
   [self setLastAngle:0.0];
   
   [self setStyle:WheelViewStyleWheel];
}

- (id)init
{
   self = [super init];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (void)layoutSubviews
{
   [self setAngle:[self currentAngle]];
}

- (CGPoint)wheelCenter
{
   CGPoint center = CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
   return center;
}

- (void)setAngle:(CGFloat)angle
{
   // The follow code is inprised from the carousel example at:
   // http://stackoverflow.com/questions/5243614/3d-carousel-effect-on-the-ipad
   
   CGPoint center = [self wheelCenter];
   CGFloat radiusX = MIN([self bounds].size.width, [self bounds].size.height) * 0.35;
   CGFloat radiusY = radiusX;
   if ([self style] == WheelViewStyleCarousel) {
      radiusY = radiusX * 0.30;
   }
   
   NSInteger nubCount = [[self dataSource] wheelViewNumberOfNubs:self];
   float angleToAdd = 360.0f / nubCount;
   
   for (NSInteger index = 0; index < nubCount; index++)
   {
      if (index < nubCount) {
         WheelViewNub *view = [[self dataSource] wheelView:self nubAtIndex:index];
         if ([view superview] == nil) {
            [self addSubview:view];
         }
         
         float angleInRadians = (angle + 180.0) * M_PI / 180.0f;
         
         // get a location based on the angle
         float xPosition = center.x + (radiusX * sinf(angleInRadians)) - (CGRectGetWidth([view frame]) / 2);
         float yPosition = center.y + (radiusY * cosf(angleInRadians)) - (CGRectGetHeight([view frame]) / 2);
         
         // get a scale too; effectively we have:
         //
         //  0.75f   the minimum scale
         //  0.25f   the amount by which the scale varies over half a circle
         //
         // so this will give scales between 0.75 and 1.0. Adjust to suit!
         float scale = 0.75f + 0.25f * (cosf(angleInRadians) + 1.0);
         
         // apply location and scale
         if ([self style] == WheelViewStyleCarousel) {
            [view setTransform:CGAffineTransformScale(CGAffineTransformMakeTranslation(xPosition, yPosition), scale, scale)];
            // tweak alpha using the same system as applied for scale, this time
            // with 0.3 the minimum and a semicircle range of 0.5
            [view setAlpha:(0.3f + 0.5f * (cosf(angleInRadians) + 1.0))];
            
         } else {
            [view setTransform:CGAffineTransformMakeTranslation(xPosition, yPosition)];
            [view setAlpha:1.0];
         }
         
         // setting the z position on the layer has the effect of setting the
         // draw order, without having to reorder our list of subviews
         [[view layer] setZPosition:scale];
      }
      
      // work out what the next angle is going to be
      angle += angleToAdd;
   }
}

- (void)setStyle:(WheelViewStyle)newStyle
{
   if (style_ != newStyle) {
      style_ = newStyle;
      
      [UIView beginAnimations:@"WheelViewStyleChange" context:nil];
      [self setAngle:[self currentAngle]];
      [UIView commitAnimations];
   }
}


@end


@implementation WheelViewNub

@end