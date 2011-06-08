//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/7/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoView.h"
#import "Models.h"
#import "CustomToolbar.h"
#import "SendEmailController.h"

#define ACTIONSHEET_DELETEMENU 1
#define ACTIONSHEET_ACTIONMENU 2

@interface PhotoBrowserViewController ()
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *photoViewCache;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSTimer *chromeTimer;
@property (nonatomic, assign, getter = isChromeHidden) BOOL chromeHidden;
@property (nonatomic, assign) NSInteger firstVisiblePageIndexBeforeRotation;
@property (nonatomic, assign) NSInteger percentScrolledIntoFirstVisiblePage;
@property (nonatomic, retain) SendEmailController *sendEmailController;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (NSInteger)numberOfPhotos;
- (void)addButtonsToNavigationBar;
- (void)setTitleWithCurrentPhotoIndex;
- (void)scrollToIndex:(NSInteger)index; 
- (void)setScrollViewContentSize;
- (void)initPhotoViewCache;
- (void)startChromeDisplayTimer;
- (void)cancelChromeDisplayTimer; 
- (void)hideChrome;
- (void)chromeShouldHide:(BOOL)hide;
- (void)loadPhoto:(NSInteger)index;
- (void)unloadPhoto:(NSInteger)index;
@end

@implementation PhotoBrowserViewController

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize scrollView = scrollView_;
@synthesize photoViewCache = photoViewCache_;
@synthesize currentIndex = currentIndex_;
@synthesize startAtIndex = startAtIndex_;
@synthesize chromeTimer = chromeTimer_;
@synthesize chromeHidden = chromeHidden_;
@synthesize firstVisiblePageIndexBeforeRotation = firstVisiblePageIndexBeforeRotation_;
@synthesize percentScrolledIntoFirstVisiblePage = percentScrolledIntoFirstVisiblePage_;
@synthesize actionButton = actionButton_;
@synthesize sendEmailController = sendEmailController_;

- (void)dealloc
{
   [fetchedResultsController_ release], fetchedResultsController_ = nil;
   [scrollView_ release], scrollView_ = nil;
   [photoViewCache_ release], photoViewCache_ = nil;
   [actionButton_ release], actionButton_ = nil;
   [sendEmailController_ release], sendEmailController_ = nil;
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

   [self addButtonsToNavigationBar];
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
   [self cancelChromeDisplayTimer];
   [[[self navigationController] navigationBar] setHidden:YES];
}

- (void)viewDidUnload
{
   [self setActionButton:nil];
   [super viewDidUnload];
}

#pragma mark - Rotation Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration 
{
   // Here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
   // place to calculate the content offset that we will need in the new orientation
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

- (void)layoutScrollViewSubviews
{
   [self setScrollViewContentSize];
   
   NSArray *subviews = [[self scrollView] subviews];
   
   for (PhotoView *photoView in subviews) {
      CGPoint restorePoint = [photoView pointToCenterAfterRotation];
      CGFloat restoreScale = [photoView scaleToRestoreAfterRotation];
      [photoView setFrame:[self frameForPageAtIndex:[photoView index]]];
      [photoView setMaxMinZoomScalesForCurrentBounds];
      [photoView restoreCenterPoint:restorePoint scale:restoreScale];
   }
   
   // adjust contentOffset to preserve page location based on values collected prior to location
   CGFloat pageWidth = [self scrollView].bounds.size.width;
   CGFloat newOffset = ([self firstVisiblePageIndexBeforeRotation] * pageWidth) + ([self percentScrolledIntoFirstVisiblePage] * pageWidth);
   [[self scrollView] setContentOffset:CGPointMake(newOffset, 0)];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration 
{
   [self layoutScrollViewSubviews];
   
   // Adjust navigation bar if needed.
   if ([self isChromeHidden]) {
      UINavigationBar *navbar = [[self navigationController] navigationBar];
      CGRect frame = [navbar frame];
      frame.origin.y = 20;
      [navbar setFrame:frame];
   }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
   [self startChromeDisplayTimer];
}



#pragma mark - Helper Methods

- (NSInteger)numberOfPhotos
{
   NSInteger count = [[[[self fetchedResultsController] sections] objectAtIndex:0] numberOfObjects];
   return count;
}

- (id)objectAtIndex:(NSInteger)index
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
   id object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
   return object;
}

- (UIImage *)photoAtIndex:(NSInteger)index
{
   Photo *photo = [self objectAtIndex:index];
   return [photo largeImage];
}

- (void)addButtonsToNavigationBar
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
   [self setActionButton:actionButton];
   
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
   NSInteger pageCount = [self numberOfPhotos];
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
   NSInteger numberOfPhotos = [self numberOfPhotos];
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
   
   [self setChromeHidden:hide];
}

