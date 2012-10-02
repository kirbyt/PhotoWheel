//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "PhotosViewController.h"
#import "AlbumsViewController.h"
#import "AppDelegate.h"

@implementation MainViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   [self setSkipRotation:YES];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue destinationViewController] isKindOfClass:[AlbumsViewController class]]) {
      AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
      NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];

      AlbumsViewController *destinationViewController = [segue destinationViewController];
      [destinationViewController setManagedObjectContext:managedObjectContext];
      
      PhotosViewController *photosScene = [[self storyboard] instantiateViewControllerWithIdentifier:@"PhotosScene"];
      [destinationViewController setPhotoAlbumViewController:photosScene];
   }
}

#pragma mark - Rotation support

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
