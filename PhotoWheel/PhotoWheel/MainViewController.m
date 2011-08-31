//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoAlbumViewController.h"
#import "PhotoAlbumsViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()
@property (nonatomic, assign) BOOL skipRotation;
@end

@implementation MainViewController

@synthesize backgroundImageView = backgroundImageView_;
@synthesize infoButton = infoButton_;
@synthesize skipRotation = skipRotation_;

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
   
   UIStoryboard *storyboard = [self storyboard];
   
   PhotoAlbumsViewController *photoAlbumsScene = [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumsScene"];
   [photoAlbumsScene setManagedObjectContext:managedObjectContext];
   [self addChildViewController:photoAlbumsScene];
   [photoAlbumsScene didMoveToParentViewController:self];

   PhotoAlbumViewController *photoAlbumScene = [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumScene"];
   [self addChildViewController:photoAlbumScene];
   [photoAlbumScene didMoveToParentViewController:self];
   
   [photoAlbumsScene setPhotoAlbumViewController:photoAlbumScene];
   [self setSkipRotation:YES];
}

- (void)viewDidUnload
{
   [self setBackgroundImageView:nil];
   [self setInfoButton:nil];
   [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];

   if ([self skipRotation] == NO) {
      UIInterfaceOrientation interfaceOrientation = [self interfaceOrientation];
      NSTimeInterval interval = 0.35;

      void (^animation)() = ^ {
         [self willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:interval];
         for (UIViewController *childController in [self childViewControllers]) {
            [childController willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:interval];
         }
      };
      
      [UIView animateWithDuration:interval animations:animation];
   }
   [self setSkipRotation:NO];
}

#pragma mark - Rotation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (void)layoutForLandscape
{
   UIImage *backgroundImage = [UIImage imageNamed:@"background-landscape-right-grooved.png"];
   [[self backgroundImageView] setImage:backgroundImage];
   
   CGRect frame = [[self infoButton] frame];
   frame.origin = CGPointMake(981, 712);
   [[self infoButton] setFrame:frame];
}

- (void)layoutForPortrait
{
   UIImage *backgroundImage = [UIImage imageNamed:@"background-portrait-grooved.png"]; 
   [[self backgroundImageView] setImage:backgroundImage];
   
   CGRect frame = [[self infoButton] frame];
   frame.origin = CGPointMake(723, 960);
   [[self infoButton] setFrame:frame];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      [self layoutForLandscape];
   } else {
      [self layoutForPortrait];
   }
}


@end
