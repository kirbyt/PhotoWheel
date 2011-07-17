//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoAlbumViewController.h"
#import "PhotoBrowserViewController.h"
#import "PhotoWheelViewCell.h"
#import "PhotoAlbum.h"
#import "Photo.h"

@interface MainViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *cachedWheelViewCells;
@end

@implementation MainViewController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize wheelView = wheelView_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize cachedWheelViewCells = cachedWheelViewCells_;

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   PhotoAlbumViewController *childController = [[self storyboard] instantiateViewControllerWithIdentifier:@"PhotoAlbumScene"];
   [self addChildViewController:childController];
   [childController didMoveToParentViewController:self];
   
   NSInteger capacity = 7;
   self.cachedWheelViewCells = [[NSMutableArray alloc] initWithCapacity:capacity];
   for (NSInteger index = 0; index < capacity; index++) {
      [self.cachedWheelViewCells addObject:[NSNull null]];
   }
}

- (void)displayPhotoBrowser
{
   [self performSegueWithIdentifier:@"PhotoBrowserSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue destinationViewController] isKindOfClass:[PhotoBrowserViewController class]]) {
      PhotoBrowserViewController *photoBrowserViewController = [segue destinationViewController];
      [photoBrowserViewController setManagedObjectContext:[self managedObjectContext]];
   }
}


#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)fetchedResultsController
{
   if (fetchedResultsController_) {
      return fetchedResultsController_;
   }
   
   NSString *cacheName = NSStringFromClass([self class]);
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"PhotoAlbum" inManagedObjectContext:[self managedObjectContext]];
   [fetchRequest setEntity:entityDescription];
   
   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
   
   self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:cacheName];
   [self.fetchedResultsController setDelegate:self];
   
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
   [self.wheelView reloadData];
}


#pragma mark - WheelViewDataSource Methods

- (NSInteger)wheelViewNumberOfCells:(WheelView *)wheelView
{
   NSArray *sections = self.fetchedResultsController.sections;
   NSInteger count = [[sections objectAtIndex:0] numberOfObjects];
   NSLog(@"cell count: %i", count);
   return count;
}

- (WheelViewCell *)wheelView:(WheelView *)wheelView cellAtIndex:(NSInteger)index
{
   id cell = [self.cachedWheelViewCells objectAtIndex:index];
   if (cell == [NSNull null]) {
      cell = [PhotoWheelViewCell photoWheelViewCell];
      [self.cachedWheelViewCells replaceObjectAtIndex:index withObject:cell];
   }
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoAlbum = [self.fetchedResultsController objectAtIndexPath:indexPath];
   Photo *photo = [photoAlbum keyPhoto];
   if (photo) {
      [[cell imageView] setImage:[photo thumbnailImage]];
   }
   
   return cell;
}

#pragma mark - Actions

- (IBAction)addPhotoAlbum:(id)sender
{
   NSManagedObjectContext *context = [self managedObjectContext];
   [NSEntityDescription insertNewObjectForEntityForName:@"PhotoAlbum" inManagedObjectContext:context];

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

@end
