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
#import "SlideshowSettingsViewController.h"
#import "NSManagedObject+KTCategory.h"
#import "UINavigationController+KTTransitions.h"
#import "CustomNavigationController.h"
#import "PhotoBrowserViewController.h"

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
- (void)layoutForLandscape;
- (void)layoutForPortrait;
@end

@implementation PhotoAlbumViewController

@synthesize backgroundImageView = backgroundImageView_;
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
@synthesize toolbarView = toolbarView_;

- (void)dealloc
{
   [toolbarView_ release], toolbarView_ = nil;
   [backgroundImageView_ release], backgroundImageView_ = nil;
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

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [[self gridView] setAlwaysBounceVertical:YES];
}

- (void)viewDidUnload
{
   [[self refreshDisplayTimer] invalidate];
   [self setRefreshDisplayTimer:nil];

   [self setToolbarView:nil];
   [self setBackgroundImageView:nil];
   [self setGridView:nil];
   [self setTitleTextField:nil];
   [self setEmailButton:nil];
   [self setSlideshowButton:nil];
   [self setPrintButton:nil];
   [self setRemoveAlbumButton:nil];

   [super viewDidUnload];
}

- (void)layoutForLandscape
{
   [[self backgroundImageView] setImage:[UIImage imageNamed:@"stack-viewer-bg-landscape-right.png"]];
   
   CGRect frame;
   CGFloat commonWidth = 651;
   
   [[self gridView] setFrame:CGRectMake(20, 74, commonWidth, 481)];

   frame = [[self titleTextField] frame];
   frame = CGRectMake(20, frame.origin.y, commonWidth, frame.size.height);
   [[self titleTextField] setFrame:frame];
   
   frame = [[self toolbarView] frame];
   frame.origin.y = 569;
   frame.size.width = commonWidth;
   [[self toolbarView] setFrame:frame];
}

- (void)layoutForPortrait
{
   [[self backgroundImageView] setImage:[UIImage imageNamed:@"stack-viewer-bg-portrait.png"]];

   CGRect frame;
   CGFloat commonWidth = 676;

   [[self gridView] setFrame:CGRectMake(20, 78, commonWidth, 438)];
   
   frame = [[self titleTextField] frame];
   frame = CGRectMake(20, frame.origin.y, commonWidth, frame.size.height);
   [[self titleTextField] setFrame:frame];

   frame = [[self toolbarView] frame];
   frame.origin.y = 535;
   frame.size.width = commonWidth;
   [[self toolbarView] setFrame:frame];
}

- (void)doRefreshDisplay
{
   [[self refreshDisplayTimer] invalidate];
   [self setRefreshDisplayTimer:nil];
   
   void (^animations)(void) = ^ {
      [[self gridView] setAlpha:0.0];
      [[self titleTextField] setText:[[self photoAlbum] name]];
      [[self toolbarView] setAlpha:0.0];
      [self setFetchedResultsController:nil];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      [[self gridView] reloadData];
      void (^animations)(void) = ^ {
         [[self gridView] setAlpha:1.0];
         [[self toolbarView] setAlpha:1.0];
      };
      [UIView animateWithDuration:0.25 animations:animations];
   };
   
   [UIView animateWithDuration:0.25 animations:animations completion:completion];
}

- (void)refreshDisplay
{
#define REFRESH_DELAY 0.3
   if ([self refreshDisplayTimer]) {
      [[self refreshDisplayTimer] setFireDate:[NSDate dateWithTimeIntervalSinceNow:REFRESH_DELAY]];
   } else {
      NSTimer *newTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_DELAY target:self selector:@selector(doRefreshDisplay) userInfo:nil repeats:NO];
      [self setRefreshDisplayTimer:newTimer];
   }
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

