//
//  PhotoAlbumViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoAlbum.h"
#import "Photo.h"
#import "ImageGridViewCell.h"
#import "FlickrViewController.h"
#import "ImageGridViewCell.h"
#import "AppDelegate.h"

@interface PhotosViewController ()
@property (nonatomic, strong) PhotoAlbum *photoAlbum;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *imagePickerPopoverController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) SendEmailController *sendEmailController;

- (void)presentPhotoPickerMenu;
- (void)emailPhotos;
@end

@implementation PhotosViewController

- (void)dealloc 
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kRefetchAllDataNotification object:nil];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
   [self setManagedObjectContext:managedObjectContext];

   [self reload];
   
   [[NSNotificationCenter defaultCenter] addObserverForName:kRefetchAllDataNotification object:[[UIApplication sharedApplication] delegate] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *__strong note) {
      [self reload];
   }];
}

- (void)viewDidUnload
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kRefetchAllDataNotification object:nil];
   
   [self setToolbar:nil];
   [self setTextField:nil];
   [self setAddButton:nil];
   [self setGridView:nil];
   [super viewDidUnload];
}
- (UIImagePickerController *)imagePickerController
{
   if (_imagePickerController) {
      return _imagePickerController;
   }
   
   self.imagePickerController = [[UIImagePickerController alloc] init];
   [self.imagePickerController setDelegate:self];
   
   return _imagePickerController;
}

#pragma mark Photo album management

- (void)reload
{
   if ([self managedObjectContext] && [self objectID]) {
      NSManagedObjectContext *context = [self managedObjectContext];
      PhotoAlbum *album = (PhotoAlbum *)[context objectWithID:[self objectID]];
      [self setPhotoAlbum:album];
      [[self toolbar] setHidden:NO];
      [[self textField] setText:[self.photoAlbum name]];
   } else {
      [self setPhotoAlbum:nil];
      [[self toolbar] setHidden:YES];
      [[self textField] setText:@""];
   }
   
   [self setFetchedResultsController:nil];
   [[self gridView] reloadData];
}

- (void)saveChanges
{
   // Save the context.
   NSManagedObjectContext *context = [self managedObjectContext];
   NSError *error = nil;
   ZAssert([context save:&error], @"Core Data save error: %@\n%@", [error localizedDescription], [error userInfo]);
}

#pragma mark - UITextFieldDelegate methods

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
   [self saveChanges];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return NO;
}

#pragma mark Actions

