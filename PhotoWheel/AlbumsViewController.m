//
//  PhotoAlbumsViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "AlbumsViewController.h"
#import "PhotoWheelViewCell.h"
#import "PhotoAlbum.h"
#import "Photo.h"
#import "PhotosViewController.h"

@interface AlbumsViewController ()
@property (nonatomic, strong) 
   NSFetchedResultsController *fetchedResultsController;
@end

@implementation AlbumsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize wheelView = _wheelView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize photoAlbumViewController = _photoAlbumViewController;

- (void)dealloc 
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kRefetchAllDataNotification object:nil];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
   [[NSNotificationCenter defaultCenter] addObserverForName:kRefetchAllDataNotification object:[[UIApplication sharedApplication] delegate] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *__strong note) {
      [self setFetchedResultsController:nil];
      [[self wheelView] reloadData];
   }];
}

- (void)viewDidUnload
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kRefetchAllDataNotification object:nil];
   [self setWheelView:nil];
   [super viewDidUnload];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   CGRect newFrame;
   CGFloat angleOffset;
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      newFrame = CGRectMake(700, 100, 551, 550);
      angleOffset = 270.0;
   } else {
      newFrame = CGRectMake(109, 680, 551, 550);
      angleOffset = 0.0;
   }
   [[self view] setFrame:newFrame];
   [[self wheelView] setAngleOffset:angleOffset];
}

#pragma mark - Actions

- (IBAction)addPhotoAlbum:(id)sender
{
   NSManagedObjectContext *context = [self managedObjectContext];
   PhotoAlbum *photoAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"PhotoAlbum" inManagedObjectContext:context];
   [photoAlbum setDateAdded:[NSDate date]];
   
   // Save the context.
   NSError *error = nil;
   ZAssert([context save:&error], @"Core Data save error: %@\n%@", [error localizedDescription], [error userInfo]);
}

#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController) {
      return _fetchedResultsController;
   }
   
   NSString *cacheName = NSStringFromClass([self class]);
   NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PhotoAlbum"];
   
   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

   NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:cacheName];
   [newFetchedResultsController setDelegate:self];
   
   NSError *error = nil;
   ZAssert([newFetchedResultsController performFetch:&error], @"Fetch error: %@\n%@", [error localizedDescription], [error userInfo]);
   
   [self setFetchedResultsController:newFetchedResultsController];
   return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
   [[self wheelView] reloadData];
}


#pragma mark - WheelViewDataSource and WheelViewDelegate methods

- (NSInteger)wheelViewNumberOfVisibleCells:(WheelView *)wheelView
{
   return 7;
}

- (NSInteger)wheelViewNumberOfCells:(WheelView *)wheelView
{
   NSArray *sections = [[self fetchedResultsController] sections];
   NSInteger count = [[sections objectAtIndex:0] numberOfObjects];
   return count;
}

- (WheelViewCell *)wheelView:(WheelView *)wheelView 
                 cellAtIndex:(NSInteger)index
{
   PhotoWheelViewCell *cell = [wheelView dequeueReusableCell];
   if (!cell) {
      cell = [PhotoWheelViewCell photoWheelViewCell];
   }
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoAlbum = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   Photo *photo = [[photoAlbum photos] lastObject];
   UIImage *image = [photo thumbnailImage];
   if (image == nil) {
      image = [UIImage imageNamed:@"defaultPhoto.png"];
   }
   
   [[cell imageView] setImage:image];
   [[cell label] setText:[photoAlbum name]];
   
   return cell;
}

- (void)wheelView:(WheelView *)wheelView didSelectCellAtIndex:(NSInteger)index
{
   // Retrieve the photo album from the fetched results.
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoAlbum = nil;
   // index = -1 means no selected cell and nothing to retrieve 
   // from the fetched results.
   if (index >= 0) {
      photoAlbum = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   }
   
   // Pass the current managed object context and object id for the 
   // photo album to the photo album view controller. 
   PhotosViewController *photoAlbumViewController = [self photoAlbumViewController];
   [photoAlbumViewController setManagedObjectContext:[self managedObjectContext]];
   [photoAlbumViewController setObjectID:[photoAlbum objectID]];
   [photoAlbumViewController reload];
}

@end
