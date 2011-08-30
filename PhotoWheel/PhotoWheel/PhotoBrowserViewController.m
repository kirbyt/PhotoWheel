//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/26/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoBrowserPhotoView.h"
/*
#import "ClearToolbar.h"
 */

#define ACTIONSHEET_TAG_DELETE 1
#define ACTIONSHEET_TAG_ACTIONS 2

@interface PhotoBrowserViewController ()
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *photoViewCache;
@property (nonatomic, assign, getter = isChromeHidden) BOOL chromeHidden;
@property (nonatomic, strong) NSTimer *chromeHideTimer;
@property (nonatomic, assign) CGFloat statusBarHeight;
@property (nonatomic, strong) UIBarButtonItem *actionButton;

//- (void)addButtonsToNavigationBar;
- (void)initPhotoViewCache;
- (void)setScrollViewContentSize;
- (void)scrollToIndex:(NSInteger)index;
- (void)setTitleWithCurrentIndex;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;

- (void)toggleChrome:(BOOL)hide;
- (void)hideChrome;
- (void)startChromeDisplayTimer;
- (void)cancelChromeDisplayTimer; 
@end

@implementation PhotoBrowserViewController

@synthesize scrollView = scrollView_;
@synthesize delegate = delegate_;
@synthesize startAtIndex = startAtIndex_;
@synthesize currentIndex = currentIndex_;
@synthesize photoViewCache = photoViewCache_;
@synthesize chromeHidden = chromeHidden_;
@synthesize chromeHideTimer = chromeHideTimer_;
@synthesize statusBarHeight = statusBarHeight_;
@synthesize actionButton = actionButton_;

