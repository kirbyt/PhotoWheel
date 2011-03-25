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
@property (nonatomic, retain) NameEditorViewController *nameEditorViewController;
@property (nonatomic, retain) UIPopoverController *nameEditorPopoverController;
@end

@implementation RootViewController
		
@synthesize detailViewController = detailViewController_;
@synthesize nameEditorViewController = nameEditorViewController_;
@synthesize nameEditorPopoverController = nameEditorPopoverController_;
@synthesize data = data_;

- (void)dealloc
{
   [data_ release];
   [detailViewController_ release];
   [nameEditorPopoverController_ release];
   [nameEditorPopoverController_ release];
   [super dealloc];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self setClearsSelectionOnViewWillAppear:NO];
   [self setContentSizeForViewInPopover:CGSizeMake(320.0, 600.0)];
   
   [self setTitle:@"Photo Wheels"];
   
   NSMutableArray *newData = [[NSMutableArray alloc] init];
   [newData addObject:@"First photo wheel"];
   [newData addObject:@"Second photo wheel"];
   [self setData:newData];
   [newData release];
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


#pragma -
#pragma Actions

- (IBAction)addPhotoWheel:(id)sender
{
   NameEditorViewController *newViewController = [[NameEditorViewController alloc] init];
   [newViewController setDelegate:self];
   [self setNameEditorViewController:newViewController];
   [newViewController release];
   
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:[self nameEditorViewController]];
   [newPopover setDelegate:self];
   [self setNameEditorPopoverController:newPopover];
   [newPopover release];
   
   [[self nameEditorPopoverController] presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma -
#pragma UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
   [self setNameEditorPopoverController:nil];
   [self setNameEditorViewController:nil];
}


#pragma -
#pragma NameEditorViewControllerDelegate

- (void)nameEditorDidSaveWithName:(NSString *)name
{
   [[self data] addObject:name];
   [[self tableView] reloadData];
   [[self nameEditorPopoverController] dismissPopoverAnimated:YES];
}

- (void)nameEditorDidCancel
{
   [[self nameEditorPopoverController] dismissPopoverAnimated:YES];
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
    }

   // Configure the cell.
   [[cell textLabel] setText:[[self data] objectAtIndex:[indexPath row]]];
   		
   return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

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


@end
