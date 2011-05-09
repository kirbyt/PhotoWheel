//
//  CustomNavigationController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/8/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()
@property (nonatomic, assign) CGPoint implodeToPoint;
@property (nonatomic, assign) BOOL implodeNextPop;
@end

@implementation CustomNavigationController

@synthesize implodeToPoint = implodeToPoint_;
@synthesize implodeNextPop = implodeNextPop_;

- (void)pushViewController:(UIViewController *)viewController explodeFromPoint:(CGPoint)point
{
   [self setImplodeToPoint:point];
   [self setImplodeNextPop:YES];
   
   UIView *transitionToView = [viewController view];
   CGFloat transitionToAlpha = [transitionToView alpha];
   [transitionToView setAlpha:0.3];
   [transitionToView setFrame:CGRectMake(point.x, point.y, 0, 0)];
   
   UIViewController *topViewController = [self topViewController];
   UIView *transitionFromView = [topViewController view];
   [transitionFromView addSubview:transitionToView];
   
   CGRect bounds = [transitionFromView bounds];
   
   void (^animations)(void) = ^ {
      [transitionToView setFrame:bounds];
      [transitionToView setAlpha:transitionToAlpha];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      if (finished) {
         [self pushViewController:viewController animated:NO];
      }
   };

   [UIView animateWithDuration:0.6 animations:animations completion:completion];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
   UIViewController *poppedViewController = nil;
   
   if (animated && [self implodeNextPop]) {
      [self setImplodeNextPop:NO];
      
      UIViewController *transitionFromViewController = [self topViewController];
      UIView *transitionFromView = [transitionFromViewController view];
      
      poppedViewController = [super popViewControllerAnimated:NO];
      
      UIViewController *transitionToViewController = [self topViewController];
      UIView *transitionToView = [transitionToViewController view];
      
      [transitionToView addSubview:transitionFromView];
      CGPoint toPoint = [self implodeToPoint];
      
      void (^animations)(void) = ^ {
         [transitionFromView setFrame:CGRectMake(toPoint.x, toPoint.y, 0, 0)];
         [transitionFromView setAlpha:0.0];
      };
      
      void (^completion)(BOOL) = ^(BOOL finished) {
         [transitionFromView removeFromSuperview];
      };
      
      [UIView animateWithDuration:0.6 animations:animations completion:completion];
      
   } else {
      poppedViewController = [super popViewControllerAnimated:animated];
   }
   
   return poppedViewController;
}


@end