- (void)viewDidLoad 
{
   [super viewDidLoad];

   // Make sure to set wantsFullScreenLayout or the photo
   // will not display behind the status bar.
   [self setWantsFullScreenLayout:YES];

   // Set the view's frame size. This ensures the scroll view
   // autoresizing correctly and avoids surprises when retrieving
   // the scroll view's bounds later.
   CGRect frame = [[UIScreen mainScreen] bounds];
   [[self view] setFrame:frame];
   
   UIScrollView *scrollView = [self scrollView]; 
   [scrollView setFrame:[self frameForPagingScrollView]];   // Set the initial size.
   [scrollView setDelegate:self];
   [scrollView setBackgroundColor:[UIColor blackColor]];
   [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
   [scrollView setAutoresizesSubviews:YES];
   [scrollView setPagingEnabled:YES];
   [scrollView setShowsVerticalScrollIndicator:NO];
   [scrollView setShowsHorizontalScrollIndicator:NO];
   
   // Must store the status bar size while it is still visible.
   CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
   if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
      [self setStatusBarHeight:statusBarFrame.size.width];
   } else {
      [self setStatusBarHeight:statusBarFrame.size.height];
   }

   /*
   [self addButtonsToNavigationBar];
    */
   [self initPhotoViewCache];   
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

#pragma mark - Delegate Callback Helpers

- (NSInteger)numberOfPhotos   
{
   NSInteger numberOfPhotos = 0;
   id<PhotoBrowserViewControllerDelegate> delegate = [self delegate];
   if (delegate && [delegate respondsToSelector:@selector(photoBrowserViewControllerNumberOfPhotos:)]) {
      numberOfPhotos = [delegate photoBrowserViewControllerNumberOfPhotos:self];
   }
   return numberOfPhotos;
}

- (UIImage*)imageAtIndex:(NSInteger)index 
{
   UIImage *image = nil;
   id<PhotoBrowserViewControllerDelegate> delegate = [self delegate];
   if (delegate && [delegate respondsToSelector:@selector(photoBrowserViewController:imageAtIndex:)]) {
      image = [delegate photoBrowserViewController:self imageAtIndex:index];
   }
   return image;
}

#pragma mark - Helper Methods
/*
- (void)addButtonsToNavigationBar
{
   // Add buttons to the navigation bar. The nav bar allows
   // one button on the left and one on the right. Optionally
   // a custom view can be used instead of a button. To get
   // multiple buttons we must create a short toolbar containing
   // the buttons we want.
   
   UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto:)];
   [trashButton setStyle:UIBarButtonItemStyleBordered];
   
   UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionMenu:)];
   [actionButton setStyle:UIBarButtonItemStyleBordered];
   [self setActionButton:actionButton];
   
   UIBarButtonItem *slideshowButton = [[UIBarButtonItem alloc] initWithTitle:@"Slideshow" style:UIBarButtonItemStyleBordered target:self action:@selector(slideshow:)];
   
   UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
   
   
   NSMutableArray *toolbarItems = [[NSMutableArray alloc] initWithCapacity:3];
   [toolbarItems addObject:flexibleSpace];
   [toolbarItems addObject:slideshowButton];
   [toolbarItems addObject:actionButton];
   [toolbarItems addObject:trashButton];
   
   UIToolbar *toolbar = [[ClearToolbar alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
   [toolbar setBackgroundColor:[UIColor clearColor]];
   [toolbar setBarStyle:UIBarStyleBlack];
   [toolbar setTranslucent:YES];
   
   [toolbar setItems:toolbarItems];
   
   UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
   [[self navigationItem] setRightBarButtonItem:customBarButtonItem animated:YES];
}
*/
- (void)initPhotoViewCache
{
   // Setup our photo view cache. We only keep 3 views in
   // memory. NSNull is used as a placeholder for the other
   // elements in the view cache array.
   
   NSInteger numberOfPhotos = [self numberOfPhotos];;
   self.photoViewCache = [[NSMutableArray alloc] initWithCapacity:numberOfPhotos];
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
                            bounds.size.height / 2);   // Cut in half to prevent horizontal scrolling.
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
   NSString *title = title = [NSString stringWithFormat:@"%1$i of %2$i", index, count, nil];
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

#pragma mark - Page Management

- (void)loadPage:(NSInteger)index   
{
   if (index < 0 || index >= [self numberOfPhotos]) {
      return;
   }
   
   id currentView = [[self photoViewCache] objectAtIndex:index];
   if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]] == NO) {
      // Load the photo view.
      CGRect frame = [self frameForPageAtIndex:index];
      PhotoBrowserPhotoView *newView = [[PhotoBrowserPhotoView alloc] initWithFrame:frame];
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
   currentIndex_ = newIndex;
   
   [self loadPage:currentIndex_];
   [self loadPage:currentIndex_ + 1];
   [self loadPage:currentIndex_ - 1];
   [self unloadPage:currentIndex_ + 2];
   [self unloadPage:currentIndex_ - 2];
   
   [self setTitleWithCurrentIndex];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   if ([scrollView isScrollEnabled]) {
      CGFloat pageWidth = scrollView.bounds.size.width;
      float fractionalPage = scrollView.contentOffset.x / pageWidth;
      NSInteger page = floor(fractionalPage);
      if (page != currentIndex_) {
         [self setCurrentIndex:page];
      }
   }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
   [self hideChrome];
}

#pragma mark - Chrome Helpers

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
   
   // Must set the navigation bar's alpha, otherwise the photo
   // view will be pushed until the navigation bar.
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
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideChrome) userInfo:nil repeats:NO];
   [self setChromeHideTimer:timer];
}

- (void)cancelChromeDisplayTimer 
{
   if ([self chromeHideTimer]) {
      [[self chromeHideTimer] invalidate];
      [self setChromeHideTimer:nil];
   }
}

#pragma mark - Actions

- (void)deletePhotoConfirmed
{
   id<PhotoBrowserViewControllerDelegate> delegate = [self delegate];
   if (delegate && [delegate respondsToSelector:@selector(photoBrowserViewController:deleteImageAtIndex:)]) {
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
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete Photo" otherButtonTitles:nil, nil];
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

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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

@end