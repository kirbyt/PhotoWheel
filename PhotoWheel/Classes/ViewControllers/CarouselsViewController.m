//
//  CarouselsViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "CarouselsViewController.h"
#import "KTGridView.h"
#import "PhotoAlbum.h"
#import "PhotoWheelView.h"
#import "DetailViewController.h"


@interface CarouselsViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end

@implementation CarouselsViewController

@synthesize gridView = gridView_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;


- (void)dealloc
{
   [managedObjectContext_ release], managedObjectContext_ = nil;
   [fetchedResultsController_ release], fetchedResultsController_ = nil;
   [gridView_ release], gridView_ = nil;
   [super dealloc];
}

- (id)init
{
   self = [super initWithNibName:@"CarouselsView" bundle:nil];
   if (self) {
      
   }
   return self;
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   [self setGridView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}


#pragma mark - KTGridViewDataSource Methods
- (NSInteger)ktGridViewNumberOfViews:(KTGridView *)gridView
{
   NSInteger count = [[[[self fetchedResultsController] sections] objectAtIndex:0] numberOfObjects];
   return count;
}

- (CGSize)ktGridViewCellSize:(KTGridView *)gridView
{
   return CGSizeMake(300, 200);
}

- (KTGridViewCell *)ktGridView:(KTGridView *)gridView viewAtIndex:(NSInteger)index
{
   PhotoWheelView *cell = (PhotoWheelView *)[gridView dequeueReusableView];
   if (!cell) {
      cell = [[[PhotoWheelView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)] autorelease];
      [cell setStyle:PhotoWheelStyleCarousel];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
      [cell addGestureRecognizer:tap];
      [tap release];
   }
   
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   PhotoAlbum *photoWheel = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   [cell setPhotoWheel:photoWheel];
   
   return cell;
}

- (void)cellTapped:(UITapGestureRecognizer *)recognizer
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
   PhotoAlbum *photoWheel = [[recognizer view] photoWheel];
   
   DetailViewController *newController = [[DetailViewController alloc] init];
   [newController setPhotoWheel:photoWheel];
   [[self navigationController] pushViewController:newController animated:YES];
   [newController release];
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

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//   [[self tableView] beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//   NSLog(@"%s",__PRETTY_FUNCTION__);
//   NSLog(@"indexPath.row=%i newIndexPath.row=%i", [indexPath row], [newIndexPath row]);
//
//   UITableView *tableView = [self tableView];
//   
//   switch(type) 
//   {
//      case NSFetchedResultsChangeInsert:
//         [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//         break;
//         
//      case NSFetchedResultsChangeDelete:
//         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//         break;
//         
//      case NSFetchedResultsChangeUpdate:
//         [self configureCell:(PhotoWheelTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//         break;
//         
//      case NSFetchedResultsChangeMove:
//         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//         [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
//         break;
//   }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//   [[self tableView] endUpdates];
//}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self gridView] reloadData];
}


#pragma mark - Actions

- (IBAction)showInfoScreen
{
   
}

- (IBAction)addPhotoWheel
{
   NSFetchedResultsController *fetchedRequestController = [self fetchedResultsController];
   NSManagedObjectContext *context = [fetchedRequestController managedObjectContext];
   
   PhotoAlbum *newPhotoWheel = [PhotoAlbum insertNewInManagedObjectContext:context];
   [newPhotoWheel setName:@"New Photo Wheel"];
   
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
