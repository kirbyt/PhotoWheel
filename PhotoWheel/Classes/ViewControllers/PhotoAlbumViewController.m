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
#import "ImageGridViewCell.h"
#import "AddPhotoViewController.h"
#import "NSManagedObject+KTCategory.h"

#define BUTTON_CANCEL 0
#define BUTTON_REMOVE_PHOTO_ALBUM 1
#define BUTTON_SEND_AS_PHOTOS 1
#define BUTTON_SEND_AS_PHOTOWHEEL 2

@interface PhotoAlbumViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSTimer *refreshDisplayTimer;
- (NSInteger)numberOfObjects;
- (id)objectAtIndex:(NSInteger)index;
- (void)addPhotoAtIndex:(NSInteger)index;
- (void)emailAsPhotos;
- (void)emailAsPhotoWheel;
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
@synthesize popoverController = popoverController_;
@synthesize refreshDisplayTimer = refreshDisplayTimer_;

- (void)dealloc
{
   [refreshDisplayTimer_ release], refreshDisplayTimer_ = nil;
   [popoverController_ release], popoverController_ = nil;
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
   [[self refreshDisplayTimer] invalidate];
   [self setRefreshDisplayTimer:nil];
   
   [self setGridView:nil];
   [self setTitleTextField:nil];
   [self setEmailButton:nil];
   [self setSlideshowButton:nil];
   [self setPrintButton:nil];
   [self setRemoveAlbumButton:nil];

   [super viewDidUnload];
}

- (void)doRefreshDisplay
{
   void (^animations)(void) = ^ {
      [[self gridView] setAlpha:0.0];
      [[self titleTextField] setText:[[self photoAlbum] name]];
      [self setFetchedResultsController:nil];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      [[self gridView] reloadData];
      void (^animations)(void) = ^ {
         [[self gridView] setAlpha:1.0];
      };
      [UIView animateWithDuration:0.6 animations:animations];
   };
   
   [UIView animateWithDuration:0.6 animations:animations completion:completion];
}

- (void)refreshDisplay
{
   if ([self refreshDisplayTimer]) {
      [[self refreshDisplayTimer] invalidate];
   }
   
   NSTimer *newTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(doRefreshDisplay) userInfo:nil repeats:NO];
   [self setRefreshDisplayTimer:newTimer];
}

- (void)setPhotoAlbum:(PhotoAlbum *)photoAlbum
{
   if (photoAlbum_ != photoAlbum) {
      [photoAlbum retain];
      [photoAlbum_ release];
      photoAlbum_ = photoAlbum;
      
      [self refreshDisplay];
   }
}

#pragma mark - Actions

- (IBAction)removePhotoAlbum:(id)sender
{
   NSString *message = [NSString stringWithFormat:@"Remove %@ and its photos?", [[self photoAlbum] name]];
   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove Photo Album" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Remove", nil];
   [alertView show];
}

- (IBAction)printPhotoAlbum:(id)sender
{
   
}

- (IBAction)emailPhotoAlbum:(id)sender
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send as Photos", @"Send as a Photo Wheel", nil];
   [actionSheet showFromRect:[sender frame] inView:[self view] animated:YES];
}

- (IBAction)slideshow:(id)sender
{
   
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex == BUTTON_REMOVE_PHOTO_ALBUM) {
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

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   [actionSheet release];
   switch (buttonIndex) {
      case BUTTON_SEND_AS_PHOTOS:
         [self emailAsPhotos];
         break;
      case BUTTON_SEND_AS_PHOTOWHEEL:
         [self emailAsPhotoWheel];
         break;
      default:
         break;
   }
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   [[self photoAlbum] setName:[textField text]];
   [[self photoAlbum] kt_save];
}

#pragma mark - GridViewDataSource Methods

- (NSInteger)gridViewNumberOfCells:(GridView *)gridView
{
   NSInteger count = 0;
   // Set the count only when we have a photo album.
   if ([self photoAlbum]) {
      count = [self numberOfObjects] + 1;   // Add 1 for the "add cell"
   }
   return count;
}

- (GridViewCell *)gridView:(GridView *)gridView cellAtIndex:(NSInteger)index
{
   ImageGridViewCell *cell = [gridView dequeueReusableCell];
   if (cell == nil) {
      cell = [ImageGridViewCell imageGridViewCell];
   }
   
   if (index < [self numberOfObjects]) {
      Photo *photo = [self objectAtIndex:index];
      [cell setImage:[photo smallImage]];
   } else {
      [cell setImage:[UIImage imageNamed:@"addphoto.png"]];
   }
   
   return cell;
}

- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return [ImageGridViewCell size];
}

- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index
{
   if (index < [self numberOfObjects]) {
      
   } else {
      [self addPhotoAtIndex:index];
   }
}

#pragma mark - NSFetchedResultsController Helper Methods

- (NSInteger)numberOfObjects
{
   NSInteger count = [[[[self fetchedResultsController] sections] objectAtIndex:0] numberOfObjects];
   return count;
}

- (id)objectAtIndex:(NSInteger)index
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   id object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   return object;
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
   
   NSString *cacheName = [[self photoAlbum] uuid];
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

#pragma mark - Photo Management

- (void)addPhotoAtIndex:(NSInteger)index
{
   AddPhotoViewController *addPhotoViewController = [[AddPhotoViewController alloc] init];
   [addPhotoViewController setPhotoAlbumViewController:self];
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:addPhotoViewController];
   [self setPopoverController:newPopover];
   
   [newPopover release];
   [addPhotoViewController release];
   
   GridViewCell *cell = [[self gridView] cellAtIndex:index];
   [[self popoverController] presentPopoverFromRect:[cell frame] inView:[self gridView] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)addFromCamera
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)addFromLibrary
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   UIViewController *newRootController = [[UIViewController alloc] init];
   [newRootController setContentSizeForViewInPopover:CGSizeMake(320, 480)];
   UIImagePickerController *newImagePicker = [[UIImagePickerController alloc] initWithRootViewController:newRootController];
   [newImagePicker setDelegate:self];
   
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:newImagePicker];
   [self setPopoverController:newPopover];
   
   [newPopover release];
   [newImagePicker release];
   [newRootController release];
   
   NSInteger selectedIndex = [[self gridView] indexForSelectedCell];
   GridViewCell *cell = [[self gridView] cellAtIndex:selectedIndex];
   [[self popoverController] presentPopoverFromRect:[cell frame] inView:[self gridView] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)addFromFlickr
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - UIPopoverControllerDelegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
   if ([self popoverController] == popoverController) {
      [self setPopoverController:nil];
   }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   [[self popoverController] dismissPopoverAnimated:YES];
   [self setPopoverController:nil];
   
   NSManagedObjectContext *context = [[self photoAlbum] managedObjectContext];
   
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   Photo *newPhoto = [Photo insertNewInManagedObjectContext:context];
   [newPhoto setPhotoAlbum:[self photoAlbum]];
   [newPhoto setDateAdded:[NSDate date]];
   [newPhoto saveImage:image];
   [newPhoto kt_save];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
   [[self popoverController] dismissPopoverAnimated:YES];
   [self setPopoverController:nil];
}

#pragma mark - Email Management

- (void)emailAsPhotos
{
   
}

- (void)emailAsPhotoWheel
{
   
}

@end
