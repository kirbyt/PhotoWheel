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
@end

@implementation MainViewController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize wheelView = wheelView_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize pushFromRect = pushFromRect_;

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   PhotoAlbumViewController *childController = [[self storyboard] instantiateViewControllerWithIdentifier:@"PhotoAlbumScene"];
   [self addChildViewController:childController];
   [childController didMoveToParentViewController:self];
}

- (void)displayPhotoBrowser;
{
   [self performSegueWithIdentifier:@"PhotoBrowserSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue destinationViewController] isKindOfClass:[PhotoBrowserViewController class]]) {
      // We know we have only 1 child controller so it's safe to 
      // always grab the first one.
      PhotoAlbumViewController *childController = [[self childViewControllers] objectAtIndex:0];
      PhotoBrowserViewController *photoBrowserViewController = [segue destinationViewController];
      [photoBrowserViewController setDelegate:childController];
      [photoBrowserViewController setStartAtIndex:[childController selectedItemIndex]];
//      [self setPushFromRect:[photoBrowserViewController selectedItemRect]];
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


#pragma mark - WheelViewDataSource and WheelViewDelegate Methods

- (NSInteger)wheelViewNumberOfVisibleCells:(WheelView *)wheelView
{
   return 7;
}

- (NSInteger)wheelViewNumberOfCells:(WheelView *)wheelView
{
   NSArray *sections = self.fetchedResultsController.sections;
   NSInteger count = [[sections objectAtIndex:0] numberOfObjects];
   return count;
}

- (WheelViewCell *)wheelView:(WheelView *)wheelView cellAtIndex:(NSInteger)index
{
   PhotoWheelViewCell *cell = [wheelView dequeueReusableCell];
   if (!cell) {
      cell = [PhotoWheelViewCell photoWheelViewCell];
   }
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoAlbum = [self.fetchedResultsController objectAtIndexPath:indexPath];
   [[cell label] setText:[photoAlbum name]];

   Photo *photo = [photoAlbum keyPhoto];
   if (photo) {
      [[cell imageView] setImage:[photo thumbnailImage]];
   }
   
   return cell;
}

- (void)wheelView:(WheelView *)wheelView didSelectCellAtIndex:(NSInteger)index
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoAlbum = [self.fetchedResultsController objectAtIndexPath:indexPath];
   
   // There is only one view controller in childViewControllers so
   // grabbing the last one is okay.
   id childViewController = [[self childViewControllers] lastObject];
   [childViewController setManagedObjectContext:[self managedObjectContext]];
   [childViewController setObjectID:[photoAlbum objectID]];
   [childViewController refresh];
}

#pragma mark - Actions

- (IBAction)addPhotoAlbum:(id)sender
{
   NSManagedObjectContext *context = [self managedObjectContext];
   PhotoAlbum *photoAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"PhotoAlbum" inManagedObjectContext:context];
   [photoAlbum setDateAdded:[NSDate date]];

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
