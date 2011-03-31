//
//  PhotoWheelViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/31/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelViewController.h"
#import "PhotoWheelImageView.h"
#import <QuartzCore/QuartzCore.h>

// From: http://iphonedevelopment.blogspot.com/2009/12/better-two-finger-rotate-gesture.html
static inline CGFloat angleBetweenLinesInRadians(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End) {
	
	CGFloat a = line1End.x - line1Start.x;
	CGFloat b = line1End.y - line1Start.y;
	CGFloat c = line2End.x - line2Start.x;
	CGFloat d = line2End.y - line2Start.y;
   
   CGFloat line1Slope = (line1End.y - line1Start.y) / (line1End.x - line1Start.x);
   CGFloat line2Slope = (line2End.y - line2Start.y) / (line2End.x - line2Start.x);
	
	CGFloat degs = acosf(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
	
   
	return (line2Slope > line1Slope) ? degs : -degs;	
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (180.0 * x / M_PI)


#define WHEEL_SPOKE_COUNT 12
#define WHEEL_SIZE_WIDTH 300
#define WHEEL_SIZE_HEIGHT 300
#define WHEEL_IMAGE_SIZE_WIDTH 80
#define WHEEL_IMAGE_SIZE_HEIGHT 80


@interface PhotoWheelViewController ()
@property (nonatomic, retain) UIView *wheelView;
@property (nonatomic, retain) NSMutableArray *wheelSubviews;
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) CGFloat lastAngle;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
- (void)setAngle:(CGFloat)angle;
@end

@implementation PhotoWheelViewController

@synthesize style = style_;
@synthesize wheelView = wheelView_;
@synthesize wheelSubviews = wheelSubviews_;
@synthesize currentAngle = currentAngle_;
@synthesize lastAngle = lastAngle_;
@synthesize interfaceOrientation = interfaceOrientation_;

- (void)dealloc
{
   [wheelView_ release];
   [wheelSubviews_ release];
   [super dealloc];
}

- (void)loadView
{
   CGRect idealFrame = CGRectZero; //CGRectMake(0, 0, WHEEL_SIZE_WIDTH, WHEEL_SIZE_HEIGHT);
   
   UIView *contentView = [[UIView alloc] initWithFrame:idealFrame];
   [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
   [self setView:contentView];
   [contentView release];
   
   // Create the array that holds each view on a wheel spoke.
   NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:WHEEL_SPOKE_COUNT];
   [self setWheelSubviews:newArray];
   [newArray release];

   // Create the wheel view.
   UIView *newWheelView = [[UIView alloc] initWithFrame:idealFrame]; //CGRectMake(0, 0, WHEEL_SIZE_WIDTH, WHEEL_SIZE_HEIGHT)];
   [newWheelView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
   [newWheelView setBackgroundColor:[UIColor yellowColor]];
   [self setWheelView:newWheelView];
   [newWheelView release];

   // Position the views to center on (0, 0).
   CGRect wheelSubviewFrame = CGRectMake(-(WHEEL_IMAGE_SIZE_WIDTH * 0.5), -(WHEEL_IMAGE_SIZE_HEIGHT * 0.5), WHEEL_IMAGE_SIZE_WIDTH, WHEEL_IMAGE_SIZE_HEIGHT);
   
   UIImage *defaultImage = [UIImage imageNamed:@"photoDefault.png"];
   for (NSInteger index=0; index < WHEEL_SPOKE_COUNT; index++) {
      PhotoWheelImageView *newView = [[PhotoWheelImageView alloc] initWithFrame:wheelSubviewFrame];
      [newView setImage:defaultImage];
      [[self wheelView] addSubview:newView];
      [[self wheelSubviews] addObject:newView];
      [newView release];
   }

   // Add the wheel view to the main view and position it.
   [[self view] addSubview:[self wheelView]];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self setStyle:PhotoWheelStyleWheel];
   [self setCurrentAngle:0.0];
   [self setLastAngle:0.0];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];

   [self setAngle:[self currentAngle]];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   [self setInterfaceOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   [self setAngle:[self currentAngle]];
}

// The follow code is inprised from the carousel example at:
// http://stackoverflow.com/questions/5243614/3d-carousel-effect-on-the-ipad
- (void)setAngle:(CGFloat)angle
{
   CGPoint wheelCenter = [[self wheelView] center];
   // Swap the points if interface oritentation is landscape.
   if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
      wheelCenter = CGPointMake(wheelCenter.y, wheelCenter.x);
   }

   CGPoint center = CGPointMake(wheelCenter.x , wheelCenter.y );
   CGFloat radiusX = [[self wheelView] bounds].size.width * 0.35;
   CGFloat radiusY = radiusX;
   if ([self style] == PhotoWheelStyleCarousel) {
      radiusY = radiusX * 0.30;
   }

   NSInteger spokeCount = [[self wheelSubviews] count];
   float angleToAdd = 360.0f / spokeCount;
   
   for(UIView *view in [self wheelSubviews])
   {
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
         
      }
      
      // setting the z position on the layer has the effect of setting the
      // draw order, without having to reorder our list of subviews
      [[view layer] setZPosition:scale];
      
      // work out what the next angle is going to be
      angle += angleToAdd;
   }
}


#pragma -
#pragma Touch Event Handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   // We only support single touches, so anyObject retrieves just that touch from touches
   UITouch *touch = [touches anyObject];
   
   // Only move the placard view if the touch was in the placard view
   if ([touch view] == [self view]) { 
      
//      CGPoint touchPoint = [touch locationInView:[self view]];
//      [self animateFirstTouchAtPoint:touchPoint];
   }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   // We only support single touches, so anyObject retrieves just that touch from touches
   UITouch *touch = [touches anyObject];
   
   // Only move the placard view if the touch was in the placard view
//   if ([touch view] == [self view]) { 
   {
      CGPoint wheelCenter = [[self wheelView] center];
      
      // use the movement of the touch to decide
      // how much to rotate the carousel
      CGPoint locationNow = [touch locationInView:[self view]];
      CGPoint locationThen = [touch previousLocationInView:[self view]];
      CGPoint oppositeNow = CGPointMake(wheelCenter.x + (wheelCenter.x - locationNow.x), wheelCenter.y + (wheelCenter.y - locationNow.y));
      CGPoint oppositeThen = CGPointMake(wheelCenter.x + (wheelCenter.x - locationThen.x), wheelCenter.y + (wheelCenter.y - locationThen.y));
      
      CGFloat angleInRadians = angleBetweenLinesInRadians(locationNow, oppositeNow, locationThen, oppositeThen);
      [self setLastAngle:[self currentAngle]];
      [self setCurrentAngle:[self currentAngle] + radiansToDegrees(angleInRadians)];

      [self setAngle:[self currentAngle]];
      
//      [[self imageView] setTransform:CGAffineTransformRotate([[self imageView] transform], angleInRadians)];
   }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   //   // if our touch ended then...
   //   if([touches containsObject:trackingTouch_])
   //   {
   //      // make sure we're no longer tracking it
   //      trackingTouch_ = nil;
   //   }
}


@end
