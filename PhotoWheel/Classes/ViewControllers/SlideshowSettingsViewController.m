//
//  SlideshowSettingsViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "SlideshowSettingsViewController.h"


@implementation SlideshowSettingsViewController

@synthesize tableView = tableView_;

- (void)dealloc
{
   [tableView_ release], tableView_ = nil;
   [super dealloc];
}

- (id)init
{
   self = [super initWithNibName:@"SlideshowSettingsView" bundle:nil];
   if (self) {
      [self setContentSizeForViewInPopover:CGSizeMake(320, 200)];
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   [self setTitle:@"Slideshow Options"];
}

- (void)viewDidUnload
{
   [self setTableView:nil];
   [super viewDidUnload];
}

- (void)startSlideshow
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   UITableViewCell *cell;
   cell = [tableView dequeueReusableCellWithIdentifier:@"SlideshowCell"];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SlideshowCell"] autorelease];
   }
   
   if ([indexPath row] == 0) {
      [[cell textLabel] setText:@"Transitions"];
   } else {
      [[cell textLabel] setText:@"Play Music"];
   }
   
   return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
   UIView *newView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];

   UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   [newButton setFrame:CGRectMake(10, 2, 300, 44)];
   [newButton setTitle:@"Start Slideshow" forState:UIControlStateNormal];
   [newButton addTarget:self action:@selector(startSlideshow) forControlEvents:UIControlEventTouchUpInside];
   [newView addSubview:newButton];
   
   return newView;
}

@end
