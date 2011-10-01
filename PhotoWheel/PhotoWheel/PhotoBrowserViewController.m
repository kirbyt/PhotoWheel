//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/1/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoBrowserPhotoView.h"
#import "ClearToolbar.h"

#define ACTIONSHEET_TAG_DELETE 1
#define ACTIONSHEET_TAG_ACTIONS 2

@interface PhotoBrowserViewController ()
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *photoViewCache;
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, assign) NSInteger firstVisiblePageIndexBeforeRotation; // 1
@property (nonatomic, assign) NSInteger percentScrolledIntoFirstVisiblePage; // 2

- (void)initPhotoViewCache;
- (void)setScrollViewContentSize;
- (void)scrollToIndex:(NSInteger)index;
- (void)setTitleWithCurrentIndex;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (void)addButtonsToNavigationBar;

@end

@implementation PhotoBrowserViewController

@synthesize scrollView = _scrollView;
@synthesize delegate = _delegate;
@synthesize startAtIndex = _startAtIndex;
@synthesize currentIndex = _currentIndex;
@synthesize photoViewCache = _photoViewCache;
@synthesize chromeHidden = _chromeHidden;
@synthesize chromeHideTimer = _chromeHideTimer;
@synthesize statusBarHeight = _statusBarHeight;
@synthesize actionButton = _actionButton;
@synthesize firstVisiblePageIndexBeforeRotation = _firstVisiblePageIndexBeforeRotation;   // 3
@synthesize percentScrolledIntoFirstVisiblePage = _percentScrolledIntoFirstVisiblePage;   // 4

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // Make sure to set wantsFullScreenLayout or the photo
   // will not display behind the status bar.
   [self setWantsFullScreenLayout:YES];
   
   // Set the view's frame size. This ensures that the scroll view
   // autoresizes correctly and avoids surprises when retrieving
   // the scroll view's bounds later.
   CGRect frame = [[UIScreen mainScreen] bounds];
   [[self view] setFrame:frame];
   
   UIScrollView *scrollView = [self scrollView];
   // Set the initial size.
   [scrollView setFrame:[self frameForPagingScrollView]];
   [scrollView setDelegate:self];
   [scrollView setBackgroundColor:[UIColor blackColor]];
   [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | 
    UIViewAutoresizingFlexibleHeight];
   [scrollView setAutoresizesSubviews:YES];
   [scrollView setPagingEnabled:YES];
   [scrollView setShowsVerticalScrollIndicator:NO];
   [scrollView setShowsHorizontalScrollIndicator:NO];
   
   [self addButtonsToNavigationBar];
   [self initPhotoViewCache];

   // Must store the status bar size while it is still visible.
   CGRect statusBarFrame = [[UIApplication sharedApplication] 
                            statusBarFrame];
   if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
      [self setStatusBarHeight:statusBarFrame.size.width];
   } else {
      [self setStatusBarHeight:statusBarFrame.size.height];
   }
}

