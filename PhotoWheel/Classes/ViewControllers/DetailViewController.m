//
//  DetailViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "PhotoWheelViewController.h"
#import "UIViewController+KTCompositeView.h"


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) PhotoWheelViewController *photoWheelViewController;
@end


@implementation DetailViewController

@synthesize toolbar=toolbar_;
@synthesize popoverController=popoverController_;
@synthesize photoWheelViewController = photoWheelViewController_;
@synthesize photoWheelPlaceholderView = photoWheelPlaceholderView_;

- (void)dealloc
{
   [popoverController_ release];
   [toolbar_ release];
   [photoWheelViewController_ release];
   [photoWheelPlaceholderView_ release];
   
   [super dealloc];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   PhotoWheelViewController *newController = [[PhotoWheelViewController alloc] init];
   [self setPhotoWheelViewController:newController];
   [newController release];

   [self addSubview:[[self photoWheelViewController] view] toPlaceholder:[self photoWheelPlaceholderView]];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];

   // Forward the message to our "sub" view controller.
   [[self photoWheelViewController] viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
   return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   [[self photoWheelViewController] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   [[self photoWheelViewController] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
   
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
   [self setToolbar:nil];
   [self setPopoverController:nil];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


#pragma -
#pragma mark Split view support

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
   barButtonItem.title = @"Photo Wheels";
   NSMutableArray *items = [[[self toolbar] items] mutableCopy];
   [items insertObject:barButtonItem atIndex:0];
   [[self toolbar] setItems:items animated:YES];
   [items release];
   [self setPopoverController:pc];
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
   NSMutableArray *items = [[[self toolbar] items] mutableCopy];
   [items removeObjectAtIndex:0];
   [[self toolbar] setItems:items animated:YES];
   [items release];
   [self setPopoverController:nil];
}


#pragma -
#pragma Actions

- (IBAction)pickImage:(id)sender 
{
}

@end
