//
//  PhotoAlbumMenuViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/27/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumMenuViewController.h"
#import "PhotoAlbumViewController.h"
#import "IconButton.h"
#import "IconMenuView.h"


@implementation PhotoAlbumMenuViewController

@synthesize photoAlbumViewController = photoAlbumViewController_;

- (void)loadView
{
   IconMenuView *newView = [[IconMenuView alloc] initWithFrame:CGRectZero];
   [self setView:newView];
   [newView release];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   CGSize size = CGSizeMake(520, 100);
   [[self view] setFrame:CGRectMake(0, 0, size.width, size.height)];
   [self setContentSizeForViewInPopover:size];
   [[self view] setBackgroundColor:[UIColor whiteColor]];
   
   NSMutableArray *buttons = [[NSMutableArray alloc] init];

   IconButton *emailButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-email.png"] title:@"Email"];
   [emailButton addTarget:[self photoAlbumViewController] action:@selector(emailPhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
   [buttons addObject:emailButton];
   
//   IconButton *slideshowButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-slideshow.png"] title:@"Slideshow"];
//   [slideshowButton addTarget:[self photoAlbumViewController] action:@selector(slideshow:) forControlEvents:UIControlEventTouchUpInside];
//   [buttons addObject:slideshowButton];

   IconButton *printButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-print.png"] title:@"Print"];
   [printButton addTarget:[self photoAlbumViewController] action:@selector(printPhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
   [buttons addObject:printButton];

   IconButton *removeButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-remove.png"] title:@"Remove"];
   [removeButton addTarget:[self photoAlbumViewController] action:@selector(removePhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
   [buttons addObject:removeButton];
   
   [(IconMenuView *)[self view] setButtons:buttons];
   [buttons release];
}

@end
