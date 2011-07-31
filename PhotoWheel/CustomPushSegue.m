//
//  CustomPushSegue.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "CustomPushSegue.h"
#import "UIView+PWCategory.h"
#import "PhotoBrowserViewController.h"

@implementation CustomPushSegue

- (void)perform
{
   UIView *sourceView = [[[self sourceViewController] parentViewController] view];
   UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:[sourceView pw_imageSnapshot]];

   UIView *destinationView = [[self destinationViewController] view];
   UIImageView *destinationImageView = [[UIImageView alloc] initWithImage:[destinationView pw_imageSnapshot]];
   CGRect pushFromFrame = [[self destinationViewController] pushFromFrame];
   [destinationImageView setFrame:pushFromFrame];
   [destinationImageView setAlpha:0.3];

   [destinationView addSubview:sourceImageView];
   [destinationView addSubview:destinationImageView];
   
   UINavigationController *navController = [[self sourceViewController] navigationController];
   [navController pushViewController:[self destinationViewController] animated:NO];

   // Move the bav bar off the screen. It will drop down as part of the animation sequence.
   UINavigationBar *navBar = [navController navigationBar];
   [navController setNavigationBarHidden:NO];
   [navBar setFrame:CGRectOffset(navBar.frame, 0, -navBar.frame.size.height)];

   void (^animations)(void) = ^ {
      [destinationImageView setFrame:[destinationView bounds]];
      [destinationImageView setAlpha:1.0];
      
      [navBar setFrame:CGRectOffset(navBar.frame, 0, navBar.frame.size.height)];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      if (finished) {
         [sourceImageView removeFromSuperview];
         [destinationImageView removeFromSuperview];
      }
   };
   
   [UIView animateWithDuration:0.6 animations:animations completion:completion];
}

@end
