//
//  UINavigationController+KTTransitions.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/11/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "UINavigationController+KTTransitions.h"


@implementation UINavigationController (UINavigationController_KTTransitions)

- (void)kt_pushViewController:(UIViewController *)viewController explodeFromPoint:(CGPoint)fromPoint
{
   UIView *transitionToView = [viewController view];
   CGFloat transitionToAlpha = [transitionToView alpha];
   [transitionToView setAlpha:0.3];
   [transitionToView setFrame:CGRectMake(fromPoint.x, fromPoint.y, 0, 0)];
   
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
   
   [UIView animateWithDuration:10.3 animations:animations completion:completion];
}

- (void)kt_popViewControllerImplodeToPoint:(CGPoint)toPoint
{
   UIViewController *transitionFromViewController = [self topViewController];
   UIView *transitionFromView = [transitionFromViewController view];
   
   [self popViewControllerAnimated:NO];
   
   UIViewController *transitionToViewController = [self topViewController];
   UIView *transitionToView = [transitionToViewController view];
   
   [transitionToView addSubview:transitionFromView];

   void (^animations)(void) = ^ {
      [transitionFromView setFrame:CGRectMake(toPoint.x, toPoint.y, 0, 0)];
      [transitionFromView setAlpha:0.0];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      [transitionFromView removeFromSuperview];
   };

   [UIView animateWithDuration:0.3 animations:animations completion:completion];
}

@end
