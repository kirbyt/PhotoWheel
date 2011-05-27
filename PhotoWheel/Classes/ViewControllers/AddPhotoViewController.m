//
//  AddPhotoViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "AddPhotoViewController.h"
#import "PhotoAlbumViewController.h"
#import "IconMenuView.h"
#import "IconButton.h"
#import "UIDevice+KTDeviceExtensions.h"


@interface AddPhotoViewController ()
- (void)addFromCamera:(id)sender;
- (void)addFromLibrary:(id)sender;
- (void)addFromFlickr:(id)sender;
@end

@implementation AddPhotoViewController

@synthesize photoAlbumViewController = photoAlbumViewController_;

- (void)dealloc
{
   [super dealloc];
}

- (void)loadView
{
   IconMenuView *newView = [[IconMenuView alloc] initWithFrame:CGRectZero];
   [self setView:newView];
   [newView release];
}

- (void)viewDidLoad
{
   [super viewDidLoad];

   CGSize size = CGSizeMake(320, 100);
   [[self view] setFrame:CGRectMake(0, 0, size.width, size.height)];
   [self setContentSizeForViewInPopover:size];
   [[self view] setBackgroundColor:[UIColor whiteColor]];

   NSMutableArray *buttons = [[NSMutableArray alloc] init];
   
   if ([UIDevice kt_hasCamera]) {
      IconButton *cameraButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-camera.png"] title:@"Camera"];
      [cameraButton addTarget:self action:@selector(addFromCamera:) forControlEvents:UIControlEventTouchUpInside];
      [buttons addObject:cameraButton];
   }
   
   IconButton *libraryButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-library.png"] title:@"Library"];
   [libraryButton addTarget:self action:@selector(addFromLibrary:) forControlEvents:UIControlEventTouchUpInside];
   [buttons addObject:libraryButton];
   
   IconButton *flickrButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-flickr.png"] title:@"Flickr"];
   [flickrButton addTarget:self action:@selector(addFromFlickr:) forControlEvents:UIControlEventTouchUpInside];
   [buttons addObject:flickrButton];
   
   [(IconMenuView *)[self view] setButtons:buttons];
   [buttons release];
}

#pragma mark - Actions

- (IBAction)addFromCamera:(id)sender
{
   [[self photoAlbumViewController] addFromCamera];
}

- (IBAction)addFromLibrary:(id)sender
{
   [[self photoAlbumViewController] addFromLibrary];
}

- (IBAction)addFromFlickr:(id)sender
{
   [[self photoAlbumViewController] addFromFlickr];
}

@end
