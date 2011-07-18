//
//  WheelView.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 7/1/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "WheelView.h"
#import <QuartzCore/QuartzCore.h>
#import "SpinGestureRecognizer.h"

@interface WheelView ()
@property (nonatomic, assign) CGFloat currentAngle;
@end

@implementation WheelView

@synthesize dataSource = dataSource_;
@synthesize style = style_;
@synthesize currentAngle = currentAngle_;
@synthesize selectAtDegrees = selectAtDegrees_;
@synthesize selectedIndex = selectedIndex_;

- (void)commonInit
{
   [self setSelectedIndex:-1];
   [self setSelectAtDegrees:0.0];
   [self setCurrentAngle:0.0];
   
   SpinGestureRecognizer *spin = [[SpinGestureRecognizer alloc] initWithTarget:self action:@selector(spin:)];
   [self addGestureRecognizer:spin];
}

- (id)init
{
   self = [super init];
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

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (BOOL)isSelectedItemForAngle:(CGFloat)angle
{
   // The selected item is one whose angle is
   // at or near 0 degrees.
   //
   // To calculate the selected item based on the 
   // angle, we must convert the angle to the 
   // relative angle between 0 and 360 degrees.
   
   CGFloat relativeAngle = fabsf(fmodf(angle, 360.0));
   
   // Pad the selection point so it does not
   // have to be exact.
   CGFloat padding = 15.0;   // Allow 15 degrees on either side.
   
   BOOL isSelectedItem = relativeAngle >= (360.0 - padding) || relativeAngle <= padding;
   return isSelectedItem;
}

- (void)setAngle:(CGFloat)angle
{
   // The follow code is inspired from the carousel example at:
   // http://stackoverflow.com/questions/5243614/3d-carousel-effect-on-the-ipad
   
   CGPoint center = CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
   CGFloat radiusX = MIN([self bounds].size.width, [self bounds].size.height) * 0.35;
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

      // Set the selected index if it has changed.
      if (index != [self selectedIndex] && [self isSelectedItemForAngle:angle]) {
         [self setSelectedIndex:index];
         if ([[self dataSource] respondsToSelector:@selector(wheelView:didSelectCellAtIndex:)]) {
            [[self dataSource] wheelView:self didSelectCellAtIndex:index];
         }
      }
      
      float angleInRadians = (angle + 180.0) * M_PI / 180.0f;
      
      // Get a position based on the angle
      float xPosition = center.x + (radiusX * sinf(angleInRadians)) - (CGRectGetWidth([cell frame]) / 2);
      float yPosition = center.y + (radiusY * cosf(angleInRadians)) - (CGRectGetHeight([cell frame]) / 2);
      
      float scale = 0.75f + 0.25f * (cosf(angleInRadians) + 1.0);
      
      // apply location and scale
      if ([self style] == WheelViewStyleCarousel) {
         [cell setTransform:CGAffineTransformScale(CGAffineTransformMakeTranslation(xPosition, yPosition), scale, scale)];
         // tweak alpha using the same system as applied for scale, this time
         // with 0.3 the minimum and a semicircle range of 0.5
         [cell setAlpha:(0.3f + 0.5f * (cosf(angleInRadians) + 1.0))];
         
      } else {
         [cell setTransform:CGAffineTransformMakeTranslation(xPosition, yPosition)];
         [cell setAlpha:1.0];
      }
      
      [[cell layer] setZPosition:scale];         
      
      // work out what the next angle is going to be
      angle += angleToAdd;
   }
}

- (void)layoutSubviews
{
   [self setAngle:[self currentAngle]];
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

- (void)spin:(SpinGestureRecognizer *)recognizer
{
   CGFloat angleInRadians = -[recognizer rotation];
   CGFloat degrees = 180.0 * angleInRadians / M_PI;   // radians to degrees
   [self setCurrentAngle:[self currentAngle] + degrees];
   [self setAngle:[self currentAngle]];
}

- (void)reloadData
{
   [self layoutSubviews];
}

@end


@implementation WheelViewCell

@end