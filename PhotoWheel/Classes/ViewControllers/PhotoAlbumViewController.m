//
//  PhotoAlbumViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/4/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import "Models.h"
#import "MainViewController.h"

#define ALERT_BUTTON_CANCEL 0
#define ALERT_BUTTON_REMOVEPHOTOALBUM 1

@implementation PhotoAlbumViewController

@synthesize emailButton = emailButton_;
@synthesize slideshowButton = slideshowButton_;
@synthesize printButton = printButton_;
@synthesize removeAlbumButton = removeAlbumButton_;
@synthesize titleTextField = titleTextField_;
@synthesize photoAlbum = photoAlbum_;
@synthesize mainViewController = mainViewController_;

- (void)dealloc
{
   [titleTextField_ release], titleTextField_ = nil;
   [emailButton_ release], emailButton_ = nil;
   [slideshowButton_ release], slideshowButton_ = nil;
   [printButton_ release], printButton_ = nil;
   [removeAlbumButton_ release], removeAlbumButton_ = nil;
   [photoAlbum_ release], photoAlbum_ = nil;
   
   [super dealloc];
}

- (void)viewDidUnload
{
   [self setTitleTextField:nil];
   [self setEmailButton:nil];
   [self setSlideshowButton:nil];
   [self setPrintButton:nil];
   [self setRemoveAlbumButton:nil];

   [super viewDidUnload];
}

- (void)updateDisplay
{
   [[self titleTextField] setText:[[self photoAlbum] name]];
}

- (void)setPhotoAlbum:(PhotoAlbum *)photoAlbum
{
   if (photoAlbum_ != photoAlbum) {
      [photoAlbum retain];
      [photoAlbum_ release];
      photoAlbum_ = photoAlbum;
      
      [self updateDisplay];
   }
}

#pragma mark - Actions

- (IBAction)removePhotoAlbum:(id)sender
{
   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo Album" message:@"Remove the selected photo album and its photos?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Remove", nil];
   [alertView show];
}

- (IBAction)printPhotoAlbum:(id)sender
{
   
}

- (IBAction)emailPhotoAlbum:(id)sender
{
   
}

- (IBAction)slideshow:(id)sender
{
   
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex == ALERT_BUTTON_REMOVEPHOTOALBUM) {
      if ([[self mainViewController] deletePhotoAlbum:[self photoAlbum]]) {
         [self setPhotoAlbum:nil];
      }
   }
   [alertView release];
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
   [alertView release];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   [[self photoAlbum] setName:[textField text]];
   [[self photoAlbum] save];
}

@end
