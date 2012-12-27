//
//  CustomPushSegue.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/13/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "CustomPushSegue.h"
#import "UIView+PWCategory.h"
#import "MainViewController.h"

@implementation CustomPushSegue

- (void)perform
{
   id sourceViewController = [self sourceViewController];
   id destinationViewController = [self destinationViewController];
   
   UIView *sourceView = [sourceViewController view];
   UIImage *sourceViewImage = [sourceView pw_imageSnapshot];
   UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:sourceViewImage];
   
   UIInterfaceOrientation orientation = [sourceViewController interfaceOrientation];
   BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
   
   UIApplication *app = [UIApplication sharedApplication];
   CGRect statusBarFrame = [app statusBarFrame];
   
   CGFloat statusBarHeight;
   if (isLandscape) {
      statusBarHeight = statusBarFrame.size.width;
   } else {
      statusBarHeight = statusBarFrame.size.height;
   }
   CGRect imageViewFrame = [sourceImageView frame];
   CGRect newFrame = CGRectOffset(imageViewFrame, 0, statusBarHeight);
   [sourceImageView setFrame:newFrame];
   
   
   CGRect destinationFrame = [[UIScreen mainScreen] bounds];
   if (isLandscape) {
      destinationFrame.size = CGSizeMake(destinationFrame.size.height, 
                                         destinationFrame.size.width);
   }
   
   UIImage *destinationImage = [sourceViewController selectedPhotoImage];
   UIImageView *destinationImageView = [[UIImageView alloc] initWithImage:destinationImage];
   [destinationImageView setContentMode:UIViewContentModeScaleAspectFit];
   [destinationImageView setBackgroundColor:[UIColor blackColor]];
   
   CGRect frame = [sourceViewController selectedPhotoFrame];
   frame = CGRectOffset(frame, 0, statusBarHeight);
   [destinationImageView setFrame:frame];
   [destinationImageView setAlpha:0.3];
   
   UINavigationController *navController = [sourceViewController navigationController];
   [navController pushViewController:destinationViewController animated:NO];
   
   UINavigationBar *navBar = [navController navigationBar];
   [navController setNavigationBarHidden:NO];
   [navBar setFrame:CGRectOffset(navBar.frame, 0, -navBar.frame.size.height)];
   
   UIView *destinationView = [destinationViewController view];
   [destinationView addSubview:sourceImageView];
   [destinationView addSubview:destinationImageView];
   
   void (^animations)(void) = ^ {
      [destinationImageView setFrame:destinationFrame];
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
