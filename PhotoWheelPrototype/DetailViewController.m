//
//  DetailViewController.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/15/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "PhotoWheelViewCell.h"

@interface DetailViewController ()
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) PhotoWheelViewCell *selectedPhotoWheelViewCell;
@property (assign, nonatomic) NSUInteger selectedWheelViewCellIndex;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize data = data_;
@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize toolbar = _toolbar;
@synthesize popoverController = _myPopoverController;
@synthesize wheelView = wheelView_;
@synthesize photoAlbum = photoAlbum_;
@synthesize selectedPhotoWheelViewCell = selectedPhotoWheelViewCell;
@synthesize selectedWheelViewCellIndex = selectedWheelViewCellIndex_;
@synthesize actionSheet = actionSheet_;
@synthesize imagePickerController = imagePickerController_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.title = NSLocalizedString(@"Detail", @"Detail");
      
      [self setImagePickerController:[[UIImagePickerController alloc] init]];
      [self.imagePickerController setDelegate:self];
   }
   return self;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
   if (_detailItem != newDetailItem) {
      _detailItem = newDetailItem;
      
      // Update the view.
      [self configureView];
   }
   
   if (self.popoverController != nil) {
      [self.popoverController dismissPopoverAnimated:YES];
   }        
}

- (void)configureView
{
   // Update the user interface for the detail item.
   
   if (self.detailItem) {
      self.detailDescriptionLabel.text = [self.detailItem description];
   }
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];

   CGRect cellFrame = CGRectMake(0, 0, 75, 75);
   NSInteger count = 10;
   NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:count];
   for (NSInteger index = 0; index < count; index++) {
      PhotoWheelViewCell *cell = [[PhotoWheelViewCell alloc] initWithFrame:cellFrame];
      
      UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDoubleTapped:)];
      [doubleTap setNumberOfTapsRequired:2];
      [cell addGestureRecognizer:doubleTap];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
      [tap requireGestureRecognizerToFail:doubleTap];
      [cell addGestureRecognizer:tap];
      
      [newArray addObject:cell];
   }
   [self setData:[newArray copy]];
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
   [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   if ([self actionSheet]) {
      [self.actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
   }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
   barButtonItem.title = @"Photo Albums";
   NSMutableArray *items = [[self.toolbar items] mutableCopy];
   [items insertObject:barButtonItem atIndex:0];
   [self.toolbar setItems:items animated:YES];
   self.popoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
   // Called when the view is shown again in the split view, invalidating the button and popover controller.
   NSMutableArray *items = [[self.toolbar items] mutableCopy];
   [items removeObjectAtIndex:0];
   [self.toolbar setItems:items animated:YES];
   self.popoverController = nil;
}

#pragma mark - WheelViewDataSource Methods

- (NSInteger)wheelViewNumberOfCells:(WheelView *)wheelView
{
   NSInteger count = [self.data count];
   return count;
}

- (WheelViewCell *)wheelView:(WheelView *)wheelView cellAtIndex:(NSInteger)index
{
   WheelViewCell *cell = [self.data objectAtIndex:index];
   return cell;
}

#pragma mark - Image Picker Helper Methods

- (void)presentCamera
{
   // Display the camera.
   [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
   [self presentModalViewController:[self imagePickerController] animated:YES];
}

- (void)presentPhotoLibrary
{
   // Display assets from the photo library only.
   [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   
   UIView *view = [self selectedPhotoWheelViewCell];
   CGRect rect = [view bounds];
   
   UIPopoverController *newPopoverController = [[UIPopoverController alloc] initWithContentViewController:[self imagePickerController]];
   [newPopoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   [self setPopoverController:newPopoverController];
}

- (void)presentPhotoPickerMenu
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   [actionSheet addButtonWithTitle:@"Take Photo"];
   [actionSheet addButtonWithTitle:@"Choose from Library"];
   
   UIView *view = [self selectedPhotoWheelViewCell];
   CGRect rect = [view bounds];
   [actionSheet showFromRect:rect inView:view animated:YES];

   [self setActionSheet:actionSheet];
}

#pragma mark - Actions

- (IBAction)segmentedControlValueChanged:(id)sender
{
   NSInteger index = [sender selectedSegmentIndex];
   if (index == 0) {
      [self.wheelView setStyle:WheelViewStyleWheel];
   } else {
      [self.wheelView setStyle:WheelViewStyleCarousel];
   }
}

- (void)cellTapped:(UIGestureRecognizer *)recognizer
{
   [self setSelectedPhotoWheelViewCell:(PhotoWheelViewCell *)[recognizer view]];

   BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   if (hasCamera) {
      [self presentPhotoPickerMenu];
   } else {
      [self presentPhotoLibrary];
   }
}

- (void)cellDoubleTapped:(UIGestureRecognizer *)recognizer
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   switch (buttonIndex) {
      case 0:
         [self presentCamera];
         break;
      case 1:
         [self presentPhotoLibrary];
         break;
   }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
   [self setActionSheet:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   // If the popover controller is available then
   // assume the photo is selected from the library
   // and not from the camera.
   BOOL takenWithCamera = ([self popoverController] == nil);
   
   // Dismiss the popover controller if available, 
   // otherwise dismiss the camera view.
   if ([self popoverController]) {
      [self.popoverController dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   } else {
      [self dismissModalViewControllerAnimated:YES];
   }

   // Retrieve and display the image.
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   [self.selectedPhotoWheelViewCell setImage:image];
   
   Photo *targetPhoto = [[[self photoAlbum] photos] objectAtIndex:[self selectedWheelViewCellIndex]];
   [targetPhoto saveImage:image];
   [targetPhoto setDateAdded:[NSDate date]];
   
   [[self photoAlbum] setKeyPhoto:targetPhoto];
   
   NSError *error = nil;
   [[[self photoAlbum] managedObjectContext] save:&error];

   if (takenWithCamera) {
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
   }
}

#pragma mark - Accessors

- (void)setPhotoAlbum:(PhotoAlbum *)photoAlbum
{
   photoAlbum_ = photoAlbum;
   UIImage *defaultPhoto = [UIImage imageNamed:@"defaultPhoto.png"];
   for (NSUInteger index=0; index<10; index++) {
      PhotoWheelViewCell *cell = [[self data] objectAtIndex:index];
      Photo *photo = [[[self photoAlbum] photos] objectAtIndex:index];
      UIImage *thumbnail = [photo thumbnailImage];
      if (thumbnail != nil) {
         [cell setImage:thumbnail];
      } else {
         [cell setImage:defaultPhoto];
      }
   }
}

@end
