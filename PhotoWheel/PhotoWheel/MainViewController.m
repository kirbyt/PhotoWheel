//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoAlbumViewController.h"
#import "PhotoAlbumsViewController.h"

@implementation MainViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   UIStoryboard *storyboard = [self storyboard];
   
   PhotoAlbumsViewController *photoAlbumsScene = [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumsScene"];
   [self addChildViewController:photoAlbumsScene];
   [photoAlbumsScene didMoveToParentViewController:self];

   PhotoAlbumViewController *photoAlbumScene = [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumScene"];
   [self addChildViewController:photoAlbumScene];
   [photoAlbumScene didMoveToParentViewController:self];
}

@end
