//
//  PhotoAlbumEmailViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/27/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumEmailViewController.h"
#import "SendEmailController.h"
#import "PhotoAlbum.h"

@interface PhotoAlbumEmailViewController ()
@property (nonatomic, retain) SendEmailController *sendEmailController;
@end

@implementation PhotoAlbumEmailViewController

@synthesize photoAlbum = photoAlbum_;
@synthesize sendEmailController = sendEmailController_;

- (void)dealloc
{
   [photoAlbum_ release], photoAlbum_ = nil;
   [sendEmailController_ release], sendEmailController_ = nil;
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
   SendEmailController *newController = [[SendEmailController alloc] initWithViewController:self];
   [newController setPhotos:[[self photoAlbum] photos]];
   [self setSendEmailController:newController];
   [newController release];
   
   [[self sendEmailController] sendEmail];
   
}

- (IBAction)sendAsPhotoWheel:(id)sender
{
   
}

- (IBAction)cancel:(id)sender
{
   [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - SendEmailControllerDelegate

- (void)sendEmailControllerDidFinish:(SendEmailController *)controller
{
   if (controller == [self sendEmailController]) {
      [self setSendEmailController:nil];
   }
}

@end
