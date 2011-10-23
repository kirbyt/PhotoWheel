//
//  PhotoAlbumsViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumsViewController.h"

@implementation PhotoAlbumsViewController

- (void)didMoveToParentViewController:(UIViewController *)parent
{
   // Position the view within the new parent.
   [[parent view] addSubview:[self view]];
   CGRect newFrame = CGRectMake(109, 680, 551, 550);
   [[self view] setFrame:newFrame];   
   
   [[self view] setBackgroundColor:[UIColor clearColor]];
}

@end
