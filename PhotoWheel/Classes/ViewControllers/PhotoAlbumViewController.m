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

@interface PhotoAlbumViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end

@implementation PhotoAlbumViewController

@synthesize emailButton = emailButton_;
@synthesize slideshowButton = slideshowButton_;
@synthesize printButton = printButton_;
@synthesize removeAlbumButton = removeAlbumButton_;
@synthesize titleTextField = titleTextField_;
@synthesize photoAlbum = photoAlbum_;
@synthesize mainViewController = mainViewController_;
@synthesize gridView = gridView_;
@synthesize fetchedResultsController = fetchedResultsController_;


- (void)dealloc
{
   [fetchedResultsController_ release], fetchedResultsController_ = nil;
   [gridView_ release], gridView_ = nil;
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
   [self setGridView:nil];
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
   [self setFetchedResultsController:nil];
   [[self gridView] reloadData];
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

#pragma mark - GridViewDataSource Methods

- (NSInteger)gridViewNumberOfViews:(GridView *)gridView
{
   NSInteger count = [[[[self fetchedResultsController] sections] objectAtIndex:0] numberOfObjects] + 1;
   return count;
}

- (GridViewCell *)gridView:(GridView *)gridView viewAtIndex:(NSInteger)index
{
   return nil;
}

- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return CGSizeMake(100, 100);
}

#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)fetchedResultsController
{
   if ([self photoAlbum] == nil) {
      return nil;
   }
   
   if (fetchedResultsController_) {
      return fetchedResultsController_;
   }
   
   NSManagedObjectContext *context = [[self photoAlbum] managedObjectContext];
   
   NSString *cacheName = NSStringFromClass([self class]);
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[Photo entityName] inManagedObjectContext:context];
   [fetchRequest setEntity:entityDescription];
   
   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
   
   [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"photoAlbum = %@", [self photoAlbum]]];
   
   NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:cacheName];
   [newFetchedResultsController setDelegate:self];
   [self setFetchedResultsController:newFetchedResultsController];
   [newFetchedResultsController release];
   [fetchRequest release];
   
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
	}
   
   return fetchedResultsController_;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self gridView] reloadData];
}

@end
