//
//  PhotoAlbumsViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumsViewController.h"
#import "PhotoWheelViewCell.h"                                           // 1
#import "PhotoAlbum.h"
#import "Photo.h"
#import "PhotoAlbumViewController.h"

@interface PhotoAlbumsViewController ()                                  // 2
@property (nonatomic, strong) 
   NSFetchedResultsController *fetchedResultsController;                 // 3
@end

@implementation PhotoAlbumsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize wheelView = _wheelView;                                     // 4
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize photoAlbumViewController = _photoAlbumViewController;

- (void)didMoveToParentViewController:(UIViewController *)parent        // 5
{
   // Position the view within the new parent.
   [[parent view] addSubview:[self view]];
   CGRect newFrame = CGRectMake(109, 680, 551, 550);
   [[self view] setFrame:newFrame];   
   
   [[self view] setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload                                                   // 6
{
   [self setWheelView:nil];
   [super viewDidUnload];
}

- (void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
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

- (IBAction)addPhotoAlbum:(id)sender                                    // 7
{
   NSManagedObjectContext *context = [self managedObjectContext];        // 1
   PhotoAlbum *photoAlbum = [NSEntityDescription 
                             insertNewObjectForEntityForName:@"PhotoAlbum" 
                             inManagedObjectContext:context];            // 2
   [photoAlbum setDateAdded:[NSDate date]];                              // 3
   
   // Save the context.
   NSError *error = nil;
   if (![context save:&error])                                           // 4
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. 
       You should not use this function in a shipping application, although 
       it may be useful during development. If it is not possible to recover 
       from the error, display an alert panel that instructs the user to quit 
       the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController               // 8
{
   if (_fetchedResultsController) {                                    // 9
      return _fetchedResultsController;
   }
   
   NSString *cacheName = NSStringFromClass([self class]);              // 10
   NSFetchRequest *fetchRequest = 
      [NSFetchRequest fetchRequestWithEntityName:@"PhotoAlbum"];       // 11
   
   NSSortDescriptor *sortDescriptor = 
      [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" 
                                    ascending:YES];                    // 12
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

   NSFetchedResultsController *newFetchedResultsController = 
      [[NSFetchedResultsController alloc] 
       initWithFetchRequest:fetchRequest 
       managedObjectContext:[self managedObjectContext] 
         sectionNameKeyPath:nil 
                  cacheName:cacheName];                                // 13
   [newFetchedResultsController setDelegate:self];                     // 14
   
   NSError *error = nil;
   if (![newFetchedResultsController performFetch:&error])             // 15
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. 
       You should not use this function in a shipping application, although it 
       may be useful during development. If it is not possible to recover from 
       the error, display an alert panel that instructs the user to quit the 
       application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
   
   [self setFetchedResultsController:newFetchedResultsController];     // 16
   return _fetchedResultsController;                                   // 17
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath                         // 18
{
   [[self wheelView] reloadData];
}


#pragma mark - WheelViewDataSource and WheelViewDelegate methods       // 19

- (NSInteger)wheelViewNumberOfVisibleCells:(WheelView *)wheelView      // 20
{
   return 7;
}

- (NSInteger)wheelViewNumberOfCells:(WheelView *)wheelView             // 21
{
   NSArray *sections = [[self fetchedResultsController] sections];
   NSInteger count = [[sections objectAtIndex:0] numberOfObjects];
   return count;
}

- (WheelViewCell *)wheelView:(WheelView *)wheelView 
                 cellAtIndex:(NSInteger)index                          // 22
{
   PhotoWheelViewCell *cell = [wheelView dequeueReusableCell];
   if (!cell) {
      cell = [PhotoWheelViewCell photoWheelViewCell];                   // 1
   }
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoAlbum = [[self fetchedResultsController] 
                             objectAtIndexPath:indexPath];
   Photo *photo = [[photoAlbum photos] lastObject];
   UIImage *image = [photo thumbnailImage];
   if (image == nil) {
      image = [UIImage imageNamed:@"defaultPhoto.png"];
   }
   
   [[cell imageView] setImage:image];                                  // 2
   [[cell label] setText:[photoAlbum name]];                           // 3
   
   return cell;
}

- (void)wheelView:(WheelView *)wheelView 
didSelectCellAtIndex:(NSInteger)index                                  // 30
{
   // Retrieve the photo album from the fetched results.
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index 
                                               inSection:0];           // 1
   PhotoAlbum *photoAlbum = nil;
   // index = -1 means no selected cell and nothing to retrieve 
   // from the fetched results.
   if (index >= 0) {
      photoAlbum = [[self fetchedResultsController] 
                    objectAtIndexPath:indexPath];
   }
   
   // Pass the current managed object context and object id for the 
   // photo album to the photo album view controller. 
   PhotoAlbumViewController *photoAlbumViewController = 
      [self photoAlbumViewController];
   [photoAlbumViewController 
      setManagedObjectContext:[self managedObjectContext]];            // 2
   [photoAlbumViewController setObjectID:[photoAlbum objectID]];       // 3
   [photoAlbumViewController reload];                                  // 4
}

@end
