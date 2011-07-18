//
//  PhotoAlbumViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import "MainViewController.h"
#import "PhotoAlbum.h"

@interface PhotoAlbumViewController ()
@property (nonatomic, strong) PhotoAlbum *photoAlbum;
@end

@implementation PhotoAlbumViewController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize objectID = objectID_;
@synthesize textField = textField_;
@synthesize photoAlbum = photoAlbum_;

- (void)didMoveToParentViewController:(UIViewController *)parent
{
   // Position the view within the new parent.
   [[parent view] addSubview:[self view]];
   CGRect newFrame = CGRectMake(26, 18, 716, 717);
   [[self view] setFrame:newFrame];
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   [self setTextField:nil];
}

- (void)refresh
{
   self.photoAlbum = (PhotoAlbum *)[self.managedObjectContext objectWithID:[self objectID]];
   [self.textField setText:[self.photoAlbum name]];
}

#pragma mark - Actions

- (IBAction)action:(id)sender
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)addPhoto:(id)sender
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)displayPhotoBrowser:(id)sender 
{
   id parent = [self parentViewController];
   if (parent && [parent respondsToSelector:@selector(displayPhotoBrowser)]) {
      [parent displayPhotoBrowser];
   }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
   [textField setBorderStyle:UITextBorderStyleRoundedRect];
   [textField setTextColor:[UIColor blackColor]];
   [textField setBackgroundColor:[UIColor whiteColor]];
   return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   [textField setBackgroundColor:[UIColor clearColor]];
   [textField setTextColor:[UIColor whiteColor]];
   [textField setBorderStyle:UITextBorderStyleNone];

   [[self photoAlbum] setName:[textField text]];
   
   // Save the context.
   NSManagedObjectContext *context = [self managedObjectContext];
   NSError *error = nil;
   if (![context save:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return NO;
}

@end
