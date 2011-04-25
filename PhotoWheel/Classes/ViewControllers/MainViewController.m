//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/22/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoWheelView.h"


@interface MainViewController ()
- (void)layoutForLandscape;
- (void)layoutForPortrait;
@end

@implementation MainViewController

@synthesize backgroundImageView = backgroundImageView_;
@synthesize photoWheelView = photoWheelView_;
@synthesize managedObjectContext = managedObjectContext_;

- (void)dealloc
{
   [backgroundImageView_ release], backgroundImageView_ = nil;
   [photoWheelView_ release], photoWheelView_ = nil;
   [managedObjectContext_ release], managedObjectContext_ = nil;
   [super dealloc];
}

- (id)init
{
   self = [super initWithNibName:@"MainView" bundle:nil];
   if (self) {
      
   }
   return self;
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   [self setBackgroundImageView:nil];
   [self setPhotoWheelView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      [self layoutForLandscape];
   } else {
      [self layoutForPortrait];
   }
}

- (void)layoutForLandscape
{
   UIImage *backgroundImage = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
   [[self backgroundImageView] setImage:backgroundImage];
   
   CGPoint newOrigin = CGPointMake(-250, 180);
   CGRect frame = [[self photoWheelView] frame];
   frame.origin = newOrigin;
   [[self photoWheelView] setFrame:frame];
}

- (void)layoutForPortrait
{
   UIImage *backgroundImage = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
   [[self backgroundImageView] setImage:backgroundImage];
   
   CGPoint newOrigin = CGPointMake(84, 756);
   CGRect frame = [[self photoWheelView] frame];
   frame.origin = newOrigin;
   [[self photoWheelView] setFrame:frame];
}

@end