- (IBAction)showActionMenu:(id)sender 
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   
   if ([SendEmailController canSendMail]) {
      [actionSheet addButtonWithTitle:@"Email Photo Album"];
   }
   
   [actionSheet addButtonWithTitle:@"Delete Photo Album"];
   [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)addPhoto:(id)sender 
{
   if ([self imagePickerPopoverController]) {
      [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
   }
   
   [self presentPhotoPickerMenu];   
}

#pragma mark - Confirm and delete photo album

- (void)confirmDeletePhotoAlbum
{
   NSString *message;
   NSString *name = [[self photoAlbum] name];
   if ([name length] > 0) {
      message = [NSString stringWithFormat:@"Delete the photo album \"%@\". This action cannot be undone.", name];
   } else {
      message = @"Delete this photo album? This action cannot be undone.";
   }
   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Photo Album" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
   [alertView show];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex == 1) {
      [self.managedObjectContext deleteObject:[self photoAlbum]];
      [self setPhotoAlbum:nil];
      [self setObjectID:nil];
      [self saveChanges];
      [self reload];
   }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   // Do nothing if the user taps outside the action 
   // sheet (thus closing the popover containing the
   // action sheet).
   if (buttonIndex < 0) {
      return;
   }
   
   NSMutableArray *names = [[NSMutableArray alloc] init];
   
   if ([actionSheet tag] == 0) {
      if ([SendEmailController canSendMail]) [names addObject:@"emailPhotos"];
      [names addObject:@"confirmDeletePhotoAlbum"];
      
   } else {
      BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
      if (hasCamera) [names addObject:@"presentCamera"];
      [names addObject:@"presentPhotoLibrary"];
      [names addObject:@"presentFlickr"];
   }
   
   SEL selector = NSSelectorFromString([names objectAtIndex:buttonIndex]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
   [self performSelector:selector];
#pragma clang diagnostic pop
}

#pragma mark - Image picker helper methods

- (void)presentCamera
{
   // Display the camera.
   UIImagePickerController *imagePicker = [self imagePickerController];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
   [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)presentPhotoLibrary
{
   // Display assets from the photo library only.
   UIImagePickerController *imagePicker = [self imagePickerController];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   
   UIPopoverController *newPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
   [newPopoverController presentPopoverFromBarButtonItem:[self addButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   [self setImagePickerPopoverController:newPopoverController];
}

- (void)presentFlickr
{
   [self performSegueWithIdentifier:@"PushFlickrScene" sender:self];
}

- (void)presentPhotoPickerMenu
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   if (hasCamera) {
      [actionSheet addButtonWithTitle:@"Take Photo"];
   }
   [actionSheet addButtonWithTitle:@"Choose from Library"];
   [actionSheet addButtonWithTitle:@"Choose from Flickr"];
   [actionSheet setTag:1];
   [actionSheet showFromBarButtonItem:[self addButton] animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   // If the popover controller is available, 
   // assume the photo is selected from the library
   // and not from the camera.
   BOOL takenWithCamera = ([self imagePickerPopoverController] == nil);
   
   if (takenWithCamera) {
      [self dismissViewControllerAnimated:YES completion:nil];
   } else {
      [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
      [self setImagePickerPopoverController:nil];
   }
   
   // Retrieve and display the image.
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   
   NSManagedObjectContext *context = [self managedObjectContext];
   Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
   [newPhoto setDateAdded:[NSDate date]];
   [newPhoto saveImage:image];
   [newPhoto setPhotoAlbum:[self photoAlbum]];
   
   [self saveChanges];
   
   // Workaround for the _deleteExternalReferenceFromPermanentLocation error
   // caused by using external storage for the images.
   // http://stackoverflow.com/questions/7930427/error-uiimage-deleteexternalreferencefrompermanentlocation-unrecognized-se
   [context refreshObject:newPhoto mergeChanges:NO];
}

#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController) {
      return _fetchedResultsController;
   }
   
   NSManagedObjectContext *context = [self managedObjectContext];
   if (!context) {
      return nil;
   }
   
   NSString *cacheName = [NSString stringWithFormat:@"%@-%@", [self.photoAlbum name], [self.photoAlbum dateAdded]];
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
   [fetchRequest setEntity:entityDescription];
   
   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
   
   [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"photoAlbum = %@", [self photoAlbum]]];
   
   NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:cacheName];
   [newFetchedResultsController setDelegate:self];
   [self setFetchedResultsController:newFetchedResultsController];
   
   NSError *error = nil;
   ZAssert([[self fetchedResultsController] performFetch:&error], @"Fetch error: %@\n%@", [error localizedDescription], [error userInfo]);
   
   return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self gridView] reloadData];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   NSInteger count = [[[[self fetchedResultsController] sections] objectAtIndex:0] numberOfObjects];
   return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   ImageGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageGridViewCell" forIndexPath:indexPath];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   [[cell imageView] setImage:[photo smallImage]];
   
   return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   [self performSegueWithIdentifier:@"PushPhotoBrowser" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue destinationViewController] isKindOfClass:[PhotoBrowserViewController class]]) {
      PhotoBrowserViewController *destinationViewController = [segue destinationViewController];
      [destinationViewController setDelegate:self];

      NSInteger index = 0;
      NSArray *selectedIndexPath = [[self gridView] indexPathsForSelectedItems];
      if ([selectedIndexPath count] > 0) {
         // Multi-select is disabled, so there will only be one selected item.
         NSIndexPath *indexPath = [selectedIndexPath objectAtIndex:0];
         index = [indexPath item];
      }
      [destinationViewController setStartAtIndex:index];
      
   } else if ([[segue destinationViewController] isKindOfClass:[FlickrViewController class]]) {
      [[segue destinationViewController] setManagedObjectContext:[self managedObjectContext]];
      [[segue destinationViewController] setObjectID:[self objectID]];
   }
}

