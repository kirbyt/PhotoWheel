//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/22/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "AboutViewController.h"
#import "PhotoAlbumViewController.h"
#import "WheelView.h"
#import "PhotoAlbumNub.h"
#import "Models.h"
#import "UIView+KTCompositeView.h"


@interface MainViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableArray *photoAlbumNubs;
@property (nonatomic, retain) PhotoAlbumViewController *photoAlbumViewController;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
- (void)layoutForLandscape;
- (void)layoutForPortrait;
@end

@implementation MainViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize backgroundImageView = backgroundImageView_;
@synthesize discImageView = discImageView_;
@synthesize photoWheelView = photoWheelView_;
@synthesize addPhotoAlbumButton = addPhotoAlbumButton_;
@synthesize infoButton = infoButton_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize photoAlbumNubs = photoAlbumNubs_;
@synthesize photoAlbumViewController = photoAlbumViewController_;
@synthesize photoAlbumViewPlaceholder = photoAlbumViewPlaceholder_;
@synthesize currentOrientation = currentOrientation_;

- (void)dealloc
{
   [infoButton_ release], infoButton_ = nil;
   [addPhotoAlbumButton_ release], addPhotoAlbumButton_ = nil;
   [backgroundImageView_ release], backgroundImageView_ = nil;
   [discImageView_ release], discImageView_ = nil;
   [photoWheelView_ release], photoWheelView_ = nil;
   [fetchedResultsController_ release], fetchedResultsController_ = nil;
   [managedObjectContext_ release], managedObjectContext_ = nil;
   [photoAlbumNubs_ release], photoAlbumNubs_ = nil;
   [photoAlbumViewController_ release], photoAlbumViewController_ = nil;
   [photoAlbumViewPlaceholder_ release], photoAlbumViewPlaceholder_ = nil;
   
   [super dealloc];
}

