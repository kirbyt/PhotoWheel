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
#import "PhotoAlbumMenuViewController.h"
#import "PhotoAlbumEmailViewController.h"

#define BUTTON_CANCEL 0
#define BUTTON_REMOVE_PHOTO_ALBUM 1
#define BUTTON_SEND_AS_PHOTOS 1
#define BUTTON_SEND_AS_PHOTOWHEEL 2

@interface PhotoAlbumViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIPopoverController *popoverController;
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
@synthesize topShadowImageView = topShadowImageView_;
@synthesize toolbar = toolbar_;
@synthesize titleTextField = titleTextField_;
@synthesize addPhotoButton = addPhotoButton_;
@synthesize actionButton = actionButton_;
@synthesize photoAlbum = photoAlbum_;
@synthesize mainViewController = mainViewController_;
@synthesize gridView = gridView_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize popoverController = popoverController_;

- (void)dealloc
{
   [backgroundImageView_ release], backgroundImageView_ = nil;
   [topShadowImageView_ release], topShadowImageView_ = nil;
   [popoverController_ release], popoverController_ = nil;
   [fetchedResultsController_ release], fetchedResultsController_ = nil;
   [gridView_ release], gridView_ = nil;
   [toolbar_ release], toolbar_ = nil;
   [titleTextField_ release], titleTextField_ = nil;
   [addPhotoButton_ release], addPhotoButton_ = nil;
   [actionButton_ release], actionButton_ = nil;
   [photoAlbum_ release], photoAlbum_ = nil;
   
   [super dealloc];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [[self gridView] setAlwaysBounceVertical:YES];
   // Hide the toolbar until we have a photo album.
   [[self toolbar] setAlpha:0.0];
}

- (void)viewDidUnload
{
   [self setBackgroundImageView:nil];
   [self setTopShadowImageView:nil];
   [self setGridView:nil];
   [self setToolbar:nil];
   [self setTitleTextField:nil];
   [self setAddPhotoButton:nil];
   [self setActionButton:nil];

   [super viewDidUnload];
}

- (void)layoutForLandscape
{
   [[self backgroundImageView] setImage:[UIImage imageNamed:@"stack-viewer-bg-landscape-right.png"]];
   [[self gridView] setFrame:CGRectMake(9, 65, 678, 620)];
   [[self toolbar] setFrame:CGRectMake(9, 14, 678, 44)];
   [[self topShadowImageView] setFrame:CGRectMake(9, 65, 678, 8)];
}

- (void)layoutForPortrait
{
   [[self backgroundImageView] setImage:[UIImage imageNamed:@"stack-viewer-bg-portrait.png"]];
   [[self gridView] setFrame:CGRectMake(9, 65, 698, 583)];
   [[self toolbar] setFrame:CGRectMake(9, 14, 698, 44)];
   [[self topShadowImageView] setFrame:CGRectMake(9, 65, 698, 8)];
}

- (void)doRefreshDisplay
{
   BOOL hideToolbar = ([self photoAlbum] == nil);
   
   void (^animations)(void) = ^ {
      [[self gridView] setAlpha:0.0];
      [[self titleTextField] setText:[[self photoAlbum] name]];
      [self setFetchedResultsController:nil];
      if (hideToolbar) {
         [[self toolbar] setAlpha:0.0];
      }
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      [[self gridView] reloadData];
      void (^animations)(void) = ^ {
         [[self gridView] setAlpha:1.0];
         if (!hideToolbar) {
            [[self toolbar] setAlpha:1.0];
         }
      };
      [UIView animateWithDuration:0.25 animations:animations];
   };
   
   [UIView animateWithDuration:0.25 animations:animations completion:completion];
}

- (void)refreshDisplay
{
#define REFRESH_DELAY 0.75
   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doRefreshDisplay) object:nil];
   [self performSelector:@selector(doRefreshDisplay) withObject:nil afterDelay:REFRESH_DELAY];
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

- (IBAction)showActionMenu:(id)sender
{
   [[UIPrintInteractionController sharedPrintController] dismissAnimated:YES];

   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
      
   } else {
      PhotoAlbumMenuViewController *newController = [[PhotoAlbumMenuViewController alloc] init];
      [newController setPhotoAlbumViewController:self];
      UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:newController];
      [newPopover setDelegate:self];
      [self setPopoverController:newPopover];
      
      [newPopover release];
      [newController release];
      
      [[self popoverController] presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   }
}

- (IBAction)addPhoto:(id)sender
{
   [[UIPrintInteractionController sharedPrintController] dismissAnimated:YES];

   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];

   } else {
      AddPhotoViewController *addPhotoViewController = [[AddPhotoViewController alloc] init];
      [addPhotoViewController setPhotoAlbumViewController:self];
      UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:addPhotoViewController];
      [newPopover setDelegate:self];
      [self setPopoverController:newPopover];
      
      [newPopover release];
      [addPhotoViewController release];
      
      [[self popoverController] presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   }
}

- (void)addFromCamera:(id)sender
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