- (void)viewDidUnload
{
   [self setScrollView:nil];
   [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   [self setScrollViewContentSize];
   [self setCurrentIndex:[self startAtIndex]];
   [self scrollToIndex:[self startAtIndex]];
   [self setTitleWithCurrentIndex];
   
   [self startChromeDisplayTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self cancelChromeDisplayTimer];
   [super viewWillDisappear:animated];
}

#pragma mark - Delegate callback helpers

- (NSInteger)numberOfPhotos
{
   NSInteger numberOfPhotos = 0;
   id<PhotoBrowserViewControllerDelegate> delegate = [self delegate];
   if (delegate && [delegate respondsToSelector:
                    @selector(photoBrowserViewControllerNumberOfPhotos:)]) 
   {
      numberOfPhotos = [delegate photoBrowserViewControllerNumberOfPhotos:self];
   }
   return numberOfPhotos;
}

- (UIImage*)imageAtIndex:(NSInteger)index
{
   UIImage *image = nil;
   id<PhotoBrowserViewControllerDelegate> delegate = [self delegate];
   if (delegate && [delegate respondsToSelector:
                    @selector(photoBrowserViewController:imageAtIndex:)]) 
   {
      image = [delegate photoBrowserViewController:self imageAtIndex:index];
   }
   return image;
}

#pragma mark - Helper methods

- (void)addButtonsToNavigationBar
{
   // Add buttons to the navigation bar. The nav bar allows
   // one button on the left and one on the right. Optionally,
   // a custom view can be used instead of a button. To get
   // multiple buttons we must create a short toolbar containing
   // the buttons we want.
   
   UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] 
                       initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                       target:self 
                       action:@selector(deletePhoto:)];
   [trashButton setStyle:UIBarButtonItemStyleBordered];
   
   UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] 
                        initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                        target:self 
                        action:@selector(showActionMenu:)];
   [actionButton setStyle:UIBarButtonItemStyleBordered];
   [self setActionButton:actionButton];
   
   UIBarButtonItem *slideshowButton = [[UIBarButtonItem alloc] 
                                       initWithTitle:@"Slideshow" 
                                       style:UIBarButtonItemStyleBordered 
                                       target:self 
                                       action:@selector(slideshow:)];
   
   UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] 
                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                target:nil 
                action:nil];
   
   
   NSMutableArray *toolbarItems = [[NSMutableArray alloc] initWithCapacity:3];
   [toolbarItems addObject:flexibleSpace];
   [toolbarItems addObject:slideshowButton];
   [toolbarItems addObject:actionButton];
   [toolbarItems addObject:trashButton];
   
   UIToolbar *toolbar = [[ClearToolbar alloc] 
                         initWithFrame:CGRectMake(0, 0, 200, 44)];
   [toolbar setBackgroundColor:[UIColor clearColor]];
   [toolbar setBarStyle:UIBarStyleBlack];
   [toolbar setTranslucent:YES];
   
   [toolbar setItems:toolbarItems];
   
   UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc] 
                                           initWithCustomView:toolbar];
   [[self navigationItem] setRightBarButtonItem:customBarButtonItem 
                                       animated:YES];
}

- (void)initPhotoViewCache
{
   // Set up the photo's view cache. We keep only three views in
   // memory. NSNull is used as a placeholder for the other
   // elements in the view cache array.
   
   NSInteger numberOfPhotos = [self numberOfPhotos];;
   [self setPhotoViewCache:
    [[NSMutableArray alloc] initWithCapacity:numberOfPhotos]];
   for (int i=0; i < numberOfPhotos; i++) {
      [self.photoViewCache addObject:[NSNull null]];
   }
}

- (void)setScrollViewContentSize
{
   NSInteger pageCount = [self numberOfPhotos];
   if (pageCount == 0) {
      pageCount = 1;
   }
   
   CGRect bounds = [[self scrollView] bounds];
   CGSize size = CGSizeMake(bounds.size.width * pageCount, 
                            // Divide in half to prevent horizontal
                            // scrolling.
                            bounds.size.height / 2);
   [[self scrollView] setContentSize:size];
}

- (void)scrollToIndex:(NSInteger)index
{
   CGRect bounds = [[self scrollView] bounds];
   bounds.origin.x = bounds.size.width * index;
   bounds.origin.y = 0;
   [[self scrollView] scrollRectToVisible:bounds animated:NO];
}

- (void)setTitleWithCurrentIndex
{
   NSInteger index = [self currentIndex] + 1;
   if (index < 1) {
      // Prevents the title from showing 0 of n when the user
      // attempts to scroll the first page to the right.
      index = 1;
   }
   NSInteger count = [self numberOfPhotos];
   NSString *title = title = [NSString stringWithFormat:@"%1$i of %2$i", 
                              index, count, nil];
   [self setTitle:title];
}

#pragma mark - Frame calculations
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
   CGRect bounds = [[self scrollView] bounds];
   CGRect pageFrame = bounds;
   pageFrame.size.width -= (2 * PADDING);
   pageFrame.origin.x = (bounds.size.width * index) + PADDING;
   return pageFrame;
}

#pragma mark - Page management

