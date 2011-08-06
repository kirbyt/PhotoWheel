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
#import "Photo.h"
#import "ImageGridViewCell.h"
#import "FlickrViewController.h"

@interface PhotoAlbumViewController ()
@property (nonatomic, strong) PhotoAlbum *photoAlbum;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) SendEmailController *sendEmailController;
@end

@implementation PhotoAlbumViewController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize objectID = objectID_;
@synthesize textField = textField_;
@synthesize addButton = addButton_;
@synthesize gridView = gridView_;
@synthesize backgroundImageView = backgroundImageView_;
@synthesize topShadowImageView = topShadowImageView_;
@synthesize toolbar = toolbar_;
@synthesize photoAlbum = photoAlbum_;
@synthesize imagePickerController = imagePickerController_;
@synthesize popoverController = popoverController_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize sendEmailController = sendEmailController_;

- (void)didMoveToParentViewController:(UIViewController *)parent
{
   // Position the view within the new parent.
   [[parent view] addSubview:[self view]];
   CGRect newFrame = CGRectMake(26, 18, 716, 717);
   [[self view] setFrame:newFrame];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   [[self gridView] setAlwaysBounceVertical:YES];
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   [self setTextField:nil];
   [self setAddButton:nil];
   [self setGridView:nil];
}

- (UIImagePickerController *)imagePickerController
{
   if (imagePickerController_) {
      return imagePickerController_;
   }
   
   self.imagePickerController = [[UIImagePickerController alloc] init];
   [self.imagePickerController setDelegate:self];
   
   return imagePickerController_;
}

#pragma mark - Photo Album Management

- (void)refresh
{
   self.photoAlbum = (PhotoAlbum *)[self.managedObjectContext objectWithID:[self objectID]];
   [self.textField setText:[self.photoAlbum name]];
   [self setFetchedResultsController:nil];
   [self.gridView reloadData];
}

- (void)saveChanges
{
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

- (void)confirmDeletePhotoAlbum
{
   NSString *message;
   if ([[self.photoAlbum name] length] > 0) {
      message = [NSString stringWithFormat:@"Delete the photo album \"%@\". This action cannot be undone.", [self.photoAlbum name]];
   } else {
      message = @"Delete this photo album. This action cannot be undone.";
   }
   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Photo Album" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
   [alertView show];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex == 1) {
      [self.managedObjectContext deleteObject:[self photoAlbum]];
      [self saveChanges];
   }
}

#pragma mark - Image Picker Helper Methods

- (void)presentCamera
{
   // Display the camera.
   UIImagePickerController *imagePicker = [self imagePickerController];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
   [self presentModalViewController:imagePicker animated:YES];
}

- (void)presentPhotoLibrary
{
   // Display assets from the photo library only.
   UIImagePickerController *imagePicker = [self imagePickerController];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   
   UIPopoverController *newPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
   [newPopoverController presentPopoverFromBarButtonItem:[self addButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   [self setPopoverController:newPopoverController];
}

- (void)presentFlickr
{
   [self performSegueWithIdentifier:@"FlickrSegue" sender:self];
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

#pragma mark - Actions

- (IBAction)action:(id)sender
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
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
   }

   [self presentPhotoPickerMenu];   
}

#pragma mark - Email

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

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
   [self performSelector:selector];
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
   [self saveChanges];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return NO;
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   // If the popover controller is available then
   // assume the photo is selected from the library
   // and not from the camera.
   BOOL takenWithCamera = ([self popoverController] == nil);
   
   if (takenWithCamera) {
      [self dismissModalViewControllerAnimated:YES];
   } else {
      [self.popoverController dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   // Retrieve and display the image.
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

   NSManagedObjectContext *context = [self managedObjectContext];
   Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
   [newPhoto setDateAdded:[NSDate date]];
   [newPhoto saveImage:image];
   [newPhoto setPhotoAlbum:[self photoAlbum]];
   
   [self saveChanges];
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
   if (fetchedResultsController_) {
      return fetchedResultsController_;
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
   [cell setImage:[photo smallImage] withShadow:NO];
   
   return cell;
}

- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return [ImageGridViewCell size];
}

- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index
{
   [self performSegueWithIdentifier:@"PhotoBrowserSegue" sender:gridView];
}

#pragma mark - PhotoBrowserViewController

- (NSInteger)photoBrowserViewControllerNumberOfPhotos:(PhotoBrowserViewController *)photoBrowser
{
   NSInteger count = [self numberOfObjects];
   return count;
}

- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser imageAtIndex:(NSInteger)index
{
   Photo *photo = [self objectAtIndex:index];
   UIImage *image = [photo largeImage];
   return image;
}

- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser deleteImageAtIndex:(NSInteger)index
{
   Photo *photo = [self objectAtIndex:index];
   NSManagedObjectContext *context = [self managedObjectContext];
   [context deleteObject:photo];
   [self saveChanges];   
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue destinationViewController] isKindOfClass:[PhotoBrowserViewController class]]) {
      if ([sender isKindOfClass:[GridView class]] && [[segue sourceViewController] isKindOfClass:[PhotoAlbumViewController class]]) {
         GridView *gridView = sender;
         NSInteger selectedIndex = [gridView indexForSelectedCell];
         GridViewCell *cell = [gridView cellAtIndex:selectedIndex];
         CGRect cellFrame = [cell frame];
         
         PhotoBrowserViewController *photoBrowserViewController = [segue destinationViewController];
         [photoBrowserViewController setDelegate:[segue sourceViewController]];
         [photoBrowserViewController setStartAtIndex:selectedIndex];
         
         CGRect pushFromFrame = [[photoBrowserViewController view] convertRect:cellFrame fromView:gridView];
         [photoBrowserViewController setPushFromFrame:pushFromFrame];
      }
   } else if ([[segue destinationViewController] isKindOfClass:[FlickrViewController class]]) {
      [[segue destinationViewController] setManagedObjectContext:[self managedObjectContext]];
      [[segue destinationViewController] setObjectID:[self objectID]];
   }
}

#pragma mark - Rotation Support

- (void)layoutForLandscape
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   [[self view] setFrame:CGRectMake(18, 20, 738, 719)];
   [[self backgroundImageView] setImage:[UIImage imageNamed:@"stack-viewer-bg-landscape-right.png"]];
   [[self backgroundImageView] setFrame:[[self view] bounds]];
   [[self topShadowImageView] setFrame:CGRectMake(9, 51, 678, 8)];
   [[self gridView] setFrame:CGRectMake(20, 52, 654, 632)];
   [[self toolbar] setFrame:CGRectMake(9, 6, 678, 44)];
}

- (void)layoutForPortrait
{
   if ([self popoverController]) {
      [[self popoverController] dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   [[self view] setFrame:CGRectMake(26, 18, 716, 717)];
   [[self backgroundImageView] setImage:[UIImage imageNamed:@"stack-viewer-bg-portrait.png"]];
   [[self backgroundImageView] setFrame:[[self view] bounds]];
   [[self topShadowImageView] setFrame:CGRectMake(9, 51, 698, 8)];
   [[self gridView] setFrame:CGRectMake(20, 51, 678, 597)];
   [[self toolbar] setFrame:CGRectMake(9, 6, 698, 44)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      [self layoutForLandscape];
   } else {
      [self layoutForPortrait];
   }
}

@end