- (void)addFromLibrary:(id)sender
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   UIImagePickerController *newImagePicker = [[UIImagePickerController alloc] init];
   [newImagePicker setDelegate:self];
   [newImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:newImagePicker];
   [newPopover setDelegate:self];
   [self setPopoverController:newPopover];
   
   [newPopover release];
   [newImagePicker release];
   
   [[self popoverController] presentPopoverFromBarButtonItem:[self addPhotoButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)addFromFlickr:(id)sender
{
   NSLog(@"%s", __PRETTY_FUNCTION__);

   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
}

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

- (void)removePhotoAlbum:(id)sender
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }

   NSString *message;
   if ([[self photoAlbum] name] && [[[self photoAlbum] name] length] > 0) {
      message = [NSString stringWithFormat:@"Remove %@ and its photos?", [[self photoAlbum] name]];
   } else {
      message = [NSString stringWithFormat:@"Remove photo album?"];
   }
   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove Photo Album" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Remove", nil];
   [alertView show];
}

- (void)printPhotoAlbum:(id)sender
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }

   if ([self numberOfObjects] == 0) return;  // Nothing to print.
   
   NSMutableArray *imageURLs = [[NSMutableArray alloc] initWithCapacity:[self numberOfObjects]];
   for (Photo *photo in [[self fetchedResultsController] fetchedObjects]) {
      [imageURLs addObject:[photo largeImageURL]];
   }   
   
   UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
   if(!controller){
      NSLog(@"Couldn't get shared UIPrintInteractionController!");
      return;
   }
   
   UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
      if(completed && error)
         NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
   };
   
   UIPrintInfo *printInfo = [UIPrintInfo printInfo];
   [printInfo setOutputType:UIPrintInfoOutputPhoto];
   [printInfo setJobName:[[self photoAlbum] name]];
   
   [controller setPrintInfo:printInfo];
   [controller setPrintingItems:imageURLs];
   
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [controller presentFromBarButtonItem:[self actionButton] animated:YES completionHandler:completionHandler];
   } else {
      [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
   }
   
   [imageURLs release];
}

- (void)emailPhotoAlbum:(id)sender
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }

   PhotoAlbumEmailViewController *newController = [[PhotoAlbumEmailViewController alloc] initWithDefaultNib];
   [newController setPhotoAlbum:[self photoAlbum]];
   [[self mainViewController] presentModalViewController:newController animated:YES];
   [newController release];
}

- (void)slideshow:(id)sender
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   SlideshowSettingsViewController *newController = [[SlideshowSettingsViewController alloc] init];
   UINavigationController *newNavController = [[UINavigationController alloc] initWithRootViewController:newController];
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:newNavController];
   [newPopover setDelegate:self];
   [self setPopoverController:newPopover];
   
   [newPopover release];
   [newNavController release];
   [newController release];
   
   [[self popoverController] presentPopoverFromBarButtonItem:[self actionButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

- (NSInteger)gridViewNumberOfCells:(GridView *)gridView
{
   NSInteger count = [self numberOfObjects];
   return count;
}

- (GridViewCell *)gridView:(GridView *)gridView cellAtIndex:(NSInteger)index
{
   ImageGridViewCell *cell = [gridView dequeueReusableCell];
   if (cell == nil) {
      cell = [ImageGridViewCell imageGridViewCell];
   }
   
   Photo *photo = [self objectAtIndex:index];
   [cell setImage:[photo smallImage] withShadow:YES];
   
   return cell;
}

- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return [ImageGridViewCell size];
}

- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index
{
   GridViewCell *cell = [gridView cellAtIndex:index];
   CGRect cellFrame = [cell frame];
   CGPoint point = CGPointMake(CGRectGetMidX(cellFrame), CGRectGetMidY(cellFrame));
   point = [gridView convertPoint:point toView:[[self view] superview]];
   NSLog(@"frame: %@", NSStringFromCGRect(cellFrame));
   
   PhotoBrowserViewController *newController = [[PhotoBrowserViewController alloc] init];
   [newController setFetchedResultsController:[self fetchedResultsController]];
   [newController setStartAtIndex:index];
   CustomNavigationController *navController = (CustomNavigationController *)[[self mainViewController] navigationController];
   [navController pushViewController:newController explodeFromPoint:point];
   [newController release];
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

- (void)threaded_saveImage:(id)data
{
   if ([data isKindOfClass:[NSDictionary class]]) {
      NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

      NSDictionary *dict = data;
      NSPersistentStoreCoordinator *storeCoordinator = [dict objectForKey:@"storeCoordinator"];
      NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
      [context setPersistentStoreCoordinator:storeCoordinator];

      NSManagedObjectID *photoAlbumObjectID = [dict objectForKey:@"photoAlbumObjectID"];
      id photoAlbum = [context objectWithID:photoAlbumObjectID];
      
      UIImage *image = [dict objectForKey:@"image"];
      Photo *newPhoto = [Photo insertNewInManagedObjectContext:context];
      [newPhoto setPhotoAlbum:photoAlbum];
      [newPhoto saveImage:image];
      [newPhoto kt_save];
      
      [pool drain];
   }
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
   
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   NSManagedObjectContext *context = [[self photoAlbum] managedObjectContext];
   NSPersistentStoreCoordinator *storeCoordinator = [context persistentStoreCoordinator];
   NSManagedObjectID *photoAlbumObjectID = [[self photoAlbum] objectID];
   NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:storeCoordinator, @"storeCoordinator", image, @"image", photoAlbumObjectID, @"photoAlbumObjectID", nil];
   [self performSelectorInBackground:@selector(threaded_saveImage:) withObject:data];
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

- (NSURL *)photoBrowserViewController:(PhotoBrowserViewController *)controller printPhotoURLAtIndex:(NSInteger)index
{
   Photo *photo = [self objectAtIndex:index];
   return [photo largeImageURL];
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