- (void)loadPage:(NSInteger)index
{
   if (index < 0 || index >= [self numberOfPhotos]) {
      return;
   }
   
   id currentView = [[self photoViewCache] objectAtIndex:index];
   if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]] == NO) {
      // Load the photo view.
      CGRect frame = [self frameForPageAtIndex:index];
      PhotoBrowserPhotoView *newView = [[PhotoBrowserPhotoView alloc] 
                                        initWithFrame:frame];
      [newView setBackgroundColor:[UIColor clearColor]];
      [newView setImage:[self imageAtIndex:index]];
      [newView setPhotoBrowserViewController:self];
      [newView setIndex:index];
      
      [[self scrollView] addSubview:newView];
      [[self photoViewCache] replaceObjectAtIndex:index withObject:newView];
   } else {
      [currentView turnOffZoom];
   }
}

- (void)unloadPage:(NSInteger)index
{
   if (index < 0 || index >= [self numberOfPhotos]) {
      return;
   }
   
   id currentView = [[self photoViewCache] objectAtIndex:index];
   if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]]) {
      [currentView removeFromSuperview];
      [[self photoViewCache] replaceObjectAtIndex:index withObject:[NSNull null]];
   }
}

- (void)setCurrentIndex:(NSInteger)newIndex
{
   _currentIndex = newIndex;
   
   [self loadPage:_currentIndex];
   [self loadPage:_currentIndex + 1];
   [self loadPage:_currentIndex - 1];
   [self unloadPage:_currentIndex + 2];
   [self unloadPage:_currentIndex - 2];
   
   [self setTitleWithCurrentIndex];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   if ([scrollView isScrollEnabled]) {
      CGFloat pageWidth = scrollView.bounds.size.width;
      float fractionalPage = scrollView.contentOffset.x / pageWidth;
      NSInteger page = floor(fractionalPage);
      if (page != [self currentIndex]) {
         [self setCurrentIndex:page];
      }
   }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   [self hideChrome];
}

#pragma mark - Chrome helpers

- (void)toggleChromeDisplay
{
   [self toggleChrome:![self isChromeHidden]];
}

- (void)toggleChrome:(BOOL)hide
{
   [self setChromeHidden:hide];
   if (hide) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:0.4];
   }
   
   CGFloat alpha = hide ? 0.0 : 1.0;
   
   UINavigationBar *navbar = [[self navigationController] navigationBar];
   [navbar setAlpha:alpha];
   
   [[UIApplication sharedApplication] setStatusBarHidden:hide];
   
   if (hide) {
      [UIView commitAnimations];
   }
   
   if ( ! [self isChromeHidden] ) {
      [self startChromeDisplayTimer];
   }
}

- (void)hideChrome
{
   NSTimer *timer = [self chromeHideTimer];
   if (timer && [timer isValid]) {
      [timer invalidate];
      [self setChromeHideTimer:nil];
   }
   [self toggleChrome:YES];
}

- (void)startChromeDisplayTimer
{
   [self cancelChromeDisplayTimer];
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 
                                                     target:self 
                                                   selector:@selector(hideChrome) 
                                                   userInfo:nil 
                                                    repeats:NO];
   [self setChromeHideTimer:timer];
}

- (void)cancelChromeDisplayTimer
{
   if ([self chromeHideTimer]) {
      [[self chromeHideTimer] invalidate];
      [self setChromeHideTimer:nil];
   }
}

#pragma mark - Gesture handlers

- (void)imageTapped:(UITapGestureRecognizer *)recognizer
{
   [self toggleChromeDisplay];
}

#pragma mark - Actions

- (void)deletePhotoConfirmed
{
   id<PhotoBrowserViewControllerDelegate> delegate = [self delegate];
   if (delegate && [delegate respondsToSelector:
                    @selector(photoBrowserViewController:deleteImageAtIndex:)]) 
   {
      NSInteger count = [self numberOfPhotos];
      NSInteger indexToDelete = [self currentIndex];
      [self unloadPage:indexToDelete];
      [delegate photoBrowserViewController:self deleteImageAtIndex:indexToDelete];
      
      if (count == 1) {
         // The one and only photo was deleted. Pop back to
         // the previous view controller.
         [[self navigationController] popViewControllerAnimated:YES];
      } else {
         NSInteger nextIndex = indexToDelete;
         if (indexToDelete == count) {
            nextIndex -= 1;
         }
         [self setCurrentIndex:nextIndex];
         [self setScrollViewContentSize];
      }
   }
}

