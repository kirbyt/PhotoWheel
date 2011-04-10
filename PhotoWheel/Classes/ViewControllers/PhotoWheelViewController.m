//
//  PhotoWheelViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/31/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelViewController.h"
#import "PhotoWheelImageView.h"
#import "PhotoWheelImageViewController.h"
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


#define WHEEL_NUB_COUNT 12


@interface PhotoWheelViewController ()
@property (nonatomic, retain) UIView *wheelView;
@property (nonatomic, retain) NSMutableArray *wheelSubviewControllers;
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) CGFloat lastAngle;
@property (nonatomic, retain) UIViewController *controllerToPush;
@property (nonatomic, assign) CGPoint imageBrowserAnimationPoint;
- (void)setAngle:(CGFloat)angle;
@end

@implementation PhotoWheelViewController

@synthesize style = style_;
@synthesize wheelView = wheelView_;
@synthesize wheelSubviewControllers = wheelSubviewControllers_;
@synthesize currentAngle = currentAngle_;
@synthesize lastAngle = lastAngle_;
@synthesize controllerToPush = controllerToPush_;
@synthesize imageBrowserAnimationPoint = imageBrowserAnimationPoint_;

- (void)dealloc
{
   [wheelView_ release];
   [wheelSubviewControllers_ release];
   [controllerToPush_ release];
   [super dealloc];
}

- (void)loadView
{
   // Create the array that holds each view on a wheel spoke.
   NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:WHEEL_NUB_COUNT];
   [self setWheelSubviewControllers:newArray];
   [newArray release];
   
   UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
   [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
   [self setView:contentView];
   [contentView release];
   
   // Create the wheel view.
   UIView *newWheelView = [[UIView alloc] initWithFrame:CGRectZero];
   [newWheelView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
   [newWheelView setBackgroundColor:[UIColor yellowColor]];
   [self setWheelView:newWheelView];
   [newWheelView release];

   for (NSInteger index=0; index < WHEEL_NUB_COUNT; index++) {
      PhotoWheelImageViewController *newController = [[PhotoWheelImageViewController alloc] init];
      [newController setPhotoWheelViewController:self];
      [[self wheelView] addSubview:[newController view]];
      [[self wheelSubviewControllers] addObject:newController];
      [newController release];
   }

   // Add the wheel view to the main view and position it.
   [[self view] addSubview:[self wheelView]];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self setCurrentAngle:0.0];
   [self setLastAngle:0.0];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];

   [self setAngle:[self currentAngle]];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   [self setAngle:[self currentAngle]];
}

- (void)setStyle:(PhotoWheelStyle)style
{
   if (style_ != style) {
      style_ = style;
      [UIView beginAnimations:@"ChangeStyle" context:nil];
      [self setAngle:[self currentAngle]];
      [UIView commitAnimations];
   }
}


// The follow code is inprised from the carousel example at:
// http://stackoverflow.com/questions/5243614/3d-carousel-effect-on-the-ipad
- (void)setAngle:(CGFloat)angle
{
   CGPoint center = [[self wheelView] center];
   CGFloat radiusX = [[self wheelView] bounds].size.width * 0.35;
   CGFloat radiusY = radiusX;
   if ([self style] == PhotoWheelStyleCarousel) {
      radiusY = radiusX * 0.30;
   }

   NSInteger spokeCount = [[self wheelSubviewControllers] count];
   float angleToAdd = 360.0f / spokeCount;
   
   for(UIViewController *controller in [self wheelSubviewControllers])
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


#pragma mark -
#pragma mark Touch Event Handlers

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   // We only support single touches, so anyObject retrieves just that touch from touches
   UITouch *touch = [touches anyObject];
   
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
}


#pragma mark -
#pragma mark Public Methods

- (void)showImageBrowserFromPoint:(CGPoint)point
{
   [self setImageBrowserAnimationPoint:point];
   
   CGRect frame = CGRectMake(point.x, point.y, 0, 0);
   UIViewController *newViewController = [[UIViewController alloc] init];
   [self setControllerToPush:newViewController];
   [newViewController release];

   
   UIView *newView = [[self controllerToPush] view];
   [newView setFrame:frame];
   [newView setBackgroundColor:[UIColor magentaColor]];
   [newView setAlpha:0.4];
   
   [[self view] addSubview:newView];
   
   [UIView beginAnimations:@"showImageBrowser" context:nil];
   [UIView setAnimationDuration:0.6];
   
   CGRect bounds = [[self view] bounds];
   [newView setFrame:bounds];
   [newView setAlpha:1.0];
   
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(animationComplete:finished:target:)];
   
   [UIView commitAnimations];
   
}

- (void)hideImageBrowser
{
   [[self navigationController] popViewControllerAnimated:NO];
   
   UIView *view = [[self controllerToPush] view];
   [[self view] addSubview:view];
   
   [UIView beginAnimations:@"hideImageBrowser" context:nil];
   [UIView setAnimationDuration:0.6];
   
   CGPoint animateToPoint = [self imageBrowserAnimationPoint];
   CGRect frame = CGRectMake(animateToPoint.x, animateToPoint.y, 0, 0);
   [view setFrame:frame];
   [view setAlpha:0.0];
   
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(hideImageBrowserAnimationComplete:finished:target:)];
   
   [UIView commitAnimations];
}

- (void)hideImageBrowserAnimationComplete:(NSString *)animationId finished:(BOOL)finished target:(UIView *)target
{
   UIView *view = [[self controllerToPush] view];
   [view removeFromSuperview];
   [self setControllerToPush:nil];
}

- (void)animationComplete:(NSString *)animationId finished:(BOOL)finished target:(UIView *)target
{
   if (finished) {
      [[self navigationController] pushViewController:[self controllerToPush] animated:NO];
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
      [[[self controllerToPush] view] addGestureRecognizer:tap];
      [tap release];
      
      //[self setControllerToPush:nil];
   }
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
   [self hideImageBrowser];
}


@end
