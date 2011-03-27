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


@interface RootViewController ()
@property (nonatomic, retain) NSMutableArray *data;
@end

@implementation RootViewController
		
@synthesize detailViewController = detailViewController_;
@synthesize data = data_;

- (void)dealloc
{
   [data_ release];
   [detailViewController_ release];
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
   
   NSMutableArray *newData = [[NSMutableArray alloc] init];
   [newData addObject:@"First photo wheel"];
   [newData addObject:@"Second photo wheel"];
   [self setData:newData];
   [newData release];
   
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

#pragma -
#pragma Actions

- (IBAction)addPhotoWheel:(id)sender
{
   NameEditorViewController *newViewController = [[NameEditorViewController alloc] init];
   [newViewController setDelegate:self];
   [[self navigationController] pushViewController:newViewController animated:YES];
   [newViewController release];
}


#pragma -
#pragma NameEditorViewControllerDelegate

- (void)nameEditorDidSave:(NameEditorViewController *)nameEditorViewController
{
   [[self data] addObject:[nameEditorViewController photoWheelName]];
   [[self tableView] reloadData];
   [[self navigationController] popViewControllerAnimated:YES];
}


#pragma -
#pragma UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}
		
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   NSInteger count = [[self data] count];
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

   // Configure the cell.
   [[cell textLabel] setText:[[self data] objectAtIndex:[indexPath row]]];
   		
   return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (editingStyle == UITableViewCellEditingStyleDelete) {
      // Delete the row from the data source.
      [[self data] removeObjectAtIndex:[indexPath row]];
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
   }   
   else if (editingStyle == UITableViewCellEditingStyleInsert) {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
   }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
   return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
   // We must retain the string because it is released by NSArray when removed.
   NSString *stringToMove = [[[self data] objectAtIndex:[fromIndexPath row]] retain];

   // This releases the string owned by the array. If we had not retained 
   // in the previous line then stringToMove would be pointing to an
   // invalid object.
   [[self data] removeObjectAtIndex:[fromIndexPath row]];
   
   // Add the string back to the array but at a new location.
   [[self data] insertObject:stringToMove atIndex:[toIndexPath row]];

   // Release the string retained at the beginning.
   [stringToMove release];
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
   
}

@end
