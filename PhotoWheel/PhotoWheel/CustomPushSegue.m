//
//  CustomPushSegue.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/12/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "CustomPushSegue.h"
#import "UIView+PWCategory.h"
#import "PhotoBrowserViewController.h"

@implementation CustomPushSegue

- (void)perform
{
   UIView *sourceView = [[[self sourceViewController] parentViewController] view];
   UIView *destinationView = [[self destinationViewController] view];
   
   UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:[sourceView pw_imageSnapshot]];
   
   UIImageView *destinationImageView = [[UIImageView alloc] initWithImage:[destinationView pw_imageSnapshot]];
   CGRect originalFrame = [destinationImageView frame];
   CGRect pushFromFrame = [[self destinationViewController] pushFromFrame];
   [destinationImageView setFrame:pushFromFrame];
   [destinationImageView setAlpha:0.3];
   
   
   UINavigationController *navController = [[self sourceViewController] navigationController];
   [navController pushViewController:[self destinationViewController] animated:NO];
   
   UINavigationBar *navBar = [navController navigationBar];
   [navController setNavigationBarHidden:NO];
   [navBar setFrame:CGRectOffset(navBar.frame, 0, -navBar.frame.size.height)];

   [destinationView addSubview:sourceImageView];
   [destinationView addSubview:destinationImageView];
   
   void (^animations)(void) = ^ {
      [destinationImageView setFrame:originalFrame];
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
