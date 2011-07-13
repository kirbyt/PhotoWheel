//
//  RootViewController.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/15/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "RootViewController.h"

#import "DetailViewController.h"

@implementation RootViewController

@synthesize data = data_;
@synthesize detailViewController = detailViewController_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.clearsSelectionOnViewWillAppear = NO;
      self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
   }
   return self;
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
   [self setTitle:NSLocalizedString(@"Photo Albums", @"Photo albums title")];
   
   [self setData:[[NSMutableOrderedSet alloc] init]];
   [[self data] addObject:@"A Sample Photo Album"];
   [[self data] addObject:@"Another Photo Album"];

   [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];

   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
   [[self navigationItem] setRightBarButtonItem:addButton];
   
   [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];   
}

- (void)add:(id)sender
{
   NameEditorViewController *newController = [[NameEditorViewController alloc] initWithDefaultNib];
   [newController setDelegate:self];
   [newController setModalPresentationStyle:UIModalPresentationFormSheet];
   [self presentModalViewController:newController animated:YES];
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for supported orientations
   return YES;
}

#pragma mark - UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   NSInteger count = [[self data] count];
   return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      // Display the detail disclosure button when the table is in edit mode.
      // This is the line you must add:
      [cell setEditingAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
      
      [cell setShowsReorderControl:YES];
   }
   
   // Configure the cell.
   NSString *text = [[self data] objectAtIndex:[indexPath row]];
   [[cell textLabel] setText:text];
   
   return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
   NameEditorViewController *newController = [[NameEditorViewController alloc] initWithDefaultNib];
   [newController setDelegate:self];
   [newController setEditing:YES];
   [newController setIndexPath:indexPath];
   NSString *name = [[self data] objectAtIndex:[indexPath row]];
   [newController setDefaultNameText:name];
   [newController setModalPresentationStyle:UIModalPresentationFormSheet];
   [self presentModalViewController:newController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (editingStyle == UITableViewCellEditingStyleDelete) {
      [[self data] removeObjectAtIndex:[indexPath row]];
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
   }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
   [[self data] exchangeObjectAtIndex:[fromIndexPath row] withObjectAtIndex:[toIndexPath row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSString *name = [[self data] objectAtIndex:[indexPath row]];
   [[self detailViewController] setDetailItem:name];
}

#pragma mark - NameEditorViewControllerDelegate

- (void)nameEditorViewControllerDidFinish:(NameEditorViewController *)controller
{
   NSString *newName = [[controller nameTextField] text];
   if (newName && [newName length] > 0) {
      if ([controller isEditing]) {
         [[self data] replaceObjectAtIndex:[[controller indexPath] row] withObject:newName];
      } else {
         [[self data] addObject:newName];
      }
      [[self tableView] reloadData];
   }
}


@end
