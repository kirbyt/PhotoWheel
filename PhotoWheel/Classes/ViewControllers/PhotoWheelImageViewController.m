//
//  PhotoWheelImageViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/9/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelImageViewController.h"
#import "PhotoWheelImageView.h"


#define WHEEL_IMAGE_SIZE_WIDTH 80
#define WHEEL_IMAGE_SIZE_HEIGHT 80


@implementation PhotoWheelImageViewController

- (void)loadView
{
   CGRect wheelSubviewFrame = CGRectMake(-(WHEEL_IMAGE_SIZE_WIDTH * 0.5), -(WHEEL_IMAGE_SIZE_HEIGHT * 0.5), WHEEL_IMAGE_SIZE_WIDTH, WHEEL_IMAGE_SIZE_HEIGHT);

   UIImage *defaultImage = [UIImage imageNamed:@"photoDefault.png"];
   PhotoWheelImageView *newView = [[PhotoWheelImageView alloc] initWithFrame:wheelSubviewFrame];
   [newView setImage:defaultImage];
   [self setView:newView];
   [newView release];
}


@end
