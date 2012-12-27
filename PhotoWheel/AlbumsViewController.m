//
//  AlbumsViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/12/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "AlbumsViewController.h"
#import "PhotoWheelViewCell.h"                                          
#import "PhotoAlbum.h"
#import "Photo.h"

@interface AlbumsViewController ()
@property (nonatomic, strong)
NSFetchedResultsController *fetchedResultsController;
@end

@implementation AlbumsViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloudUpdate:) name:kRefetchAllDataNotification object:[[UIApplication sharedApplication] delegate]];
}

- (void)handleCloudUpdate:(NSNotification *)notification
{
   [self setFetchedResultsController:nil];
   [[self wheelView] reloadData];
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self name:kRefetchAllDataNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   [self rotateToInterfaceOrientation:[self interfaceOrientation]];
}

#pragma mark - Actions

- (IBAction)addPhotoAlbum:(id)sender
{
   NSManagedObjectContext *context = [self managedObjectContext];
   PhotoAlbum *photoAlbum;
   photoAlbum = [NSEntityDescription
     insertNewObjectForEntityForName:@"PhotoAlbum"
     inManagedObjectContext:context];
   [photoAlbum setDateAdded:[NSDate date]];  
   
   // Save the context.
   NSError *error = nil;
   if (![context save:&error])          
   {
      // Replace this implementation with code to handle
      // the error appropriately.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController) {                                     
      return _fetchedResultsController;
   }
   
   NSString *cacheName = NSStringFromClass([self class]);
   NSFetchRequest *fetchRequest =
   [NSFetchRequest fetchRequestWithEntityName:@"PhotoAlbum"];
   
   NSSortDescriptor *sortDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"dateAdded"
                                    ascending:YES];
   [fetchRequest setSortDescriptors:@[sortDescriptor]];
   
   NSFetchedResultsController *newFetchedResultsController;
   newFetchedResultsController = [[NSFetchedResultsController alloc]
       initWithFetchRequest:fetchRequest
       managedObjectContext:[self managedObjectContext]
       sectionNameKeyPath:nil
       cacheName:cacheName];
   [newFetchedResultsController setDelegate:self];
   
   NSError *error = nil;
   if (![newFetchedResultsController performFetch:&error])
   {
      // Replace this implementation with code to handle the
      // error appropriately.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
   
   [self setFetchedResultsController:newFetchedResultsController];
   return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
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
   
   NSIndexPath *indexPath;
   indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   NSFetchedResultsController *frc = [self fetchedResultsController];
   PhotoAlbum *photoAlbum = [frc objectAtIndexPath:indexPath];
   Photo *photo = [[photoAlbum photos] lastObject];
   UIImage *image = [photo thumbnailImage];
   if (image == nil) {
      image = [UIImage imageNamed:@"defaultPhoto.png"];
   }
   
   [[cell imageView] setImage:image];
   [[cell label] setText:[photoAlbum name]];
   
   return cell;
}

- (void)wheelView:(WheelView *)wheelView
didSelectCellAtIndex:(NSInteger)index
{
   NSDictionary *userInfo = nil;

   // index = -1 means no selected cell and nothing to retrieve
   // from the fetched results.
   if (index >= 0) {
      NSIndexPath *indexPath = nil;
      indexPath = [NSIndexPath indexPathForRow:index inSection:0];

      NSFetchedResultsController *frc = [self fetchedResultsController];
      PhotoAlbum *photoAlbum = [frc objectAtIndexPath:indexPath];
      userInfo = @{ @"PhotoAlbum":photoAlbum };
   }

   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc postNotificationName:kPhotoWheelDidSelectAlbum
                     object:nil
                   userInfo:userInfo];
}

#pragma mark - Rotation

- (void)rotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
{
   CGFloat angleOffset;
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      angleOffset = 270.0;
   } else {
      angleOffset = 0.0;
   }
   [[self wheelView] setAngleOffset:angleOffset];
}

- (void)willRotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
   [self rotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
