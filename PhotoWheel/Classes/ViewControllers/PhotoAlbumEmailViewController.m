//
//  PhotoAlbumEmailViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/27/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumEmailViewController.h"


@implementation PhotoAlbumEmailViewController

- (void)dealloc
{
   [super dealloc];
}

- (id)initWithDefaultNib
{
   self = [super initWithNibName:@"PhotoAlbumEmailView" bundle:nil];
   if (self) {
      [self setModalPresentationStyle:UIModalPresentationFormSheet];
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
   [[self navigationItem] setLeftBarButtonItem:cancelButton];
   [cancelButton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (IBAction)sendAsImages:(id)sender
{
   
}

- (IBAction)sendAsPhotoWheel:(id)sender
{
   
}

- (IBAction)cancel:(id)sender
{
   [self dismissModalViewControllerAnimated:YES];
}

@end
