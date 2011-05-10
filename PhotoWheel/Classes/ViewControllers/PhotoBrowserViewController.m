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
@property (nonatomic, retain) NSMutableArray *photoViewCache;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSTimer *chromeTimer;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (NSInteger)numberOfPhotos;
- (void)addButtonsToNavigatioBar;
- (void)setTitleWithCurrentPhotoIndex;
- (void)scrollToIndex:(NSInteger)index; 
- (void)setScrollViewContentSize;
- (void)initPhotoViewCache;
- (void)startChromeDisplayTimer;
- (void)cancelChromeDisplayTimer; 
- (void)hideChrome;
- (void)chromeShouldHide:(BOOL)hide;
@end

@implementation PhotoBrowserViewController

@synthesize dataSource = dataSource_;
@synthesize scrollView = scrollView_;
@synthesize photoViewCache = photoViewCache_;
@synthesize currentIndex = currentIndex_;
@synthesize startAtIndex = startAtIndex_;
@synthesize chromeTimer = chromeTimer_;

- (void)dealloc
{
   [scrollView_ release], scrollView_ = nil;
   [photoViewCache_ release], photoViewCache_ = nil;
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

   [self addButtonsToNavigatioBar];
   [self setScrollViewContentSize];
   [self initPhotoViewCache];
   
}

- (void)viewWillAppear:(BOOL)animated
{
   UINavigationBar *navBar = [[self navigationController] navigationBar];
   [navBar setBarStyle:UIBarStyleBlack];
   [navBar setTranslucent:YES];
   [[[self navigationController] navigationBar] setHidden:NO];
   
   [self setScrollViewContentSize];
   [self setCurrentIndex:[self startAtIndex]];
   [self scrollToIndex:[self startAtIndex]];
   
   [self setTitleWithCurrentPhotoIndex];
   [self startChromeDisplayTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [[[self navigationController] navigationBar] setHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

#pragma mark - Helper Methods

- (NSInteger)numberOfPhotos
{
   return [[self dataSource] photoBrowserViewControllerNumberOfPhotos:self];
}

- (void)addButtonsToNavigatioBar
{
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

- (void)setTitleWithCurrentPhotoIndex 
{
   NSString *formatString = NSLocalizedString(@"%1$i of %2$i", @"Photo X out of Y total.");
   NSString *title = [NSString stringWithFormat:formatString, [self currentIndex] + 1, [self numberOfPhotos], nil];
   [self setTitle:title];
}

- (void)scrollToIndex:(NSInteger)index 
{
   CGRect frame = [self scrollView].frame;
   frame.origin.x = frame.size.width * index;
   frame.origin.y = 0;
   [[self scrollView] scrollRectToVisible:frame animated:NO];
}

- (void)setScrollViewContentSize
{
   NSInteger pageCount = [[self dataSource] photoBrowserViewControllerNumberOfPhotos:self];
   if (pageCount == 0) {
      pageCount = 1;
   }
   
   CGSize size = CGSizeMake([self scrollView].frame.size.width * pageCount, 
                            [self scrollView].frame.size.height / 2);   // Cut in half to prevent horizontal scrolling.
   [[self scrollView] setContentSize:size];
}

- (void)initPhotoViewCache
{
   // Setup our photo view cache. We only keep 3 views in
   // memory. NSNull is used as a placeholder for the other
   // elements in the view cache array.
   NSInteger numberOfPhotos = [[self dataSource] photoBrowserViewControllerNumberOfPhotos:self];
   NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:numberOfPhotos];
   [self setPhotoViewCache:newArray];
   [newArray release];

   for (int i=0; i < numberOfPhotos; i++) {
      [[self photoViewCache] addObject:[NSNull null]];
   }
   
}

#pragma mark - Chrome Helper Methods

- (void)startChromeDisplayTimer 
{
   [self cancelChromeDisplayTimer];
   NSTimer *newTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideChrome) userInfo:nil repeats:NO];
   [self setChromeTimer:newTimer];
}

- (void)cancelChromeDisplayTimer 
{
   if ([self chromeTimer]) {
      [[self chromeTimer] invalidate];
      [self setChromeTimer:nil];
   }
}

- (void)hideChrome 
{
   if ([self chromeTimer] && [[self chromeTimer] isValid]) {
      [self cancelChromeDisplayTimer];
   }
   [self chromeShouldHide:YES];
}

- (void)chromeShouldHide:(BOOL)hide
{
   // We animate only when hiding the chrome.
   if (hide) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:0.4];
   }
   
   CGFloat alpha = hide ? 0.0 : 1.0;
   UINavigationBar *navbar = [[self navigationController] navigationBar];
   [navbar setAlpha:alpha];
   
   if (hide) {
      [UIView commitAnimations];
   }
   
   // If not hiding then start the chrome display timer.
   // The time will fade out the chrome after some period
   // of time.
   if ( ! hide ) {
      [self startChromeDisplayTimer];
   }
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
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button text.")
                                              destructiveButtonTitle:NSLocalizedString(@"Delete Photo", @"Delete Photo button text.")
                                                   otherButtonTitles:nil];
   [actionSheet showInView:[self view]];
   [actionSheet release];
}

- (void)showActionMenu:(id)sender
{
   
}

- (void)slideshow:(id)sender
{
   
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
//   if (buttonIndex == 1) {
//      [self deleteCurrentPhoto];
//   }
//   [self startChromeDisplayTimer];
}

@end