- (void)deletePhotoAlbum
{
   NSManagedObjectContext *context = [[self photoAlbum] managedObjectContext];
   [context deleteObject:[self photoAlbum]];

   // Save the context.
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
   [actionSheet showFromRect:[sender frame] inView:[self toolbarView] animated:YES];
}

- (IBAction)slideshow:(id)sender
{
   SlideshowSettingsViewController *newController = [[SlideshowSettingsViewController alloc] init];
   UINavigationController *newNavController = [[UINavigationController alloc] initWithRootViewController:newController];
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:newNavController];
   [self setPopoverController:newPopover];
   
   [newPopover release];
   [newNavController release];
   [newController release];
   
   [[self popoverController] presentPopoverFromRect:[sender frame] inView:[self toolbarView] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   [alertView release];
   if (buttonIndex == BUTTON_REMOVE_PHOTO_ALBUM) {
      [self deletePhotoAlbum];
   }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return NO;
}

#pragma mark - GridViewDataSource Methods

- (NSInteger)gridViewCellsPerRow:(GridView *)gridView
{
   return 4;
}

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
      [cell setImage:[photo smallImage] withShadow:YES];
   } else {
      [cell setImage:[UIImage imageNamed:@"photo-add.png"] withShadow:NO];
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
      GridViewCell *cell = [gridView cellAtIndex:index];
      CGRect cellFrame = [cell frame];
      CGPoint point = CGPointMake(CGRectGetMidX(cellFrame), CGRectGetMidY(cellFrame));
      point = [gridView convertPoint:point toView:[[self view] superview]];
      NSLog(@"frame: %@", NSStringFromCGRect(cellFrame));
      
      PhotoBrowserViewController *newController = [[PhotoBrowserViewController alloc] init];
      [newController setDataSource:self];
      [newController setStartAtIndex:index];
      CustomNavigationController *navController = (CustomNavigationController *)[[self mainViewController] navigationController];
      [navController pushViewController:newController explodeFromPoint:point];
      [newController release];
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
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }

   UIImagePickerController *newImagePicker = [[UIImagePickerController alloc] init];
   [newImagePicker setDelegate:self];
   // Note the following line of code will fail in the simulator 
   // because the simulator does not have a camera.
   [newImagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
   
   // We present from the main view controller because we want to 
   // use the full screen.
   [[self mainViewController] presentModalViewController:newImagePicker animated:YES];
   
   [newImagePicker release];
}

- (void)addFromLibrary
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   UIImagePickerController *newImagePicker = [[UIImagePickerController alloc] init];
   [newImagePicker setDelegate:self];
   [newImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:newImagePicker];
   [self setPopoverController:newPopover];
   
   [newPopover release];
   [newImagePicker release];
   
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
   [picker dismissModalViewControllerAnimated:YES];
   
   [[self popoverController] dismissPopoverAnimated:YES];
   [self setPopoverController:nil];
   
   NSManagedObjectContext *context = [[self photoAlbum] managedObjectContext];
   
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   Photo *newPhoto = [Photo insertNewInManagedObjectContext:context];
   [newPhoto setPhotoAlbum:[self photoAlbum]];
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

#pragma mark - PhotoBrowserViewControllerDataSource Methods

- (NSInteger)photoBrowserViewControllerNumberOfPhotos:(PhotoBrowserViewController *)controller
{
   return [self numberOfObjects];
}

- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)controller photoAtIndex:(NSInteger)index
{
   Photo *photo = [self objectAtIndex:index];
   return [photo largeImage];
}

- (BOOL)photoBrowserViewController:(PhotoBrowserViewController *)controller deletePhotoAtIndex:(NSInteger)index
{
   BOOL success = YES;
   Photo *photo = [self objectAtIndex:index];
   NSManagedObjectContext *context = [photo managedObjectContext];
   [context deleteObject:photo];
   
   // Save the context.
   NSError *error = nil;
   if (![context save:&error])
   {
      success = NO;
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }

   [[self gridView] reloadData];
   return success;
}

                                
@end