- (void)toggleChromeDisplay
{
   [self chromeShouldHide:![self isChromeHidden]];
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

#pragma mark - Scrolling Page Management

- (void)setCurrentIndex:(NSInteger)newIndex
{
   currentIndex_ = newIndex;
   
   [self loadPhoto:currentIndex_];
   [self loadPhoto:currentIndex_ + 1];
   [self loadPhoto:currentIndex_ - 1];
   [self unloadPhoto:currentIndex_ + 2];
   [self unloadPhoto:currentIndex_ - 2];
   
   [self setTitleWithCurrentPhotoIndex];
}

- (void)loadPhoto:(NSInteger)index
{
   if (index < 0 || index >= [self numberOfPhotos]) {
      return;
   }
   
   id currentPhotoView = [[self photoViewCache] objectAtIndex:index];
   if (NO == [currentPhotoView isKindOfClass:[PhotoView class]]) {
      // Load the photo view.
      CGRect frame = [self frameForPageAtIndex:index];
      PhotoView *photoView = [[PhotoView alloc] initWithFrame:frame];
      [photoView setPhotoBrowserViewController:self];
      [photoView setIndex:index];
      [photoView setBackgroundColor:[UIColor clearColor]];
      
      // Set the photo image.
      UIImage *image = [self photoAtIndex:index];
      [photoView setImage:image];
      
      [[self scrollView] addSubview:photoView];
      [[self photoViewCache] replaceObjectAtIndex:index withObject:photoView];
      [photoView release];
   } else {
      // Turn off zooming.
      [currentPhotoView turnOffZoom];
   }
}

- (void)unloadPhoto:(NSInteger)index
{
   if (index < 0 || index >= [self numberOfPhotos]) {
      return;
   }
   
   id currentPhotoView = [[self photoViewCache] objectAtIndex:index];
   if ([currentPhotoView isKindOfClass:[PhotoView class]]) {
      [currentPhotoView removeFromSuperview];
      [[self photoViewCache] replaceObjectAtIndex:index withObject:[NSNull null]];
   }
}

#pragma mark - Actions

- (void)deletePhoto:(id)sender
{
   [self cancelChromeDisplayTimer];
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button text.")
                                              destructiveButtonTitle:NSLocalizedString(@"Delete Photo", @"Delete Photo button text.")
                                                   otherButtonTitles:nil];
   [actionSheet setTag:ACTIONSHEET_DELETEMENU];
   [actionSheet showFromBarButtonItem:sender animated:YES];
   [actionSheet release];
}

- (void)showActionMenu:(id)sender
{
   [self cancelChromeDisplayTimer];
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Email Photo", @"Print", nil];
   [actionSheet setTag:ACTIONSHEET_ACTIONMENU];
   [actionSheet showFromBarButtonItem:sender animated:YES];
   [actionSheet release];
}

- (void)slideshow:(id)sender
{
   
}

- (void)deleteCurrentPhoto
{
   NSInteger indexToDelete = [self currentIndex];
   [self unloadPhoto:indexToDelete];
   Photo *photoToDelete = [self objectAtIndex:indexToDelete];
   NSManagedObjectContext *context = [photoToDelete managedObjectContext];
   [context deleteObject:photoToDelete];
   [photoToDelete kt_save];
   
   if ([self numberOfPhotos] == 0) {
      [[self navigationController] popViewControllerAnimated:YES];
   } else {
      NSInteger nextIndex = indexToDelete;
      if (nextIndex == [self numberOfPhotos]) {
         --nextIndex;
      }
      [self setCurrentIndex:nextIndex];
      [self setScrollViewContentSize];
   }
}

- (void)emailCurrentPhoto
{
   Photo *photo = [self objectAtIndex:[self currentIndex]];
   
   SendEmailController *newController = [[SendEmailController alloc] initWithViewController:self];
   [newController setPhotos:[NSSet setWithObject:photo]];
   [self setSendEmailController:newController];
   [newController release];
   
   [[self sendEmailController] sendEmail];
}

- (void)printCurrentPhoto
{
   Photo *photo = [self objectAtIndex:[self currentIndex]];
   NSURL *imageURL = [photo largeImageURL];
   if (imageURL == nil) return;  // Nothing to print.
   
   UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
   if(!controller){
      NSLog(@"Couldn't get shared UIPrintInteractionController!");
      return;
   }
   
   UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
      if(completed && error)
         NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
   };
   
   UIPrintInfo *printInfo = [UIPrintInfo printInfo];
   [printInfo setOutputType:UIPrintInfoOutputPhoto];
   [printInfo setJobName:[[imageURL path] lastPathComponent]];
   
   [controller setPrintInfo:printInfo];
   [controller setPrintingItem:imageURL];

   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [controller presentFromBarButtonItem:[self actionButton] animated:YES completionHandler:completionHandler];  // iPad
   }else
      [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
   if ([actionSheet tag] == ACTIONSHEET_ACTIONMENU) {
      switch (buttonIndex) {
         case 0:
            [self emailCurrentPhoto];
            break;
         case 1:
            [self printCurrentPhoto];
            break;
         default:
            break;
      }
      
   } else if ([actionSheet tag] == ACTIONSHEET_DELETEMENU) {
      if (buttonIndex == 0) {
         [self deleteCurrentPhoto];
      }
   }
   [self startChromeDisplayTimer];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
   CGFloat pageWidth = scrollView.frame.size.width;
   float fractionalPage = scrollView.contentOffset.x / pageWidth;
   NSInteger page = floor(fractionalPage);
	if (page != [self currentIndex]) {
		[self setCurrentIndex:page];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
   [self hideChrome];
}

#pragma mark - SendEmailControllerDelegate

- (void)sendEmailControllerDidFinish:(SendEmailController *)controller
{
   if (controller == [self sendEmailController]) {
      [self setSendEmailController:nil];
   }
}

@end
