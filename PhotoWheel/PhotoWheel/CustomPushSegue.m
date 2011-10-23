//
//  CustomPushSegue.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/12/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "CustomPushSegue.h"
#import "UIView+PWCategory.h"
#import "PhotoAlbumViewController.h"                                    // 1

@implementation CustomPushSegue

- (void)perform
{
   id sourceViewController = [self sourceViewController];               // 2
   
   UIView *sourceView = [[sourceViewController parentViewController] view];
   UIImageView *sourceImageView = [[UIImageView alloc] 
                                   initWithImage:[sourceView pw_imageSnapshot]];
   
   BOOL isLandscape = UIInterfaceOrientationIsLandscape(
      [sourceViewController interfaceOrientation]);                     // 3
   
   CGRect statusBarFrame = [[UIApplication sharedApplication] 
                            statusBarFrame];                            // 4
   CGFloat statusBarHeight;
   if (isLandscape) {                                                   // 5
      statusBarHeight = statusBarFrame.size.width;
   } else {
      statusBarHeight = statusBarFrame.size.height;
   }
   CGRect newFrame = CGRectOffset([sourceImageView frame], 0, statusBarHeight);
   [sourceImageView setFrame:newFrame];                                 // 6
   
   
   CGRect destinationFrame = [[UIScreen mainScreen] bounds];
   if (isLandscape) {                                                   // 7
      destinationFrame.size = CGSizeMake(destinationFrame.size.height, 
                                         destinationFrame.size.width);
   }
   
   UIImage *destinationImage = [sourceViewController selectedImage];
   UIImageView *destinationImageView = [[UIImageView alloc] 
                                        initWithImage:destinationImage];
   [destinationImageView setContentMode:UIViewContentModeScaleAspectFit];
   [destinationImageView setBackgroundColor:[UIColor blackColor]];
   [destinationImageView setFrame:[sourceViewController selectedCellFrame]];
   [destinationImageView setAlpha:0.3];
   
   UINavigationController *navController = 
      [sourceViewController navigationController];
   [navController pushViewController:[self destinationViewController] 
                            animated:NO];
   
   UINavigationBar *navBar = [navController navigationBar];
   [navController setNavigationBarHidden:NO];
   [navBar setFrame:CGRectOffset(navBar.frame, 0, -navBar.frame.size.height)];
   
   UIView *destinationView = [[self destinationViewController] view];
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
