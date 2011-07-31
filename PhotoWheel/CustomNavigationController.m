//
//  CustomNavigationController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "CustomNavigationController.h"
#import "UIView+PWCategory.h"
#import "PhotoBrowserViewController.h"

@implementation CustomNavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
   // Customize the transition for popping from the 
   // PhotoBrowserViewController only. If self is not
   // the photo browser then fall back to the default
   // transition.
   UIViewController *sourceViewController = [self topViewController];
   if ([sourceViewController isKindOfClass:[PhotoBrowserViewController class]] == NO) {
      return [super popViewControllerAnimated:animated];
   }
   
   // Animates image snapshot of the view.
   UIView *sourceView = [sourceViewController view];
   UIImage *sourceViewImage = [sourceView pw_imageSnapshot];
   UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:sourceViewImage];
   
   NSArray *viewControllers = [self viewControllers];
   NSInteger count = [viewControllers count];
   NSInteger index = count - 2;
   
   UIViewController *destinationViewController =[viewControllers objectAtIndex:index];
   UIView *destinationView = [destinationViewController view];
   
   [super popViewControllerAnimated:NO];
   [destinationView addSubview:sourceImageView];
   
   CGRect pushedFromFrame = [(PhotoBrowserViewController *)sourceViewController pushedFromFrame];
   CGRect frame = [sourceView convertRect:pushedFromFrame fromView:destinationView];
   CGPoint shrinkToPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
   
   void (^animations)(void) = ^ {
      [sourceImageView setFrame:CGRectMake(shrinkToPoint.x, shrinkToPoint.y, 0, 0)];
      [sourceImageView setAlpha:0.0];
      
      // Animate the nav bar too.
      UINavigationBar *navBar = [self navigationBar];
      [navBar setFrame:CGRectOffset(navBar.frame, 0, -navBar.frame.size.height)];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      [self setNavigationBarHidden:YES];
      // Reset the nav bar position.
      UINavigationBar *navBar = [self navigationBar];
      [navBar setFrame:CGRectOffset(navBar.frame, 0, navBar.frame.size.height)];
      
      [sourceImageView removeFromSuperview];
   };
   
   [UIView transitionWithView:destinationView
                     duration:0.3
                      options:UIViewAnimationOptionTransitionNone
                   animations:animations
                   completion:completion];
   
   return sourceViewController;
}

@end
