//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/7/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "CustomToolbar.h"

@interface PhotoBrowserViewController ()
@property (nonatomic, retain) UIScrollView *scrollView;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
@end

@implementation PhotoBrowserViewController

@synthesize scrollView = scrollView_;

- (void)dealloc
{
   [scrollView_ release], scrollView_ = nil;
   [super dealloc];
}

- (void)loadView
{
   [super loadView]; // Creates a top-level UIView for us.
   
   CGRect scrollViewFrame = [self frameForPagingScrollView];
   UIScrollView *newScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
   [newScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   [newScrollView setDelegate:self];
   [newScrollView setBackgroundColor:[UIColor blackColor]];
   [newScrollView setAutoresizesSubviews:YES];
   [newScrollView setPagingEnabled:YES];
   [newScrollView setShowsVerticalScrollIndicator:NO];
   [newScrollView setShowsHorizontalScrollIndicator:NO];
   [self setScrollView:newScrollView];
   [newScrollView release];
   
   [[self view] addSubview:[self scrollView]];
   
}

- (void)viewDidLoad
{
   [super viewDidLoad];

   // Add buttons to the navigation bar. The nav bar allows
   // one button on the left and one on the right. Optionally
   // a custom view can be used instead of a button. To get
   // multiple buttons we must create a short toolbar containing
   // the buttons we want.
   
   UIBarButtonItem *trashButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto:)] autorelease];
   [trashButton setStyle:UIBarButtonItemStyleBordered];
   
   UIBarButtonItem *actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionMenu:)] autorelease];
   [actionButton setStyle:UIBarButtonItemStyleBordered];
   
   UIBarButtonItem *slideshowButton = [[[UIBarButtonItem alloc] initWithTitle:@"Slideshow" style:UIBarButtonItemStyleBordered target:self action:@selector(slideshow:)] autorelease];

   UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
   
   
   NSMutableArray *toolbarItems = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
   [toolbarItems addObject:flexibleSpace];
   [toolbarItems addObject:slideshowButton];
   [toolbarItems addObject:actionButton];
   [toolbarItems addObject:trashButton];
   
   UIToolbar *toolbar = [[[CustomToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)] autorelease];
   [toolbar setBackgroundColor:[UIColor clearColor]];
   [toolbar setBarStyle:UIBarStyleBlack];
   [toolbar setTranslucent:YES];
   
   [toolbar setItems:toolbarItems];

   UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
   [[self navigationItem] setRightBarButtonItem:customBarButtonItem animated:YES];
   [customBarButtonItem release];
}

- (void)viewWillAppear:(BOOL)animated
{
   UINavigationBar *navBar = [[self navigationController] navigationBar];
   [navBar setBarStyle:UIBarStyleBlack];
   [navBar setTranslucent:YES];
   [[[self navigationController] navigationBar] setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [[[self navigationController] navigationBar] setHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

#pragma mark - Frame Size Calculations

#define PADDING  20

- (CGRect)frameForPagingScrollView 
{
   CGRect frame = [[UIScreen mainScreen] bounds];
   frame.origin.x -= PADDING;
   frame.size.width += (2 * PADDING);
   return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index 
{
   // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
   // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
   // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
   // because it has a rotation transform applied.
   CGRect bounds = [scrollView_ bounds];
   CGRect pageFrame = bounds;
   pageFrame.size.width -= (2 * PADDING);
   pageFrame.origin.x = (bounds.size.width * index) + PADDING;
   return pageFrame;
}

#pragma mark - Actions

- (void)deletePhoto:(id)sender
{
   
}

- (void)showActionMenu:(id)sender
{
   
}

- (void)slideshow:(id)sender
{
   
}

@end
