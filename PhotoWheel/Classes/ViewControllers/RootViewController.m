//
//  RootViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "RootViewController.h"
#import "PhotoWheelTableViewCell.h"
#import "PhotoWheelViewController.h"
#import "PhotoWheel.h"
#import "DetailViewController.h"


#define CAROUSELS_PER_ROW 2

@interface RootViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation RootViewController

@synthesize tableView = tableView_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;

- (void)dealloc
{
   [tableView_ release], tableView_ = nil;
   [fetchedResultsController_ release], fetchedResultsController_ = nil;
   [managedObjectContext_ release], managedObjectContext_ = nil;
   [super dealloc];
}

- (id)init 
{
   self = [super initWithNibName:@"RootView" bundle:nil];
   if (self) {
      
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self setTitle:@"Photo Wheels"];
}

- (void)viewDidUnload
{
   // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
   // For example: self.myOutlet = nil;

   [self setTableView:nil];
}

- (void)didReceiveMemoryWarning
{
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   
   // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)configureCell:(PhotoWheelTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
//   NSInteger row = [indexPath row] * CAROUSELS_PER_ROW;
//   NSIndexPath *adjustedIndexPath = [NSIndexPath indexPathForRow:row inSection:[indexPath section]];

   PhotoWheel *photoWheel = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   [[cell label] setText:[photoWheel name]];
   [[cell photoWheelView] setPhotoWheel:photoWheel];
}


#pragma mark - Actions

- (IBAction)addPhotoWheel:(id)sender
{
   NSFetchedResultsController *fetchedRequestController = [self fetchedResultsController];
   NSManagedObjectContext *context = [fetchedRequestController managedObjectContext];
 
   PhotoWheel *newPhotoWheel = [PhotoWheel insertNewInManagedObjectContext:context];
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

- (IBAction)showInfoScreen:(id)sender
{
   
}


#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)fetchedResultsController
{
   if (fetchedResultsController_) {
      return fetchedResultsController_;
   }
   
   NSString *cacheName = NSStringFromClass([self class]);
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[PhotoWheel entityName] inManagedObjectContext:[self managedObjectContext]];
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
   [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
   NSLog(@"%s",__PRETTY_FUNCTION__);
   NSLog(@"indexPath.row=%i newIndexPath.row=%i", [indexPath row], [newIndexPath row]);

   UITableView *tableView = [self tableView];
   
   switch(type) 
   {
      case NSFetchedResultsChangeInsert:
         [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeDelete:
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeUpdate:
         [self configureCell:(PhotoWheelTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
         break;
         
      case NSFetchedResultsChangeMove:
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self tableView] endUpdates];
}


#pragma mark - UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   NSInteger count = [[[self fetchedResultsController] sections] count];
   return count;
}
		
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   NSInteger numberOfObjects = [[[[self fetchedResultsController] sections] objectAtIndex:section] numberOfObjects];
   return numberOfObjects;
}
		
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   PhotoWheelTableViewCell *cell = [PhotoWheelTableViewCell cellForTableView:tableView];
   [self configureCell:cell atIndexPath:indexPath];
   return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (editingStyle == UITableViewCellEditingStyleDelete)
   {
      // Delete the managed object for the given index path
      NSFetchedResultsController *fetchedResultsController = [self fetchedResultsController];
      NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
      [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
      
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   PhotoWheel *photoWheel = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   
   DetailViewController *newController = [[DetailViewController alloc] init];
   [newController setPhotoWheel:photoWheel];
   [[self navigationController] pushViewController:newController animated:YES];
   [newController release];
}


@end
