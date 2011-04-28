//
//  PhotoWheelViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/31/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelViewController.h"
#import "PhotoNubViewController.h"
#import "UINavigationController+KTTransitions.h"
#import "PhotoAlbum.h"
#import "Photo.h"
#import <QuartzCore/QuartzCore.h>


#define WHEEL_NUB_COUNT 8


@interface PhotoWheelViewController ()
@property (nonatomic, retain) UIView *wheelView;
@property (nonatomic, retain) NSMutableArray *wheelSubviewControllers;
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) CGFloat lastAngle;
@property (nonatomic, retain) UIViewController *controllerToPush;
@property (nonatomic, assign) CGPoint imageBrowserAnimationPoint;
- (void)updateNubs;
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
@synthesize photoWheel = photoWheel_;

- (void)dealloc
{
   [wheelView_ release], wheelView_ = nil;
   [wheelSubviewControllers_ release], wheelSubviewControllers_ = nil;
   [controllerToPush_ release], controllerToPush_ = nil;
   [photoWheel_ release], photoWheel_ = nil;
   
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
   [newWheelView setAlpha:0.0];
   [self setWheelView:newWheelView];
   [newWheelView release];

   for (NSInteger index=0; index < WHEEL_NUB_COUNT; index++) {
      PhotoNubViewController *newController = [[PhotoNubViewController alloc] init];
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

- (void)setPhotoWheel:(PhotoAlbum *)photoWheel
{
   if (photoWheel_ != photoWheel) {
      [photoWheel retain];
      [photoWheel_ release];
      photoWheel_ = photoWheel;
      
      [self updateNubs];
   }
}

- (void)updateNubs
{
   NSManagedObjectContext *context = [[self photoWheel] managedObjectContext];
   
   for (NSInteger index=0; index < [[self wheelSubviewControllers] count]; index++) {
      PhotoNubViewController *nubController = [[self wheelSubviewControllers] objectAtIndex:index];

      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sortOrder == %i", index];
      NSSet *nubSet = [[[self photoWheel] nubs] filteredSetUsingPredicate:predicate];
      if (nubSet && [nubSet count] > 0) {
         [nubController setNub:[nubSet anyObject]];
      } else {
         // Insert a new nub.
         Photo *newNub = [Photo insertNewInManagedObjectContext:context];
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
   
   CGFloat alpha = [self photoWheel] ? 1.0 : 0.0;
   
   [UIView beginAnimations:@"showWheelView" context:nil];
   [[self wheelView] setAlpha:alpha];
   [UIView commitAnimations];
}


#pragma mark - Public Methods

- (void)showImageBrowserFromPoint:(CGPoint)point startAtIndex:(NSInteger)index
{
   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sortOrder == %i", index];
   NSSet *nubs = [[[self photoWheel] nubs] filteredSetUsingPredicate:predicate];
   Photo *nub = [nubs anyObject];
   UIImage *image = [nub largeImage];
   
   [self setImageBrowserAnimationPoint:point];

   UIViewController *newViewController = [[UIViewController alloc] init];
   UIView *view = [newViewController view];
   [[view layer] setContents:(id)[image CGImage]];
   [[view layer] setContentsGravity:kCAGravityResizeAspectFill];
   
   
   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageBrowser:)];
   [[newViewController view] addGestureRecognizer:tap];
   [tap release];
   
   [[self navigationController] kt_pushViewController:newViewController explodeFromPoint:point];
   [newViewController release];
}

- (void)hideImageBrowser:(UITapGestureRecognizer *)recognizer
{
   CGPoint animateToPoint = [self imageBrowserAnimationPoint];
   [[self navigationController] kt_popViewControllerImplodeToPoint:animateToPoint];
}


@end
