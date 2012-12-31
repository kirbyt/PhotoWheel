//
//  PhotosViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/12/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoAlbum.h"
#import "Photo.h"
#import "ThumbnailCell.h"
#import "SendEmailController.h"
#import "FlickrViewController.h"

@interface PhotosViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, SendEmailControllerDelegate>

@property (nonatomic, strong) SendEmailController *sendEmailController;
@property (nonatomic, strong) PhotoAlbum *photoAlbum;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *imagePickerPopoverController;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *toolbarWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewVerticalSpacingConstraint;

@property (nonatomic, strong) UIActionSheet *addPhotoActionSheet;
@property (nonatomic, strong) UIActionSheet *actionActionSheet;

@property (nonatomic, assign, readwrite) NSInteger selectedPhotoIndex;
@property (nonatomic, assign, readwrite) CGRect selectedPhotoFrame;

- (IBAction)showActionMenu:(id)sender;
- (IBAction)addPhoto:(id)sender;
@end

@implementation PhotosViewController

- (void)dealloc
{
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc removeObserver:self name:kPhotoWheelDidSelectAlbum object:nil];
   [nc removeObserver:self name:kPhotoWheelDidDeletePhotoAtIndex object:nil];
   [nc removeObserver:self name:kRefetchAllDataNotification object:nil];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc addObserver:self selector:@selector(didSelectAlbum:) name:kPhotoWheelDidSelectAlbum object:nil];
   [nc addObserver:self selector:@selector(didDeletePhotoAtIndex:) name:kPhotoWheelDidDeletePhotoAtIndex object:nil];
   [nc addObserver:self selector:@selector(handleCloudUpdate:) name:kRefetchAllDataNotification object:[[UIApplication sharedApplication] delegate]];

   UIImage *image = [UIImage imageNamed:@"1x1-transparent"];
   [[self toolbar] setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
   [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   [self rotateToInterfaceOrientation:[self interfaceOrientation]];
}

- (void)handleCloudUpdate:(NSNotification *)notification
{
   [self setFetchedResultsController:nil];
   [self reloadData];
}

- (void)didSelectAlbum:(NSNotification *)notification
{
   PhotoAlbum *photoAlbum = nil;
   NSDictionary *userInfo = [notification userInfo];
   if (userInfo) {
      photoAlbum = userInfo[@"PhotoAlbum"];
   }
   [self setPhotoAlbum:photoAlbum];
   [self reloadData];
}

- (void)didDeletePhotoAtIndex:(NSNotification *)notification
{
   NSDictionary *userInfo = [notification userInfo];
   NSNumber *indexNumber = userInfo[@"index"];
   NSInteger index = [indexNumber integerValue];
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   Photo *photo = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   NSManagedObjectContext *context = [photo managedObjectContext];
   [context deleteObject:photo];
   [self saveChanges];
}

- (void)reloadData
{
   PhotoAlbum *album = [self photoAlbum];
   if (album) {
      [[self toolbar] setHidden:NO];
      [[self textField] setText:[album name]];
   } else {
      [[self toolbar] setHidden:YES];
      [[self textField] setText:@""];
   }
   
   [self setFetchedResultsController:nil];
   [[self collectionView] reloadData];
}

- (BOOL)saveChanges
{
   return [self saveChangesWithManagedObjectContext:[self managedObjectContext]];
}

- (BOOL)saveChangesWithManagedObjectContext:(NSManagedObjectContext *)context
{
   NSError *error = nil;
   BOOL success = [context save:&error];
   ZAssert(success, @"Unresolved error %@, %@", error, [error userInfo]);
   return success;
}

- (NSManagedObjectContext *)managedObjectContext
{
   PhotoAlbum *album = [self photoAlbum];
   NSManagedObjectContext *context = [album managedObjectContext];
   return context;
}

- (UIImagePickerController *)imagePickerController
{
   if (_imagePickerController) {
      return _imagePickerController;
   }

   UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
   [imagePickerController setDelegate:self];
   [self setImagePickerController:imagePickerController];
   
   return _imagePickerController;
}

- (BOOL)dismissPopovers:(id)popover
{
   BOOL didClose = NO;
   if ([self imagePickerPopoverController]) {
      if (popover == [self imagePickerPopoverController]) didClose = YES;
      [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
      [self setImagePickerController:nil];
   }
   
   if ([self actionActionSheet]) {
      if (popover == [self actionActionSheet]) didClose = YES;
      [[self actionActionSheet] dismissWithClickedButtonIndex:-1 animated:YES];
      [self setActionActionSheet:nil];
   }
   
   if ([self addPhotoActionSheet]) {
      if (popover == [self addPhotoActionSheet]) didClose = YES;
      [[self addPhotoActionSheet] dismissWithClickedButtonIndex:-1 animated:YES];
      [self setAddPhotoActionSheet:nil];
   }
   return didClose;
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

#pragma mark - Actions

- (IBAction)showActionMenu:(id)sender
{
   if ([self dismissPopovers:[self actionActionSheet]]) {
      // Return if closing the action sheet.
      return;
   }
   
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   if ([SendEmailController canSendMail]) {
      [actionSheet addButtonWithTitle:@"Email Photo Album"];
   }
   [actionSheet addButtonWithTitle:@"Delete Photo Album"];
   [actionSheet showFromBarButtonItem:sender animated:YES];
   [self setActionActionSheet:actionSheet];
}

- (IBAction)addPhoto:(id)sender
{
   if ([self dismissPopovers:[self addPhotoActionSheet]]) {
      return;
   }
   [self presentPhotoPickerMenu];
}

#pragma mark - Confirm and delete photo album

- (void)confirmDeletePhotoAlbum
{
   NSString *message;
   NSString *name = [[self photoAlbum] name];
   if ([name length] > 0) {
      message = [NSString stringWithFormat: @"Delete the photo album \"%@\". This action cannot be undone.", name];
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
      PhotoAlbum *album = [self photoAlbum];
      NSManagedObjectContext *context = [self managedObjectContext];
      [context deleteObject:album];
      [self saveChanges];
      [self setPhotoAlbum:nil];
      [self reloadData];
   }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   // Do nothing if the user taps outside the action
   // sheet (thus closing the popover containing the
   // action sheet).
   if (buttonIndex < 0) {
      [self dismissPopovers:nil];
      return;
   }
   
   NSMutableArray *names = [[NSMutableArray alloc] init];
   
   if (actionSheet == [self actionActionSheet]) {
      [self setActionActionSheet:nil];
      if ([SendEmailController canSendMail]) [names addObject:@"emailPhotos"];
      [names addObject:@"confirmDeletePhotoAlbum"];
      
   } else {
      [self setAddPhotoActionSheet:nil];
      BOOL hasCamera = [UIImagePickerController
                        isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
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
   
   UIPopoverController *newPopoverController =
   [[UIPopoverController alloc] initWithContentViewController:imagePicker];
   [newPopoverController presentPopoverFromBarButtonItem:[self addButton]
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
   [self setImagePickerPopoverController:newPopoverController];
}

- (void)presentFlickr
{
   [self performSegueWithIdentifier:@"PresentFlickrScene" sender:self];
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
   [actionSheet addButtonWithTitle:@"Choose from Flickr"];
   [actionSheet setTag:1];
   [actionSheet showFromBarButtonItem:[self addButton] animated:YES];
   [self setAddPhotoActionSheet:actionSheet];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue destinationViewController]
        isKindOfClass:[FlickrViewController class]])
   {
      [[segue destinationViewController] setPhotoAlbum:[self photoAlbum]];
   }
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

   NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
   [context setParentContext:[self managedObjectContext]];
   [context performBlock:^{
      Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
      [newPhoto setDateAdded:[NSDate date]];
      [newPhoto saveImage:image];
      
      // Grab the photo album using the child context.
      PhotoAlbum *photoAlbum = (PhotoAlbum *)[context objectWithID:[[self photoAlbum] objectID]];
      [newPhoto setPhotoAlbum:photoAlbum];

      if ([self saveChangesWithManagedObjectContext:context]) {
         NSManagedObjectContext *parentContext = [context parentContext];
         [parentContext performBlockAndWait:^{
            (void)[self saveChangesWithManagedObjectContext:parentContext];
         }];
      }
   }];
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
   [fetchRequest setSortDescriptors:@[sortDescriptor]];

   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoAlbum = %@", [self photoAlbum]];
   [fetchRequest setPredicate:predicate];
   
   NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:cacheName];
   [newFetchedResultsController setDelegate:self];
   [self setFetchedResultsController:newFetchedResultsController];
   
   NSError *error = nil;
   ZAssert([[self fetchedResultsController] performFetch:&error], @"Unresolved error %@, %@", error, [error userInfo]);
   
   return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self collectionView] reloadData];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   NSFetchedResultsController *frc = [self fetchedResultsController];
   NSInteger count = [[[frc sections] objectAtIndex:section] numberOfObjects];
   return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   ThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailCell" forIndexPath:indexPath];

   NSFetchedResultsController *frc = [self fetchedResultsController];
   Photo *photo = [frc objectAtIndexPath:indexPath];
   [[cell imageView] setImage:[photo smallImage]];
   
   return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   [self setSelectedPhotoIndex:[indexPath item]];
   
   UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
   CGRect cellFrame = [cell frame];
   cellFrame = [[self view] convertRect:cellFrame fromView:collectionView];
   [self setSelectedPhotoFrame:cellFrame];
   
   UIApplication *app = [UIApplication sharedApplication];
   [app sendAction:@selector(pushPhotoBrowser:) to:nil from:self forEvent:nil];
}

