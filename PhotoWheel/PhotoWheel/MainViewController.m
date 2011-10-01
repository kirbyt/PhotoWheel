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
#import "AppDelegate.h"

@implementation MainViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   AppDelegate *appDelegate = 
      (AppDelegate *)[[UIApplication sharedApplication] delegate];      // 1
   NSManagedObjectContext *managedObjectContext = 
      [appDelegate managedObjectContext];                               // 2
   
   UIStoryboard *storyboard = [self storyboard];
   
   PhotoAlbumsViewController *photoAlbumsScene = 
      [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumsScene"];
   [photoAlbumsScene setManagedObjectContext:managedObjectContext];     // 3
   [self addChildViewController:photoAlbumsScene];
   [photoAlbumsScene didMoveToParentViewController:self];
   
   PhotoAlbumViewController *photoAlbumScene = 
      [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumScene"];
   [self addChildViewController:photoAlbumScene];
   [photoAlbumScene didMoveToParentViewController:self];
   
   [photoAlbumsScene setPhotoAlbumViewController:photoAlbumScene];
}

@end
