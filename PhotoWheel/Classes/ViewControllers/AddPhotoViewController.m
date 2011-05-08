//
//  AddPhotoViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "AddPhotoViewController.h"
#import "PhotoAlbumViewController.h"
#import "IconButton.h"
#import "UIDevice+KTDeviceExtensions.h"


@interface AddPhotoViewController ()
@property (nonatomic, retain) NSMutableArray *buttons;
- (void)addFromCamera:(id)sender;
- (void)addFromLibrary:(id)sender;
- (void)addFromFlickr:(id)sender;
@end

@implementation AddPhotoViewController

@synthesize photoAlbumViewController = photoAlbumViewController_;
@synthesize buttons = buttons_;


- (void)dealloc
{
   [buttons_ release], buttons_ = nil;
   [super dealloc];
}

//- (id)init
//{
////   self = [super initWithNibName:@"AddPhotoView" bundle:nil];
//   self = [super init];
//   if (self) {
//      [self setContentSizeForViewInPopover:CGSizeMake(320, 100)];
//   }
//   return self;
//}

//- (void)loadView
//{
//   [self loadView];
//   
//   NSMutableArray *buttons = [[NSMutableArray alloc] init];
//
//   if ([UIDevice kt_hasCamera]) {
//      IconButton *cameraButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-camera.png"] title:@"Camera"];
//      [cameraButton addTarget:self action:@selector(addFromCamera:) forControlEvents:UIControlStateNormal];
//      [buttons addObject:cameraButton];
//      [cameraButton release];
//   }
//
//   IconButton *libraryButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-library.png"] title:@"Library"];
//   [libraryButton addTarget:self action:@selector(addFromLibrary:) forControlEvents:UIControlStateNormal];
//   [buttons addObject:libraryButton];
//   [libraryButton release];
//   
//   IconButton *flickrButton = [IconButton iconButtonWithImage:[UIImage imageNamed:@"icon-flickr.png"] title:@"Flickr"];
//   CGRect buttonFrame = [flickrButton frame];   // Need this for layout calculations.
//   [flickrButton addTarget:self action:@selector(addFromFlickr:) forControlEvents:UIControlStateNormal];
//   [buttons addObject:flickrButton];
//   [flickrButton release];
//
//   // Evenly distribute the buttons across the view.
//   NSInteger width = 320;
//   NSInteger height = 100;
//   NSInteger incrementXBy = (width - (buttonFrame.size.width * [buttons count])) / [buttons count];
//   NSInteger x = incrementXBy;
//   NSInteger y = (height - buttonFrame.size.height) / 2;
//   for (IconButton *button in buttons) {
//      CGRect newFrame = CGRectMake(x, y, buttonFrame.size.width, buttonFrame.size.height);
//      [button setFrame:newFrame];
//      [[self view] addSubview:button];
//      x += incrementXBy;
//   }
//   [buttons release];
//}

- (void)viewDidLoad
{
   [super viewDidLoad];

   [self setContentSizeForViewInPopover:CGSizeMake(320, 100)];
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
   CGRect buttonFrame = [flickrButton frame];   // Need this for layout calculations.
   [flickrButton addTarget:self action:@selector(addFromFlickr:) forControlEvents:UIControlEventTouchUpInside];
   [buttons addObject:flickrButton];
   
   // Evenly distribute the buttons across the view.
   NSInteger width = 320;
   NSInteger height = 100;
   CGFloat space = ((width / [buttons count]) / 2) - (buttonFrame.size.width / 2);
   NSInteger x = space;
   NSInteger y = (height - buttonFrame.size.height) / 2;
   for (IconButton *button in buttons) {
      CGRect newFrame = CGRectMake(x, y, buttonFrame.size.width, buttonFrame.size.height);
      [button setFrame:newFrame];
      [[self view] addSubview:button];
      x = x + buttonFrame.size.width + (space * 2);
   }
   
   [self setButtons:buttons];
   [buttons release];
}

- (void)viewDidUnload
{
   [self setButtons:nil];
   [super viewDidUnload];
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
