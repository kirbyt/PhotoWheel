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
#import "PhotoWheel.h"
#import "Nub.h"


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) PhotoWheelViewController *photoWheelViewController;
@property (nonatomic, retain) UINavigationController *photoNavigationController;
@end


@implementation DetailViewController

@synthesize toolbar=toolbar_;
@synthesize popoverController=popoverController_;
@synthesize photoWheelViewController = photoWheelViewController_;
@synthesize photoWheelPlaceholderView = photoWheelPlaceholderView_;
@synthesize segmentedControl = segmentedControl_;
@synthesize photoNavigationController = photoNavigationController_;
@synthesize photoWheel = photoWheel_;

- (void)dealloc
{
   [popoverController_ release], popoverController_ = nil;
   [toolbar_ release], toolbar_ = nil;
   [photoWheelViewController_ release], photoWheelViewController_ = nil;
   [photoWheelPlaceholderView_ release], photoWheelPlaceholderView_ = nil;
   [segmentedControl_ release], segmentedControl_ = nil;
   [photoNavigationController_ release], photoNavigationController_ = nil;
   [photoWheel_ release], photoWheel_ = nil;
   
   [super dealloc];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   PhotoWheelViewController *newController = [[PhotoWheelViewController alloc] init];
   [newController setStyle:PhotoWheelStyleWheel];
   [self setPhotoWheelViewController:newController];
   [newController release];
   
   UINavigationController *newNavController = [[UINavigationController alloc] initWithRootViewController:[self photoWheelViewController]];
   [newNavController setNavigationBarHidden:YES];
   [self setPhotoNavigationController:newNavController];
   [newNavController release];
   
   [self kt_addSubview:[[self photoNavigationController] view] toPlaceholder:[self photoWheelPlaceholderView]];
   
   [[self segmentedControl] addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   [[self photoNavigationController] viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   [[self photoNavigationController] viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
   return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   [[self photoNavigationController] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   [[self photoNavigationController] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
   
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
   [self setToolbar:nil];
   [self setPopoverController:nil];
   [self setSegmentedControl:nil];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


#pragma mark - Split view support

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


#pragma mark - Actions

- (IBAction)pickImage:(id)sender 
{
}

- (void)segmentedControlChanged:(id)sender
{
   NSInteger index = [[self segmentedControl] selectedSegmentIndex];
   if (index == 0) {
      [[self photoWheelViewController] setStyle:PhotoWheelStyleWheel];
   } else {
      [[self photoWheelViewController] setStyle:PhotoWheelStyleCarousel];
   }
}

@end
