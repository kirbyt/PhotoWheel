//
//  UINavigationController+KTTransitions.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/11/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UINavigationController (UINavigationController_KTTransitions)

- (void)kt_pushViewController:(UIViewController *)viewController explodeFromPoint:(CGPoint)fromPoint;
- (void)kt_popViewControllerImplodeToPoint:(CGPoint)toPoint;

@end