- (id)init
{
   self = [super initWithNibName:@"MainView" bundle:nil];
   if (self) {
      NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:12];
      for (NSInteger index = 0; index < 12; index++) {
         [newArray addObject:[NSNull null]];
      }
      [self setPhotoAlbumNubs:newArray];
      [newArray release];
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   PhotoAlbumViewController *newController = [[PhotoAlbumViewController alloc] init];
   [newController setMainViewController:self];
   [[self photoAlbumViewPlaceholder] kt_addSubview:[newController view]];
   [self setPhotoAlbumViewController:newController];
   [newController release];
   
   [self layoutForPortrait];
   [self setCurrentOrientation:UIDeviceOrientationPortrait];
   
   // Unfortunately this controlled cannot rely on autoresizing views
   // because we provide a different look in landscape compared to
   // portrait. Therefore, the controller must listen for changing in
   // the device orientation and adjust the layout as needed.
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidUnload
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
   [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
   
   [self setInfoButton:nil];
   [self setAddPhotoAlbumButton:nil];
   [self setBackgroundImageView:nil];
   [self setDiscImageView:nil];
   [self setPhotoWheelView:nil];
   [self setPhotoAlbumViewPlaceholder:nil];
   [self setPhotoAlbumViewController:nil];

   [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
   [[[self navigationController] navigationBar] setHidden:YES];
   
   if (UIInterfaceOrientationIsLandscape([self currentOrientation])) {
      [self layoutForLandscape];
   } else {
      [self layoutForPortrait];
   }
   
}

- (void)orientationChanged:(NSNotification *)notification
{
   UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
   [self setCurrentOrientation:orientation];
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
   [self setCurrentOrientation:toInterfaceOrientation];
}

#define WHEELVIEW_INSET 50
- (void)layoutForLandscape
{
   UIImage *backgroundImage = [UIImage imageNamed:@"background-landscape-right-grooved.png"];
   [[self backgroundImageView] setImage:backgroundImage];

   [[self discImageView] setFrame:CGRectMake(702, 100, 547, 548)];
   
   [[self photoWheelView] setTopAtDegrees:-90.0];
   [[self photoWheelView] setFrame:CGRectInset([[self discImageView] frame], WHEELVIEW_INSET, WHEELVIEW_INSET)];
   [[self photoWheelView] setNeedsLayout];

   [[self photoAlbumViewPlaceholder] setFrame:CGRectMake(18, 20, 738, 719)];

   [[self addPhotoAlbumButton] setCenter:[[self discImageView] center]];

   CGRect frame = [[self infoButton] frame];
   frame.origin = CGPointMake(981, 712);
   [[self infoButton] setFrame:frame];
   
   [[self photoAlbumViewController] layoutForLandscape];
}

- (void)layoutForPortrait
{
   UIImage *backgroundImage = [UIImage imageNamed:@"background-portrait-grooved.png"]; 
   [[self backgroundImageView] setImage:backgroundImage];

   [[self discImageView] setFrame:CGRectMake(111, 680, 547, 548)];

   [[self photoWheelView] setTopAtDegrees:0.0];
   [[self photoWheelView] setFrame:CGRectInset([[self discImageView] frame], WHEELVIEW_INSET, WHEELVIEW_INSET)];
   [[self photoWheelView] setNeedsLayout];

   [[self photoAlbumViewPlaceholder] setFrame:CGRectMake(26, 18, 716, 717)];
   
   [[self addPhotoAlbumButton] setCenter:[[self discImageView] center]];
   
   CGRect frame = [[self infoButton] frame];
   frame.origin = CGPointMake(723, 960);
   [[self infoButton] setFrame:frame];
   
   [[self photoAlbumViewController] layoutForPortrait];
}

#pragma mark - Actions

- (IBAction)addPhotoAlbum:(id)sender
{
   NSFetchedResultsController *fetchedRequestController = [self fetchedResultsController];
   NSManagedObjectContext *context = [fetchedRequestController managedObjectContext];

   [PhotoAlbum insertNewInManagedObjectContext:context];
   
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

- (BOOL)deletePhotoAlbum:(PhotoAlbum *)photoAlbum
{
   BOOL success = YES;
   NSManagedObjectContext *context = [photoAlbum managedObjectContext];
   [context deleteObject:photoAlbum];
   
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
   
   [[self photoWheelView] reloadData];
   return success;
}

- (IBAction)showAbout:(id)sender
{
   AboutViewController *newController = [[AboutViewController alloc] init];
   [self presentModalViewController:newController animated:YES];
   [newController release];
}

#pragma mark - PhotoWheelViewDataSource Methods

- (NSInteger)wheelViewNumberOfNubs:(WheelView *)wheelView
{
   NSInteger count = [[[[self fetchedResultsController] sections] objectAtIndex:0] numberOfObjects];
   return count;
}

- (WheelViewNub *)wheelView:(WheelView *)wheelView nubAtIndex:(NSInteger)index
{
//   PhotoAlbumNub *nub = (PhotoAlbumNub *)[wheelView dequeueReusableNub];
//   if (nub == nil) {
//      NSLog(@"create new");
//      nub = [PhotoAlbumNub photoAlbumNub];
//   }
   
   id nub = [[self photoAlbumNubs] objectAtIndex:index];
   if (nub == [NSNull null]) {
      nub = [PhotoAlbumNub photoAlbumNub];
      [[self photoAlbumNubs] replaceObjectAtIndex:index withObject:nub];
   }
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoAlbum = [[self fetchedResultsController] objectAtIndexPath:indexPath];

   UIImage *image = nil;
   Photo *keyPhoto = [photoAlbum keyPhoto];
   if (keyPhoto) {
      image = [keyPhoto thumbnailImage];
   } else {
      image = [UIImage imageNamed:@"photoDefault.png"];

   }
   [nub setImage:image];
   [nub setTitle:[photoAlbum name]];
   
   return nub;
}

- (void)wheelView:(WheelView *)wheelView didSelectNubAtIndex:(NSInteger)index
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoAlbum = [[self fetchedResultsController] objectAtIndexPath:indexPath];

   [[self photoAlbumViewController] setPhotoAlbum:photoAlbum];
}


#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)fetchedResultsController
{
   if (fetchedResultsController_) {
      return fetchedResultsController_;
   }
   
   NSString *cacheName = NSStringFromClass([self class]);
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[PhotoAlbum entityName] inManagedObjectContext:[self managedObjectContext]];
   [fetchRequest setEntity:entityDescription];
   
   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
   
   NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:cacheName];
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
   [[self photoWheelView] reloadData];
}

@end
