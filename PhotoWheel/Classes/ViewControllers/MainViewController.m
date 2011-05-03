//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/22/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "WheelView.h"
#import "PhotoAlbumNub.h"
#import "Models.h"


@interface MainViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableArray *photoAlbumNubs;
- (void)layoutForLandscape;
- (void)layoutForPortrait;
@end

@implementation MainViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize backgroundImageView = backgroundImageView_;
@synthesize photoWheelView = photoWheelView_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize photoAlbumNubs = photoAlbumNubs_;

- (void)dealloc
{
   [backgroundImageView_ release], backgroundImageView_ = nil;
   [photoWheelView_ release], photoWheelView_ = nil;
   [fetchedResultsController_ release], fetchedResultsController_ = nil;
   [managedObjectContext_ release], managedObjectContext_ = nil;
   [photoAlbumNubs_ release], photoAlbumNubs_ = nil;
   
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

   [[self photoWheelView] addObserver:self forKeyPath:@"selectedIndex" options:0 context:nil];
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   
   [[self photoWheelView] removeObserver:self forKeyPath:@"selectedIndex"];
   
   [self setBackgroundImageView:nil];
   [self setPhotoWheelView:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
   if ([keyPath isEqualToString:@"selectedIndex"]) {
      NSLog(@"selectedIndex: %i", [[self photoWheelView] selectedIndex]);
   }
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

- (void)layoutForLandscape
{
   UIImage *backgroundImage = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
   [[self backgroundImageView] setImage:backgroundImage];
   
   [[self photoWheelView] setTopAtDegrees:90.0];

   CGPoint newOrigin = CGPointMake(-250, 180);
   CGRect frame = [[self photoWheelView] frame];
   frame.origin = newOrigin;
   [[self photoWheelView] setFrame:frame];
   [[self photoWheelView] setNeedsLayout];
}

- (void)layoutForPortrait
{
   UIImage *backgroundImage = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
   [[self backgroundImageView] setImage:backgroundImage];

   [[self photoWheelView] setTopAtDegrees:0.0];

   CGPoint newOrigin = CGPointMake(84, 756);
   CGRect frame = [[self photoWheelView] frame];
   frame.origin = newOrigin;
   [[self photoWheelView] setFrame:frame];
   [[self photoWheelView] setNeedsLayout];
}

#pragma mark - Actions

- (IBAction)addPhotoAlbum:(id)sender
{
   NSFetchedResultsController *fetchedRequestController = [self fetchedResultsController];
   NSManagedObjectContext *context = [fetchedRequestController managedObjectContext];

   PhotoAlbum *newPhotoAlbum = [PhotoAlbum insertNewInManagedObjectContext:context];
   [newPhotoAlbum setName:@"Title"];
   
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
   [nub setTitle:[NSString stringWithFormat:@"%@-%i", [photoAlbum name], index]];
   
   return nub;
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
   
   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
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
