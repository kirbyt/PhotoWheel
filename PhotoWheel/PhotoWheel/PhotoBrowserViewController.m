//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/1/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoBrowserPhotoView.h"                                         // 2
#import "ClearToolbar.h"                                                // 3

#define ACTIONSHEET_TAG_DELETE 1                                        // 4
#define ACTIONSHEET_TAG_ACTIONS 2                                       // 5

@interface PhotoBrowserViewController ()
@property (nonatomic, assign) NSInteger currentIndex;                   // 1
@property (nonatomic, strong) NSMutableArray *photoViewCache;           // 2
@property (nonatomic, strong) UIBarButtonItem *actionButton;            // 6

- (void)initPhotoViewCache;                                             // 3
- (void)setScrollViewContentSize;
- (void)scrollToIndex:(NSInteger)index;
- (void)setTitleWithCurrentIndex;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (void)addButtonsToNavigationBar;                                      // 7

@end

@implementation PhotoBrowserViewController

@synthesize scrollView = _scrollView;                                   // 4
@synthesize delegate = _delegate;
@synthesize startAtIndex = _startAtIndex;
@synthesize currentIndex = _currentIndex;
@synthesize photoViewCache = _photoViewCache;
@synthesize chromeHidden = _chromeHidden;                                 // 9
@synthesize chromeHideTimer = _chromeHideTimer;                           // 10
@synthesize statusBarHeight = _statusBarHeight;                           // 11
@synthesize actionButton = _actionButton;                               // 8

- (void)viewDidLoad                                                     // 5
{
   [super viewDidLoad];
   
   // Make sure to set wantsFullScreenLayout or the photo
   // will not display behind the status bar.
   [self setWantsFullScreenLayout:YES];                                 // 6
   
   // Set the view's frame size. This ensures that the scroll view
   // autoresizes correctly and avoids surprises when retrieving
   // the scroll view's bounds later.
   CGRect frame = [[UIScreen mainScreen] bounds];                       // 7
   [[self view] setFrame:frame];
   
   UIScrollView *scrollView = [self scrollView];                        // 8
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
   
   [self addButtonsToNavigationBar];                                    // 9
   [self initPhotoViewCache];                                           // 9

   // Must store the status bar size while it is still visible.
   CGRect statusBarFrame = [[UIApplication sharedApplication] 
                            statusBarFrame];                              // 12
   if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
      [self setStatusBarHeight:statusBarFrame.size.width];
   } else {
      [self setStatusBarHeight:statusBarFrame.size.height];
   }
}

- (void)viewDidUnload                                                   // 10
{
   [self setScrollView:nil];
   [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated                                   // 11
{
   [super viewWillAppear:animated];
   [self setScrollViewContentSize];
   [self setCurrentIndex:[self startAtIndex]];
   [self scrollToIndex:[self startAtIndex]];
   [self setTitleWithCurrentIndex];
   
   [self startChromeDisplayTimer];                                        // 13
}

- (void)viewWillDisappear:(BOOL)animated                                  // 14
{
   [self cancelChromeDisplayTimer];
   [super viewWillDisappear:animated];
}

#pragma mark - Delegate callback helpers

- (NSInteger)numberOfPhotos                                             // 12
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

- (UIImage*)imageAtIndex:(NSInteger)index                               // 13
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

- (void)addButtonsToNavigationBar                                       // 10
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

- (void)initPhotoViewCache                                              // 14
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

- (void)setScrollViewContentSize                                        // 15
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

- (void)scrollToIndex:(NSInteger)index                                  // 16
{
   CGRect bounds = [[self scrollView] bounds];
   bounds.origin.x = bounds.size.width * index;
   bounds.origin.y = 0;
   [[self scrollView] scrollRectToVisible:bounds animated:NO];
}

- (void)setTitleWithCurrentIndex                                        // 17
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

- (CGRect)frameForPagingScrollView                                      // 18
{
   CGRect frame = [[UIScreen mainScreen] bounds];
   frame.origin.x -= PADDING;
   frame.size.width += (2 * PADDING);
   return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index                         // 19
{
   CGRect bounds = [[self scrollView] bounds];
   CGRect pageFrame = bounds;
   pageFrame.size.width -= (2 * PADDING);
   pageFrame.origin.x = (bounds.size.width * index) + PADDING;
   return pageFrame;
}

#pragma mark - Page management

- (void)loadPage:(NSInteger)index                                       // 20
{
   if (index < 0 || index >= [self numberOfPhotos]) {
      return;
   }
   
   id currentView = [[self photoViewCache] objectAtIndex:index];
   if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]] == NO) { // 3
      // Load the photo view.
      CGRect frame = [self frameForPageAtIndex:index];
      PhotoBrowserPhotoView *newView = [[PhotoBrowserPhotoView alloc] 
                                        initWithFrame:frame];             // 4
      [newView setBackgroundColor:[UIColor clearColor]];                  // 5
      [newView setImage:[self imageAtIndex:index]];                       // 6
      [newView setPhotoBrowserViewController:self];                       // 7
      [newView setIndex:index];                                           // 8
      
      [[self scrollView] addSubview:newView];
      [[self photoViewCache] replaceObjectAtIndex:index withObject:newView];
   } else {
      [currentView turnOffZoom];
   }
}

- (void)unloadPage:(NSInteger)index                                     // 21
{
   if (index < 0 || index >= [self numberOfPhotos]) {
      return;
   }
   
   id currentView = [[self photoViewCache] objectAtIndex:index];
   if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]]) {       // 9
      [currentView removeFromSuperview];
      [[self photoViewCache] replaceObjectAtIndex:index withObject:[NSNull null]];
   }
}

- (void)setCurrentIndex:(NSInteger)newIndex                             // 22
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView                  // 23
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView            // 18
{
   [self hideChrome];
}

#pragma mark - Chrome helpers

- (void)toggleChromeDisplay                                               // 19
{
   [self toggleChrome:![self isChromeHidden]];
}

- (void)toggleChrome:(BOOL)hide                                           // 20
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

- (void)hideChrome                                                        // 21
{
   NSTimer *timer = [self chromeHideTimer];
   if (timer && [timer isValid]) {
      [timer invalidate];
      [self setChromeHideTimer:nil];
   }
   [self toggleChrome:YES];
}

- (void)startChromeDisplayTimer                                           // 22
{
   [self cancelChromeDisplayTimer];
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 
                                                     target:self 
                                                   selector:@selector(hideChrome) 
                                                   userInfo:nil 
                                                    repeats:NO];
   [self setChromeHideTimer:timer];
}

- (void)cancelChromeDisplayTimer                                          // 23
{
   if ([self chromeHideTimer]) {
      [[self chromeHideTimer] invalidate];
      [self setChromeHideTimer:nil];
   }
}

#pragma mark - Gesture handlers

- (void)imageTapped:(UITapGestureRecognizer *)recognizer                  // 24
{
   [self toggleChromeDisplay];
}

#pragma mark - Actions

- (void)deletePhotoConfirmed                                            // 11
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

- (void)deletePhoto:(id)sender                                          // 12
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

- (void)showActionMenu:(id)sender                                       // 13
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)slideshow:(id)sender                                            // 14
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet 
clickedButtonAtIndex:(NSInteger)buttonIndex                             // 15
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
