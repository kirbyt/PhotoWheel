//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "PhotosViewController.h"
#import "AlbumsViewController.h"
#import "AppDelegate.h"

@implementation MainViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
   
   if ([[segue destinationViewController] isKindOfClass:[AlbumsViewController class]]) {
      AlbumsViewController *destinationViewController = [segue destinationViewController];
      [destinationViewController setManagedObjectContext:managedObjectContext];
   }
   
   if ([[segue destinationViewController] isKindOfClass:[PhotosViewController class]]) {
      PhotosViewController *destinationViewController = [segue destinationViewController];
      [destinationViewController setManagedObjectContext:managedObjectContext];
   }
}

@end
