//
//  CustomNavigationController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/8/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomNavigationController : UINavigationController
{
    
}

- (void)pushViewController:(UIViewController *)viewController explodeFromPoint:(CGPoint)point;

@end
