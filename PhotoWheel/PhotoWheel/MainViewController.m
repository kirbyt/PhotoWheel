//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"                                          // 1
#import "PhotoAlbumViewController.h"
#import "PhotoAlbumsViewController.h"

@implementation MainViewController

- (void)viewDidLoad                                                     // 2
{
   [super viewDidLoad];
   
   UIStoryboard *storyboard = [self storyboard];                        // 3
   
   PhotoAlbumsViewController *photoAlbumsScene;                         // 4
   photoAlbumsScene = 
      [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumsScene"];           
   [self addChildViewController:photoAlbumsScene];                      // 5
   [photoAlbumsScene didMoveToParentViewController:self];               // 6
   
   PhotoAlbumViewController *photoAlbumScene;                           // 7
   photoAlbumScene = [storyboard 
                      instantiateViewControllerWithIdentifier:@"PhotoAlbumScene"];
   [self addChildViewController:photoAlbumScene];                       // 8
   [photoAlbumScene didMoveToParentViewController:self];                // 9
}

@end
