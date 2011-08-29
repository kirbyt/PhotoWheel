//
//  PhotoAlbumsViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumsViewController.h"
#import "PhotoWheelViewCell.h"
#import "PhotoAlbum.h"
#import "Photo.h"
#import "PhotoAlbumViewController.h"

@interface PhotoAlbumsViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation PhotoAlbumsViewController

@synthesize managedObjectContext = managedObjectContext_;
@synthesize wheelView = wheelView_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize photoAlbumViewController = photoAlbumViewController_;

- (void)didMoveToParentViewController:(UIViewController *)parent
{
   // Position the view within the new parent.
   [[parent view] addSubview:[self view]];
   CGRect newFrame = CGRectMake(109, 680, 551, 550);
   [[self view] setFrame:newFrame];   
   
   [[self view] setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload
{
   [self setWheelView:nil];
   [super viewDidUnload];
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
   [[self wheelView] reloadData];
}


#pragma mark - WheelViewDataSource and WheelViewDelegate Methods

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

- (WheelViewCell *)wheelView:(WheelView *)wheelView cellAtIndex:(NSInteger)index
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
   PhotoAlbumViewController *photoAlbumViewController = [self photoAlbumViewController];
   [photoAlbumViewController setManagedObjectContext:[self managedObjectContext]];
   [photoAlbumViewController setObjectID:[photoAlbum objectID]];
   [photoAlbumViewController reload];
}

@end
