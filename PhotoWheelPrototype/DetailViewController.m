//
//  DetailViewController.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "PhotoWheelViewCell.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray *data;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize data = _data;
@synthesize wheelView = _wheelView;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
   if (_detailItem != newDetailItem) {
      _detailItem = newDetailItem;
      
      // Update the view.
      [self configureView];
   }
   
   if (self.masterPopoverController != nil) {
      [self.masterPopoverController dismissPopoverAnimated:YES];
   }        
}

- (void)configureView
{
   // Update the user interface for the detail item.
   
   if (self.detailItem) {
      self.detailDescriptionLabel.text = [self.detailItem description];
   }
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
   
   UIImage *defaultPhoto = [UIImage imageNamed:@"defaultPhoto.png"];
   CGRect cellFrame = CGRectMake(0, 0, 75, 75);
   NSInteger count = 10;
   NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:count];
   for (NSInteger index = 0; index < count; index++) {
      PhotoWheelViewCell *cell = 
      [[PhotoWheelViewCell alloc] initWithFrame:cellFrame];      
      [cell setImage:defaultPhoto];
      
      // Add a double-tap gesture to the cell.
      UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] 
                                           initWithTarget:self 
                                           action:@selector(cellDoubleTapped:)];      
      [doubleTap setNumberOfTapsRequired:2];
      [cell addGestureRecognizer:doubleTap];
      
      // Add a single-tap gesture to the cell.
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                     initWithTarget:self 
                                     action:@selector(cellTapped:)];      
      [tap requireGestureRecognizerToFail:doubleTap];
      [cell addGestureRecognizer:tap];
      
      [newArray addObject:cell];
   }
   [self setData:[newArray copy]];
   
   NSArray *segmentedItems = [NSArray arrayWithObjects:
                              @"Wheel", @"Carousel", nil];
   UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] 
                                           initWithItems:segmentedItems];
   [segmentedControl addTarget:self 
                        action:@selector(segmentedControlValueChanged:) 
              forControlEvents:UIControlEventValueChanged];
   [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
   [segmentedControl setSelectedSegmentIndex:0];
   [[self navigationItem] setTitleView:segmentedControl];
}

- (void)segmentedControlValueChanged:(id)sender
{
   NSInteger index = [sender selectedSegmentIndex];
   if (index == 0) {
      [[self wheelView] setStyle:WheelViewStyleWheel];
   } else {
      [[self wheelView] setStyle:WheelViewStyleCarousel];
   }
   
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      self.title = NSLocalizedString(@"Detail", @"Detail");
   }
   return self;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
   barButtonItem.title = NSLocalizedString(@"Photo Albums", @"Photo albums title");
   [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
   self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
   // Called when the view is shown again in the split view, invalidating 
   // the button and popover controller.
   [self.navigationItem setLeftBarButtonItem:nil animated:YES];
   self.masterPopoverController = nil;
}

#pragma mark - WheelViewDataSource Methods

- (NSInteger)wheelViewNumberOfCells:(WheelView *)wheelView
{
   NSInteger count = [[self data] count];
   return count;
}

- (WheelViewCell *)wheelView:(WheelView *)wheelView cellAtIndex:(NSInteger)index
{
   WheelViewCell *cell = [[self data] objectAtIndex:index];
   return cell;
}

// Other code left out for brevity's sake.

- (void)cellTapped:(UIGestureRecognizer *)recognizer
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cellDoubleTapped:(UIGestureRecognizer *)recognizer
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
