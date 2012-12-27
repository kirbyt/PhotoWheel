//
//  CustomPushSegue.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/13/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "CustomPushSegue.h"
#import "UIView+PWCategory.h"
#import "MainViewController.h"                                          // 1

@implementation CustomPushSegue

- (void)perform
{
   id sourceViewController = [self sourceViewController];               // 2
   id destinationViewController = [self destinationViewController];
   
   UIView *sourceView = [sourceViewController view];
   UIImage *sourceViewImage = [sourceView pw_imageSnapshot];
   UIImageView *sourceImageView = nil;
   sourceImageView = [[UIImageView alloc] initWithImage:sourceViewImage];
   
   UIInterfaceOrientation orientation;
   orientation = [sourceViewController interfaceOrientation];
   BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);   // 3
   
   UIApplication *app = [UIApplication sharedApplication];
   CGRect statusBarFrame = [app statusBarFrame];                        // 4
   
   CGFloat statusBarHeight;
   if (isLandscape) {                                                   // 5
      statusBarHeight = statusBarFrame.size.width;
   } else {
      statusBarHeight = statusBarFrame.size.height;
   }
   CGRect imageViewFrame = [sourceImageView frame];
   CGRect newFrame = CGRectOffset(imageViewFrame, 0, statusBarHeight);
   [sourceImageView setFrame:newFrame];                                 // 6
   
   
   CGRect destinationFrame = [[UIScreen mainScreen] bounds];
   if (isLandscape) {                                                   // 7
      destinationFrame.size = CGSizeMake(destinationFrame.size.height, 
                                         destinationFrame.size.width);
   }
   
   UIImage *destinationImage = [sourceViewController selectedPhotoImage];
   UIImageView *destinationImageView = nil;
   destinationImageView = [[UIImageView alloc] initWithImage:destinationImage];
   [destinationImageView setContentMode:UIViewContentModeScaleAspectFit];
   [destinationImageView setBackgroundColor:[UIColor blackColor]];
   
   CGRect frame = [sourceViewController selectedPhotoFrame];
   frame = CGRectOffset(frame, 0, statusBarHeight);
   [destinationImageView setFrame:frame];
   [destinationImageView setAlpha:0.3];
   
   UINavigationController *navController = nil;
   navController = [sourceViewController navigationController];
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
