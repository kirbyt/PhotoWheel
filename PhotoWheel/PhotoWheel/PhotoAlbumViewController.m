//
//  PhotoAlbumViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumViewController.h"
#import "PhotoAlbum.h"                                                  // 1
#import "Photo.h"
#import "ImageGridViewCell.h"

@interface PhotoAlbumViewController ()                                  // 2
@property (nonatomic, strong) PhotoAlbum *photoAlbum;                   // 3
@property (nonatomic, strong) UIImagePickerController *imagePickerController;  // 2
@property (nonatomic, strong) UIPopoverController *imagePickerPopoverController;// 3
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
- (void)presentPhotoPickerMenu;                                         // 4
@end

@implementation PhotoAlbumViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize objectID = _objectID;
@synthesize toolbar = _toolbar;
@synthesize textField = _textField;
@synthesize addButton = _addButton;
@synthesize photoAlbum = _photoAlbum;
@synthesize imagePickerController = _imagePickerController;           // 5
@synthesize imagePickerPopoverController = _imagePickerPopoverController;
@synthesize gridView = _gridView;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)didMoveToParentViewController:(UIViewController *)parent
{
   // Position the view within the new parent.
   [[parent view] addSubview:[self view]];
   CGRect newFrame = CGRectMake(26, 18, 716, 717);
   [[self view] setFrame:newFrame];
   
   [[self view] setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidLoad                                                     // 4
{
   [super viewDidLoad];
   [self reload];
}

- (void)viewDidUnload                                                   // 5
{
   [self setToolbar:nil];
   [self setTextField:nil];
   [self setAddButton:nil];
   [self setGridView:nil];
   [super viewDidUnload];
}
- (UIImagePickerController *)imagePickerController                    // 6
{
   if (_imagePickerController) {
      return _imagePickerController;
   }
   
   self.imagePickerController = [[UIImagePickerController alloc] init];
   [self.imagePickerController setDelegate:self];
   
   return _imagePickerController;
}

#pragma mark Photo album management

- (void)reload                                                          // 6
{
   if ([self managedObjectContext] && [self objectID]) {                // 7
      self.photoAlbum = (PhotoAlbum *)[self.managedObjectContext 
                                       objectWithID:[self objectID]];   // 8
      [[self toolbar] setHidden:NO];                                    // 9
      [[self textField] setText:[self.photoAlbum name]];                // 10
   } else {
      [self setPhotoAlbum:nil];
      [[self toolbar] setHidden:YES];
      [[self textField] setText:@""];
   }
   
   [self setFetchedResultsController:nil];
   [[self gridView] reloadData];
}

- (void)saveChanges                                                     // 11
{
   // Save the context.
   NSManagedObjectContext *context = [self managedObjectContext];
   NSError *error = nil;
   if (![context save:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. 
       You should not use this function in a shipping application, although 
       it may be useful during development. If it is not possible to recover 
       from the error, display an alert panel that instructs the user to quit 
       the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

#pragma mark - UITextFieldDelegate methods                              // 12

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField            // 13
{
   [textField setBorderStyle:UITextBorderStyleRoundedRect];
   [textField setTextColor:[UIColor blackColor]];
   [textField setBackgroundColor:[UIColor whiteColor]];
   return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField                 // 14
{
   [textField setBackgroundColor:[UIColor clearColor]];
   [textField setTextColor:[UIColor whiteColor]];
   [textField setBorderStyle:UITextBorderStyleNone];
   
   [[self photoAlbum] setName:[textField text]];
   [self saveChanges];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField                  // 15
{
   [textField resignFirstResponder];
   return NO;
}

#pragma mark Actions

- (IBAction)showActionMenu:(id)sender 
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
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
      message = [NSString stringWithFormat:
                 @"Delete the photo album \"%@\". This action cannot be undone.", 
                 name];
   } else {
      message = @"Delete this photo album? This action cannot be undone.";
   }
   UIAlertView *alertView = [[UIAlertView alloc] 
                             initWithTitle:@"Delete Photo Album" 
                             message:message 
                             delegate:self 
                             cancelButtonTitle:@"Cancel" 
                             otherButtonTitles:@"OK", nil];
   [alertView show];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView 
clickedButtonAtIndex:(NSInteger)buttonIndex
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

- (void)actionSheet:(UIActionSheet *)actionSheet 
clickedButtonAtIndex:(NSInteger)buttonIndex
{
   // Do nothing if the user taps outside the action 
   // sheet (thus closing the popover containing the
   // action sheet).
   if (buttonIndex < 0) {
      return;
   }
   
   NSMutableArray *names = [[NSMutableArray alloc] init];         // 9
   
   if ([actionSheet tag] == 0) {
      [names addObject:@"confirmDeletePhotoAlbum"];
      
   } else {
      BOOL hasCamera = [UIImagePickerController 
          isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
      if (hasCamera) [names addObject:@"presentCamera"];
      [names addObject:@"presentPhotoLibrary"];
   }
   
   SEL selector = NSSelectorFromString([names objectAtIndex:buttonIndex]);
   [self performSelector:selector];
}

#pragma mark - Image picker helper methods

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
   
   UIPopoverController *newPopoverController = 
      [[UIPopoverController alloc] initWithContentViewController:imagePicker];
   [newPopoverController presentPopoverFromBarButtonItem:[self addButton] 
                                permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                animated:YES];
   [self setImagePickerPopoverController:newPopoverController];
}

- (void)presentPhotoPickerMenu
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   BOOL hasCamera = [UIImagePickerController 
               isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   if (hasCamera) {
      [actionSheet addButtonWithTitle:@"Take Photo"];
   }
   [actionSheet addButtonWithTitle:@"Choose from Library"];
   [actionSheet setTag:1];
   [actionSheet showFromBarButtonItem:[self addButton] animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   // If the popover controller is available, 
   // assume the photo is selected from the library
   // and not from the camera.
   BOOL takenWithCamera = ([self imagePickerPopoverController] == nil);
   
   if (takenWithCamera) {
      [self dismissModalViewControllerAnimated:YES];
   } else {
      [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
      [self setImagePickerPopoverController:nil];
   }
   
   // Retrieve and display the image.
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   
   NSManagedObjectContext *context = [self managedObjectContext];
   Photo *newPhoto = 
      [NSEntityDescription insertNewObjectForEntityForName:@"Photo" 
                                    inManagedObjectContext:context];
   [newPhoto setDateAdded:[NSDate date]];
   [newPhoto saveImage:image];
   [newPhoto setPhotoAlbum:[self photoAlbum]];
   
   [self saveChanges];
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
   
   NSString *cacheName = [NSString stringWithFormat:@"%@-%@", 
                          [self.photoAlbum name], [self.photoAlbum dateAdded]];
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription = 
      [NSEntityDescription entityForName:@"Photo" 
                  inManagedObjectContext:context];
   [fetchRequest setEntity:entityDescription];
   
   NSSortDescriptor *sortDescriptor = 
      [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
   
   [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"photoAlbum = %@", 
                               [self photoAlbum]]];
   
   NSFetchedResultsController *newFetchedResultsController = 
      [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                          managedObjectContext:context 
                                            sectionNameKeyPath:nil 
                                                     cacheName:cacheName];
   [newFetchedResultsController setDelegate:self];
   [self setFetchedResultsController:newFetchedResultsController];
   
   NSError *error = nil;
   if (![[self fetchedResultsController] performFetch:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. 
       You should not use this function in a shipping application, although 
       it may be useful during development. If it is not possible to recover 
       from the error, display an alert panel that instructs the user to quit 
       the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
   
   return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self gridView] reloadData];
}

#pragma mark GridViewDataSource methods

- (NSInteger)gridViewNumberOfCells:(GridView *)gridView
{
   NSInteger count = [[[[self fetchedResultsController] sections] 
                       objectAtIndex:0] numberOfObjects];
   return count;
}

- (GridViewCell *)gridView:(GridView *)gridView cellAtIndex:(NSInteger)index
{
   ImageGridViewCell *cell = [gridView dequeueReusableCell];
   if (cell == nil) {
      cell = [ImageGridViewCell imageGridViewCellWithSize:CGSizeMake(100, 100)];
   }
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   [[cell imageView] setImage:[photo smallImage]];
   
   return cell;
}
- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return CGSizeMake(100, 100);
}

- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index
{
   
}

@end