- (void)deletePhoto:(id)sender
{
   [self cancelChromeDisplayTimer];
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                            delegate:self 
                                                   cancelButtonTitle:nil 
                                              destructiveButtonTitle:@"Delete Photo"
                                                   otherButtonTitles:nil, nil];
   [actionSheet setTag:ACTIONSHEET_TAG_DELETE];
   [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)showActionMenu:(id)sender
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)slideshow:(id)sender
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet 
clickedButtonAtIndex:(NSInteger)buttonIndex
{
   [self startChromeDisplayTimer];
   
   // Do nothing if the user taps outside the action 
   // sheet (thus closing the popover containing the
   // action sheet).
   if (buttonIndex < 0) {
      return;
   }
   
   if ([actionSheet tag] == ACTIONSHEET_TAG_DELETE) {
      [self deletePhotoConfirmed];
   }
}

#pragma mark - Rotation support
/**
 **
 ** Portions of the rotation code come from the Apple sample project
 ** PhotoScroller available at
 ** http://developer.apple.com/library/prerelease/ios/#samplecode/PhotoScroller/Introduction/Intro.html
 **
 **/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  // 5
{
   [[self scrollView] setScrollEnabled:NO];
   
   // Here, our pagingScrollView bounds have not yet been updated for the 
   // new interface orientation. So this is a good place to calculate the 
   // content offset that we will need in the new orientation.
   CGFloat offset = [self scrollView].contentOffset.x;
   CGFloat pageWidth = [self scrollView].bounds.size.width;
   
   if (offset >= 0) {
      [self setFirstVisiblePageIndexBeforeRotation:floorf(offset / pageWidth)];
      [self setPercentScrolledIntoFirstVisiblePage:(offset - ([self firstVisiblePageIndexBeforeRotation] * pageWidth)) / pageWidth];
   } else {
      [self setFirstVisiblePageIndexBeforeRotation:0];
      [self setPercentScrolledIntoFirstVisiblePage:offset / pageWidth];
   }
}

- (void)layoutScrollViewSubviews                                            // 6
{
   [self setScrollViewContentSize];
   
   NSArray *subviews = [[self scrollView] subviews];
   
   for (PhotoBrowserPhotoView *view in subviews) {
      CGPoint restorePoint = [view pointToCenterAfterRotation];
      CGFloat restoreScale = [view scaleToRestoreAfterRotation];
      [view setFrame:[self frameForPageAtIndex:[view index]]];
      [view setMaxMinZoomScalesForCurrentBounds];
      [view restoreCenterPoint:restorePoint scale:restoreScale];
   }
   
   // Adjust contentOffset to preserve page location based on 
   // values collected prior to location.
   CGRect bounds = [[self scrollView] bounds];
   CGFloat pageWidth = bounds.size.width;
   CGFloat newOffset = ([self firstVisiblePageIndexBeforeRotation] * pageWidth) + ([self percentScrolledIntoFirstVisiblePage] * pageWidth);
   [[self scrollView] setContentOffset:CGPointMake(newOffset, 0)];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  // 7
{
   [self layoutScrollViewSubviews];
   
   // If the chrome is hidden, the navigation
   // bar must be repositioned under the status
   // bar.
   if ([self isChromeHidden]) {
      UINavigationBar *navbar = [[self navigationController] navigationBar];
      CGRect frame = [navbar frame];
      frame.origin.y = [self statusBarHeight];
      [navbar setFrame:frame];
   }
}

- (void)didRotateFromInterfaceOrientation:
(UIInterfaceOrientation)fromInterfaceOrientation 
{
   [[self scrollView] setScrollEnabled:YES];
   [self startChromeDisplayTimer];
}

@end
