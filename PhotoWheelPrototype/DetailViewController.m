//
//  DetailViewController.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/15/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "WheelView.h"
#import "PhotoWheelViewNub.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) PhotoWheelViewNub *selectedNubView;
@property (assign, nonatomic) NSUInteger selectedNubViewIndex;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (assign, nonatomic) BOOL usingCamera;
@end

@implementation DetailViewController

@synthesize toolbar = _toolbar;
@synthesize popoverController = _myPopoverController;
@synthesize data = data_;
@synthesize wheelView = wheelView_;
@synthesize selectedNubView = selectedNubView_;
@synthesize selectedNubViewIndex = selectedNubViewIndex_;
@synthesize imagePickerController = imagePickerController_;
@synthesize usingCamera = usingCamera_;
@synthesize photoAlbum = photoAlbum_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.title = NSLocalizedString(@"Detail", @"Detail");
   }
   return self;
}

#pragma mark - Managing the detail item

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   CGRect nubFrame = CGRectMake(0, 0, 75, 75);
   NSInteger count = 10;
   NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:count];
   for (NSInteger index = 0; index < count; index++) {
      PhotoWheelViewNub *newNub = [[PhotoWheelViewNub alloc] initWithFrame:nubFrame];
      
      UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nubDoubleTapped:)];
      [doubleTap setNumberOfTapsRequired:2];
      [newNub addGestureRecognizer:doubleTap];

      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nubTapped:)];
      [tap requireGestureRecognizerToFail:doubleTap];
      [newNub addGestureRecognizer:tap];
      
      [newArray addObject:newNub];
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

- (NSInteger)wheelViewNumberOfNubs:(WheelView *)wheelView
{
   return [self.data count];
}

- (WheelViewNub *)wheelView:(WheelView *)wheelView nubAtIndex:(NSInteger)index
{
   WheelViewNub *nub = [self.data objectAtIndex:index];
   return nub;
}

#pragma mark - Photo Management

- (void)presentAddPhotoMenu
{
   if ([self popoverController]) {
      [self.popoverController dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
   [actionSheet showFromRect:[self.selectedNubView frame] inView:[self wheelView] animated:YES];
}

- (void)presentPhotoLibrary
{
   if ([self popoverController]) {
      [self.popoverController dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }

   UIImagePickerController *newImagePicker = [[UIImagePickerController alloc] init];
   [newImagePicker setDelegate:self];
   [newImagePicker setAllowsEditing:NO];
   [newImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   [self setImagePickerController:newImagePicker];
   
   UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:[self imagePickerController]];
   [popover presentPopoverFromRect:[self.selectedNubView frame] inView:[self wheelView] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   [self setPopoverController:popover];
}

- (void)presentCamera
{
   UIImagePickerController *newImagePicker = [[UIImagePickerController alloc] init];
   [newImagePicker setDelegate:self];
   [newImagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
   [self setImagePickerController:newImagePicker];

   [self setUsingCamera:YES];
   [self presentModalViewController:newImagePicker animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   UIPopoverController *popover = [self popoverController];
   if (popover) {
      [popover dismissPopoverAnimated:YES];
      [self setPopoverController:nil];
   }
   
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   [self.selectedNubView setImage:image];

   Photo *targetPhoto = [[[self photoAlbum] photos] objectAtIndex:[self selectedNubViewIndex]];
   [targetPhoto saveImage:image];
   [targetPhoto setDateAdded:[NSDate date]];
   
   [[self photoAlbum] setKeyPhoto:targetPhoto];
   
   [[[self photoAlbum] managedObjectContext] save:nil];
   if ([self usingCamera]) {
      [self setUsingCamera:NO];
      [self dismissModalViewControllerAnimated:YES];
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
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
      default:
         break;
   }
}

#pragma mark - Actions

- (IBAction)styleValueChanged:(id)sender
{
   if ([sender selectedSegmentIndex] == 0) {
      [self.wheelView setStyle:WheelViewStyleWheel];
   } else {
      [self.wheelView setStyle:WheelViewStyleCarousel];
   }
}

- (void)nubTapped:(id)sender
{
   [self setSelectedNubView:(PhotoWheelViewNub *)[sender view]];
   [self setSelectedNubViewIndex:[[self data] indexOfObject:[self selectedNubView]]];
   if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      [self presentAddPhotoMenu];
   } else {
      [self presentPhotoLibrary];
   }
}

- (void)nubDoubleTapped:(id)sender
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - Accessors

- (void)setPhotoAlbum:(PhotoAlbum *)photoAlbum
{
   photoAlbum_ = photoAlbum;
   UIImage *defaultPhoto = [UIImage imageNamed:@"defaultPhoto.png"];
   for (NSUInteger index=0; index<10; index++) {
      PhotoWheelViewNub *nub = [[self data] objectAtIndex:index];
      Photo *photo = [[[self photoAlbum] photos] objectAtIndex:index];
      if ([photo originalImageData] != nil) {
         [nub setImage:[photo thumbnailImage]];
      } else {
         [nub setImage:defaultPhoto];
      }
   }
}

@end