#pragma mark - Public Methods

- (NSArray *)photos
{
   NSArray *photos = [[self fetchedResultsController] fetchedObjects];
   return photos;
}

- (UIImage *)selectedPhotoImage
{
   NSInteger index = [self selectedPhotoIndex];
   NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
   NSFetchedResultsController *frc = [self fetchedResultsController];
   Photo *photo = [frc objectAtIndexPath:indexPath];
   return [photo largeImage];
}

#pragma mark - Rotation and Auto Layout

- (void)updateViewConstraints
{
   [super updateViewConstraints];
   [self updateViewConstraintsForInterfaceOrientation:[self interfaceOrientation]];
}

- (void)updateViewConstraintsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   UICollectionView *collectionView = [self collectionView];
   [collectionView removeConstraints:[collectionView constraints]];
   NSDictionary *views = @{ @"collectionView" : collectionView };
   
   if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
      ADD_CONSTRAINT(collectionView, @"V:[collectionView(632)]", views);
      ADD_CONSTRAINT(collectionView, @"H:[collectionView(664)]", views);
      [[self collectionViewVerticalSpacingConstraint] setConstant:52];
      [[self toolbarWidthConstraint] setConstant:678];
      
   } else {
      ADD_CONSTRAINT(collectionView, @"V:[collectionView(596)]", views);
      ADD_CONSTRAINT(collectionView, @"H:[collectionView(684)]", views);
      [[self collectionViewVerticalSpacingConstraint] setConstant:51];
      [[self toolbarWidthConstraint] setConstant:698];
   }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   [self rotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   [self updateViewConstraintsForInterfaceOrientation:toInterfaceOrientation];
   
   UIImage *image = nil;
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      image = [UIImage imageNamed:@"stack-viewer-bg-landscape-right"];
   } else {
      image = [UIImage imageNamed:@"stack-viewer-bg-portrait"];
   }
   [[self backgroundImageView] setImage:image];
}

#pragma mark - Email and SendEmailControllerDelegate methods

- (void)emailPhotos
{
   PhotoAlbum *album = [self photoAlbum];
   NSSet *photos = [album photos];
   
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
