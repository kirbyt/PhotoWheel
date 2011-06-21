//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoAlbumViewController.h"

@implementation MainViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   PhotoAlbumViewController *childController = [[self storyboard] instantiateViewControllerWithIdentifier:@"PhotoAlbumScene"];
   [self addChildViewController:childController];
   [childController didMoveToParentViewController:self];
}

- (void)displayPhotoBrowser
{
   [self performSegueWithIdentifier:@"PhotoBrowserSegue" sender:self];
}

@end
