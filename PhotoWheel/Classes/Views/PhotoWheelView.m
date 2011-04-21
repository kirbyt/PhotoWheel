//
//  PhotoWheelView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/20/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelView.h"
#import "PhotoNubViewController.h"
#import "PhotoWheel.h"
#import "Nub.h"
#import "KTGeometry.h"
#import <QuartzCore/QuartzCore.h>


@interface PhotoWheelView ()
@property (nonatomic, assign, readwrite) NSInteger nubCount;
@property (nonatomic, retain) NSMutableArray *nubControllers;
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) CGFloat lastAngle;

- (void)commonInit;
- (CGPoint)wheelCenter;
- (void)setStyle:(PhotoWheelStyle)style;
- (void)setAngle:(CGFloat)angle;
- (void)setPhotoWheel:(PhotoWheel *)photoWheel;
- (void)reloadNubs;
@end


@implementation PhotoWheelView

@synthesize nubCount = nubCount_;
@synthesize style = style_;
@synthesize photoWheel = photoWheel_;
@synthesize nubControllers = nubControllers_;
@synthesize currentAngle = currentAngle_;
@synthesize lastAngle = lastAngle_;

- (void)dealloc
{
   [nubControllers_ release], nubControllers_ = nil;
   [photoWheel_ release], photoWheel_ = nil;
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

- (void)layoutSubviews
{
   [self setAngle:[self currentAngle]];
}

- (void)commonInit
{
   // Create the array that holds each view on a wheel spoke.
   NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[self nubCount]];
   [self setNubControllers:newArray];
   [newArray release];

//   [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
   
   for (NSInteger index=0; index < [self nubCount]; index++) {
      PhotoNubViewController *newController = [[PhotoNubViewController alloc] init];
      [self addSubview:[newController view]];
      [[self nubControllers] addObject:newController];
      [newController release];
   }
   
   [self setCurrentAngle:0.0];
   [self setLastAngle:0.0];
}

- (CGPoint)wheelCenter
{
   CGPoint center = CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
   return center;
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

   CGPoint center = [self wheelCenter];
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

- (void)setPhotoWheel:(PhotoWheel *)photoWheel
{
   if (photoWheel_ != photoWheel) {
      [photoWheel retain];
      [photoWheel_ release];
      photoWheel_ = photoWheel;
      
      [self reloadNubs];
   }
}

- (void)reloadNubs
{
   NSManagedObjectContext *context = [[self photoWheel] managedObjectContext];
   
   for (NSInteger index=0; index < [[self nubControllers] count]; index++) {
      PhotoNubViewController *nubController = [[self nubControllers] objectAtIndex:index];
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sortOrder == %i", index];
      NSSet *nubSet = [[[self photoWheel] nubs] filteredSetUsingPredicate:predicate];
      if (nubSet && [nubSet count] > 0) {
         [nubController setNub:[nubSet anyObject]];
      } else {
         // Insert a new nub.
         Nub *newNub = [Nub insertNewInManagedObjectContext:context];
         [newNub setSortOrder:[NSNumber numberWithInt:index]];
         [newNub setPhotoWheel:[self photoWheel]];
         
         // Save the context.
         NSError *error = nil;
         if (![context save:&error])
         {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
         }
         
         [nubController setNub:newNub];
      }
   }
}


#pragma mark - Touch Event Handlers

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   // We only support single touches, so anyObject retrieves just that touch from touches
   UITouch *touch = [touches anyObject];
   
   CGPoint wheelCenter = CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
   
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
   
   [super touchesMoved:touches withEvent:event];
}

@end
