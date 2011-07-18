//
//  PhotoAlbumViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import "MainViewController.h"

@implementation PhotoAlbumViewController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize objectID = objectID_;

- (void)didMoveToParentViewController:(UIViewController *)parent
{
   // Position the view within the new parent.
   [[parent view] addSubview:[self view]];
   CGRect newFrame = CGRectMake(26, 18, 716, 717);
   [[self view] setFrame:newFrame];
}

- (IBAction)displayPhotoBrowser:(id)sender 
{
   id parent = [self parentViewController];
   if (parent && [parent respondsToSelector:@selector(displayPhotoBrowser)]) {
      [parent displayPhotoBrowser];
   }
}

- (void)refresh
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
