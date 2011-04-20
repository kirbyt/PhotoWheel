//
//  PhotoWheelView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/20/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelView.h"
#import "PhotoNubViewController.h"
#import "KTGeometry.h"
#import <QuartzCore/QuartzCore.h>


@interface PhotoWheelView ()
@property (nonatomic, assign, readwrite) NSInteger nubCount;
@property (nonatomic, retain) NSMutableArray *nubControllers;
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) CGFloat lastAngle;

- (void)commonInit;
- (void)setStyle:(PhotoWheelStyle)style;
- (void)setAngle:(CGFloat)angle;
@end


@implementation PhotoWheelView

@synthesize nubCount = nubCount_;
@synthesize style = style_;
@synthesize nubControllers = nubControllers_;
@synthesize currentAngle = currentAngle_;
@synthesize lastAngle = lastAngle_;

- (void)dealloc
{
   [nubControllers_ release], nubControllers_ = nil;
   [super dealloc];
}

- (id)init
{
   self = [super init];
   if (self) {
      [self setNubCount:12];  // Default to 12 nubs.
      [self commonInit];
   }
   return self;
}

- (id)initWithNubCount:(NSInteger)nubCount
{
   self = [super init];
   if (self) {
      [self setNubCount:nubCount];
      [self commonInit];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self setNubCount:12];  // Default to 12 nubs.
      [self commonInit];
   }
   return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      [self setNubCount:12];  // Default to 12 nubs.
      [self commonInit];
   }
   return self;
}

- (void)commonInit
{
   // Create the array that holds each view on a wheel spoke.
   NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[self nubCount]];
   [self setNubControllers:newArray];
   [newArray release];

   [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
   
   for (NSInteger index=0; index < [self nubCount]; index++) {
      PhotoNubViewController *newController = [[PhotoNubViewController alloc] init];
      [self addSubview:[newController view]];
      [[self nubControllers] addObject:newController];
      [newController release];
   }
   
   [self setCurrentAngle:0.0];
   [self setLastAngle:0.0];
}

- (void)setStyle:(PhotoWheelStyle)style
{
   if (style_ != style) {
      style_ = style;
      
      [UIView beginAnimations:@"PhotoWheelChangeStyle" context:nil];
      [self setAngle:[self currentAngle]];
      [UIView commitAnimations];
   }
}

- (void)setAngle:(CGFloat)angle
{
   // The follow code is inprised from the carousel example at:
   // http://stackoverflow.com/questions/5243614/3d-carousel-effect-on-the-ipad

   CGPoint center = CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
   CGFloat radiusX = [self bounds].size.width * 0.35;
   CGFloat radiusY = radiusX;
   if ([self style] == PhotoWheelStyleCarousel) {
      radiusY = radiusX * 0.30;
   }
   
   NSInteger nubCount = [[self nubControllers] count];
   float angleToAdd = 360.0f / nubCount;
   
   for(UIViewController *controller in [self nubControllers])
   {
      UIView *view = [controller view];
      
      float angleInRadians = angle * M_PI / 180.0f;
      
      // get a location based on the angle
      float xPosition = center.x + (radiusX * sinf(angleInRadians));
      float yPosition = center.y + (radiusY * cosf(angleInRadians));
      
      // get a scale too; effectively we have:
      //
      //  0.75f   the minimum scale
      //  0.25f   the amount by which the scale varies over half a circle
      //
      // so this will give scales between 0.75 and 1.0. Adjust to suit!
      float scale = 0.75f + 0.25f * (cosf(angleInRadians) + 1.0);
      
      // apply location and scale
      if ([self style] == PhotoWheelStyleCarousel) {
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
      
      // work out what the next angle is going to be
      angle += angleToAdd;
   }
}

- (void)layoutSubviews
{
   [self setAngle:[self currentAngle]];
}

#pragma mark - Touch Event Handlers

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   // We only support single touches, so anyObject retrieves just that touch from touches
   UITouch *touch = [touches anyObject];
   
   CGPoint wheelCenter = [self center];
   
   // use the movement of the touch to decide
   // how much to rotate the carousel
   CGPoint locationNow = [touch locationInView:self];
   CGPoint locationThen = [touch previousLocationInView:self];
   CGPoint oppositeNow = CGPointMake(wheelCenter.x + (wheelCenter.x - locationNow.x), wheelCenter.y + (wheelCenter.y - locationNow.y));
   CGPoint oppositeThen = CGPointMake(wheelCenter.x + (wheelCenter.x - locationThen.x), wheelCenter.y + (wheelCenter.y - locationThen.y));
   
   CGFloat angleInRadians = angleBetweenLinesInRadians(locationNow, oppositeNow, locationThen, oppositeThen);
   [self setLastAngle:[self currentAngle]];
   [self setCurrentAngle:[self currentAngle] + radiansToDegrees(angleInRadians)];
   
   [self setAngle:[self currentAngle]];
}

@end