#pragma mark - PhotoBrowserViewControllerDelegate methods

- (NSInteger)photoBrowserViewControllerNumberOfPhotos:(PhotoBrowserViewController *)photoBrowser
{
   NSInteger count = [[[[self fetchedResultsController] sections] objectAtIndex:0] numberOfObjects];
   return count;
}

- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser imageAtIndex:(NSInteger)index
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   return [photo largeImage];
}

- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser smallImageAtIndex:(NSInteger)index
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   UIImage *image = [photo smallImage];
   return image;
}

- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser updateToNewImage:(UIImage *)image atIndex:(NSInteger)index;
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   [photo saveImage:image];
   [[self gridView] reloadData];
}

- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser deleteImageAtIndex:(NSInteger)index
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   NSManagedObjectContext *context = [self managedObjectContext];
   [context deleteObject:photo];
   [self saveChanges];   
}

#pragma mark -

- (NSIndexPath *)indexPathForSelectedGridCell
{
   NSIndexPath *indexPath = nil;
   NSArray *indexPaths = [[self gridView] indexPathsForSelectedItems];
   if ([indexPaths count] > 0) {
      // Multi-select is turned off, so there will only be one selected item.
      indexPath = [indexPaths lastObject];
   }
   
   return indexPath;
}

- (UIImage *)selectedImage
{
   UIImage *selectedImage = nil;
   NSIndexPath *indexPath = [self indexPathForSelectedGridCell];
   if (indexPath) {
      Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
      selectedImage = [photo largeImage];
   }
   return selectedImage;
}

- (CGRect)selectedCellFrame
{
   CGRect rect = CGRectZero;
   NSIndexPath *indexPath = [self indexPathForSelectedGridCell];
   if (indexPath) {
      UICollectionViewCell *cell = [[self gridView] cellForItemAtIndexPath:indexPath];
      UIView *parentView = [[self parentViewController] view];
      rect = [parentView convertRect:[cell frame] fromView:[self gridView]];
   } else {
      CGRect gridFrame = [[self gridView] frame];
      rect = CGRectMake(CGRectGetMidX(gridFrame), CGRectGetMidY(gridFrame), 0, 0);
   }
   
   return rect;
}

#pragma mark - Rotation support

- (void)layoutForLandscape
{
   [[self view] setFrame:CGRectMake(0, 0, 738, 719)];
   [[self backgroundImageView] setImage:[UIImage imageNamed:@"stack-viewer-bg-landscape-right.png"]];
   [[self backgroundImageView] setFrame:[[self view] bounds]];
   [[self shadowImageView] setFrame:CGRectMake(9, 51, 678, 8)];
   [[self gridView] setFrame:CGRectMake(20, 52, 654, 632)];
   [[self toolbar] setFrame:CGRectMake(9, 6, 678, 44)];
}

- (void)layoutForPortrait
{
   [[self view] setFrame:CGRectMake(0, 0, 716, 717)];
   [[self backgroundImageView] setImage:[UIImage imageNamed:@"stack-viewer-bg-portrait.png"]];
   [[self backgroundImageView] setFrame:[[self view] bounds]];
   [[self shadowImageView] setFrame:CGRectMake(9, 51, 698, 8)];
   [[self gridView] setFrame:CGRectMake(20, 51, 678, 597)];
   [[self toolbar] setFrame:CGRectMake(9, 6, 698, 44)];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      [self layoutForLandscape];
   } else {
      [self layoutForPortrait];
   }
}

#pragma mark - Email and SendEmailControllerDelegate methods

- (void)emailPhotos
{
   NSManagedObjectContext *context = [self managedObjectContext];
   PhotoAlbum *album = (PhotoAlbum *)[context objectWithID:[self objectID]];
   NSSet *photos = [[album photos] set];
   
   SendEmailController *controller = [[SendEmailController alloc] initWithViewController:self];
   [controller setPhotos:photos];
   [controller sendEmail];
   
   [self setSendEmailController:controller];
}

- (void)sendEmailControllerDidFinish:(SendEmailController *)controller
{
   if ([controller isEqual:[self sendEmailController]]) {
      [self setSendEmailController:nil];
   }
}

@end
