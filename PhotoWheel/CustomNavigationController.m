//
//  CustomNavigationController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/13/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "CustomNavigationController.h"
#import "UIView+PWCategory.h"
#import "MainViewController.h"
#import "PhotoBrowserViewController.h"

@implementation CustomNavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
   UIViewController *sourceViewController = [self topViewController];
   
   if (![sourceViewController isKindOfClass: [PhotoBrowserViewController class]]) {
      return [super popViewControllerAnimated:animated];
   }
   // Animates image snapshot of the view.
   UIView *sourceView = [sourceViewController view];
   UIImage *sourceViewImage = [sourceView pw_imageSnapshot];
   UIImageView *sourceImageView = nil;
   sourceImageView = [[UIImageView alloc] initWithImage:sourceViewImage];
   
   // Offset the sourceImageView frame by the height of the status bar.
   // This prevents the image from dropping down after the view controller
   // is popped from the stack.
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
   CGRect newFrame = CGRectOffset([sourceImageView frame], 0, -statusBarHeight);
   [sourceImageView setFrame:newFrame];
   
   NSArray *viewControllers = [self viewControllers];
   NSInteger count = [viewControllers count];
   NSInteger index = count - 2;
   
   id destinationViewController = [viewControllers objectAtIndex:index];
   UIView *destinationView = [destinationViewController view];
   UIImage *destinationViewImage = [destinationView pw_imageSnapshot];
   UIImageView *destinationImageView = [[UIImageView alloc] initWithImage:destinationViewImage];
   
   [super popViewControllerAnimated:NO];
   
   [destinationView addSubview:destinationImageView];
   [destinationView addSubview:sourceImageView];
   
   CGRect selectedPhotoFrame = [destinationViewController selectedPhotoFrame];
   CGPoint shrinkToPoint = CGPointMake(CGRectGetMidX(selectedPhotoFrame), CGRectGetMidY(selectedPhotoFrame));
   
   void (^animations)(void) = ^ {
      [sourceImageView setFrame:CGRectMake(shrinkToPoint.x, shrinkToPoint.y, 0, 0)];
      [sourceImageView setAlpha:0.0];
      
      // Animate the nav bar too.
      UINavigationBar *navBar = [self navigationBar];
      [navBar setFrame:CGRectOffset(navBar.frame, 0, -navBar.frame.size.height)];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      [self setNavigationBarHidden:YES];
      // Reset the nav bar's position.
      UINavigationBar *navBar = [self navigationBar];
      [navBar setFrame:CGRectOffset(navBar.frame, 0, navBar.frame.size.height)];
      
      [sourceImageView removeFromSuperview];
      [destinationImageView removeFromSuperview];
   };
   
   [UIView transitionWithView:destinationView duration:0.3 options:UIViewAnimationOptionTransitionNone animations:animations completion:completion];
   
   return sourceViewController;
}

@end
