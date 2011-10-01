//
//  CustomPushSegue.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/12/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "CustomPushSegue.h"
#import "UIView+PWCategory.h"                                           // 1

@implementation CustomPushSegue

- (void)perform
{
   // UIView *sourceView = [[self sourceViewController] view];          // 2
   UIView *sourceView = [[[self sourceViewController] parentViewController] view];
   UIView *destinationView = [[self destinationViewController] view];   // 3
   
   UIImageView *sourceImageView;
   sourceImageView = [[UIImageView alloc] 
                      initWithImage:[sourceView pw_imageSnapshot]];     // 4
   
   UIImageView *destinationImageView;
   destinationImageView = [[UIImageView alloc] 
                           initWithImage:[destinationView pw_imageSnapshot]];
   CGRect originalFrame = [destinationImageView frame];
   [destinationImageView setFrame:CGRectMake(originalFrame.size.width/2, 
                                             originalFrame.size.height/2, 
                                             0, 
                                             0)];
   [destinationImageView setAlpha:0.3];                                 // 5
   
   
   UINavigationController *navController;
   navController = [[self sourceViewController] navigationController];  // 6
   [navController pushViewController:[self destinationViewController] 
                            animated:NO];                               // 7
   
   UINavigationBar *navBar = [navController navigationBar];             // 8
   [navController setNavigationBarHidden:NO];
   [navBar setFrame:CGRectOffset(navBar.frame, 
                                 0, 
                                 -navBar.frame.size.height)];           // 9
   
   [destinationView addSubview:sourceImageView];                        // 10
   [destinationView addSubview:destinationImageView];                   // 11
   
   void (^animations)(void) = ^ {                                       // 12
      [destinationImageView setFrame:originalFrame];                    // 13
      [destinationImageView setAlpha:1.0];                              // 14
      
      [navBar setFrame:CGRectOffset(navBar.frame, 
                                    0, 
                                    navBar.frame.size.height)];         // 15
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {                        // 16
      if (finished) {
         [sourceImageView removeFromSuperview];
         [destinationImageView removeFromSuperview];
      }
   };
   
   [UIView animateWithDuration:0.6 
                    animations:animations 
                    completion:completion];                             // 17
}

@end
