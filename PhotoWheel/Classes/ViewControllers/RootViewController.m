//
//  RootViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "NameEditorViewController.h"
#import "PhotoWheel.h"


@interface RootViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end


@implementation RootViewController
		
@synthesize detailViewController = detailViewController_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;

- (void)dealloc
{
   [detailViewController_ release], detailViewController_ = nil;
   [fetchedResultsController_ release], fetchedResultsController_ = nil;
   [super dealloc];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self setClearsSelectionOnViewWillAppear:NO];
   [self setContentSizeForViewInPopover:CGSizeMake(320.0, 600.0)];
   
   UIColor *aColor = [UIColor colorWithRed:0.824 green:0.841 blue:0.876 alpha:1.000];
   [[self tableView] setBackgroundColor:aColor];
   [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
   
   [self setTitle:@"Photo Wheels"];
   
   [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
}

- (void)viewDidUnload
{
   // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
   // For example: self.myOutlet = nil;
   
   [self setDetailViewController:nil];
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
   [super setEditing:editing animated:animated];
   [[[self navigationItem] rightBarButtonItem] setEnabled:!editing];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   PhotoWheel *photoWheel = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   [[cell textLabel] setText:[photoWheel name]];
}

#pragma mark - Actions

- (IBAction)addPhotoWheel:(id)sender
{
   NameEditorViewController *newViewController = [[NameEditorViewController alloc] init];
   [newViewController setDelegate:self];
   [[self navigationController] pushViewController:newViewController animated:YES];
   [newViewController release];
}


#pragma mark - NameEditorViewControllerDelegate

- (void)nameEditorDidSave:(NameEditorViewController *)nameEditorViewController
{
   NSString *name = [nameEditorViewController name];
   if ([name isEqualToString:@""]) return;   // Ignore blank names.

   NSFetchedResultsController *fetchedRequestController = [self fetchedResultsController];
   NSManagedObjectContext *context = [fetchedRequestController managedObjectContext];
   
   if ([nameEditorViewController isEditing]) {
      NSIndexPath *indexPath = [nameEditorViewController editingAtIndexPath];
      PhotoWheel *photoWheel = [[self fetchedResultsController] objectAtIndexPath:indexPath];
      [photoWheel setName:name];

   } else {
      NSEntityDescription *entity = [[fetchedRequestController fetchRequest] entity];
      PhotoWheel *newPhotoWheel = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
      [newPhotoWheel setName:name];
      
   }

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

   [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)fetchedResultsController
{
   if (fetchedResultsController_) {
      return fetchedResultsController_;
   }
   
   NSString *cacheName = NSStringFromClass([self class]);
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kPhotoWheelTablePhotoWheel inManagedObjectContext:[self managedObjectContext]];
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
         [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
   NSInteger count = [[[[self fetchedResultsController] sections] objectAtIndex:section] numberOfObjects];
   return count;
}
		
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoWheelCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
       [cell setShowsReorderControl:YES];
       [cell setEditingAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }

   [self configureCell:cell atIndexPath:indexPath];
   return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
   return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here -- for example, create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
   PhotoWheel *photoWheel = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   
   NameEditorViewController *newViewController = [[NameEditorViewController alloc] init];
   [newViewController setDelegate:self];
   [newViewController setEditing:YES];
   [newViewController setEditingAtIndexPath:indexPath];
   [newViewController setName:[photoWheel name]];
   [[self navigationController] pushViewController:newViewController animated:YES];
   [newViewController release];
}

@end
