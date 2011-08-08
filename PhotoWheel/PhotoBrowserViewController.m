//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "ClearToolbar.h"
#import "PhotoBrowserPhotoView.h"

#define RAND_IN_RANGE(low,high) (low + (high - low) * \
   (arc4random_uniform(RAND_MAX) / (double)RAND_MAX))

@interface PhotoBrowserViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) NSMutableArray *photoViewCache;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign, getter = isChromeHidden) BOOL chromeHidden;
@property (nonatomic, strong) NSTimer *chromeHideTimer;
@property (nonatomic, assign) NSInteger firstVisiblePageIndexBeforeRotation;
@property (nonatomic, assign) NSInteger percentScrolledIntoFirstVisiblePage;
@property (readwrite, strong) CIContext *ciContext;
@property (nonatomic, strong) NSMutableArray *imageFilters;
@property (nonatomic, strong) UIImage *filteredThumbnailImage;
@property (nonatomic, strong) UIImage *filteredLargeImage;
@property (nonatomic, strong) NSMutableArray *filteredThumbnailPreviewImages;

- (void)addButtonsToNavigationBar;
- (void)initPhotoViewCache;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (void)scrollToIndex:(NSInteger)index;
- (void)setScrollViewContentSize;
- (NSInteger)numberOfPhotos;
- (UIImage*)imageAtIndex:(NSInteger)index;
- (void)setTitleWithCurrentIndex;

- (void)loadPage:(NSInteger)index;
- (void)unloadPage:(NSInteger)index;

- (void)toggleChrome:(BOOL)hide;
- (void)hideChrome;
- (void)showChrome;
- (void)startChromeDisplayTimer;
- (void)cancelChromeDisplayTimer; 

- (void)hideFilters;
- (void)applySpecifiedFilter:(CIFilter *)filter;

@end


@implementation PhotoBrowserViewController

@synthesize delegate = delegate_;
@synthesize startAtIndex = startAtIndex_;
@synthesize pushFromFrame = pushFromFrame;
@synthesize filterButtons;
@synthesize filterViewContainer;
@synthesize scrollView = scrollView_;
@synthesize actionButton = actionButton_;
@synthesize photoViewCache = photoViewCache_;
@synthesize currentIndex = currentIndex_;
@synthesize chromeHidden = chromeHidden_;
@synthesize chromeHideTimer = chromeHideTimer_;
@synthesize firstVisiblePageIndexBeforeRotation = firstVisiblePageIndexBeforeRotation_;
@synthesize percentScrolledIntoFirstVisiblePage = percentScrolledIntoFirstVisiblePage_;
@synthesize ciContext = ciContext_;
@synthesize imageFilters = imageFilters_;
@synthesize filteredThumbnailImage = filteredThumbnailImage_;
@synthesize filteredLargeImage = filteredLargeImage_;
@synthesize filteredThumbnailPreviewImages = filteredThumbnailPreviewImages_;

- (void)loadView
{
   [super loadView];
   
   UIScrollView *newScrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
   [newScrollView setDelegate:self];
   [newScrollView setBackgroundColor:[UIColor blackColor]];
   [newScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
   [newScrollView setAutoresizesSubviews:YES];
   [newScrollView setPagingEnabled:YES];
   [newScrollView setShowsVerticalScrollIndicator:NO];
   [newScrollView setShowsHorizontalScrollIndicator:NO];
   
   [self.view addSubview:newScrollView];
   [self setScrollView:newScrollView];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self addButtonsToNavigationBar];
   [self initPhotoViewCache];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
   UINavigationBar *navBar = [[self navigationController] navigationBar];
   [navBar setBarStyle:UIBarStyleBlack];
   [navBar setTranslucent:YES];
   
   [[self navigationController] setNavigationBarHidden:NO animated:YES];
   
   [self setScrollViewContentSize];
   [self setCurrentIndex:[self startAtIndex]];
   [self scrollToIndex:[self startAtIndex]];
   [self setTitleWithCurrentIndex];
   [self startChromeDisplayTimer];
   
   [[self filterViewContainer] setAlpha:0.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self cancelChromeDisplayTimer];
   [[self navigationController] setNavigationBarHidden:YES animated:YES];
   [super viewWillDisappear:animated];
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

#pragma mark - Helper Methods

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
   
   UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(showFilters:)];
   
   NSMutableArray *toolbarItems = [[NSMutableArray alloc] initWithCapacity:4];
   [toolbarItems addObject:flexibleSpace];
   [toolbarItems addObject:filterButton];
   [toolbarItems addObject:slideshowButton];
   [toolbarItems addObject:actionButton];
   [toolbarItems addObject:trashButton];
   
   UIToolbar *toolbar = [[ClearToolbar alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
   [toolbar setBackgroundColor:[UIColor clearColor]];
   [toolbar setBarStyle:UIBarStyleBlack];
   [toolbar setTranslucent:YES];
   
   [toolbar setItems:toolbarItems];
   
   UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
   [[self navigationItem] setRightBarButtonItem:customBarButtonItem animated:YES];
}

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

#pragma mark - Actions

- (void)deletePhoto:(id)sender
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

- (void)showActionMenu:(id)sender
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)slideshow:(id)sender
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)photoTapped:(id)sender
{
   [self toggleChromeDisplay];
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
      [newView setBackgroundColor:[UIColor clearColor]];
      [newView setImage:[self imageAtIndex:index]];
      [newView setScroller:self];
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
   CGFloat pageWidth = scrollView.frame.size.width;
   float fractionalPage = scrollView.contentOffset.x / pageWidth;
   NSInteger page = floor(fractionalPage);
	if (page != currentIndex_) {
		[self setCurrentIndex:page];
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
   [self hideFilters];
}

- (void)showChrome 
{
   [self toggleChrome:NO];
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

#pragma mark - Rotation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration 
{
   // Here, our pagingScrollView bounds have not yet been updated for the 
   // new interface orientation. So this is a good place to calculate the 
   // content offset that we will need in the new orientation
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
   
   for (PhotoBrowserPhotoView *view in subviews) {
      CGPoint restorePoint = [view pointToCenterAfterRotation];
      CGFloat restoreScale = [view scaleToRestoreAfterRotation];
      [view setFrame:[self frameForPageAtIndex:[view index]]];
      [view setMaxMinZoomScalesForCurrentBounds];
      [view restoreCenterPoint:restorePoint scale:restoreScale];
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

- (void)viewDidUnload {
   [self setFilterViewContainer:nil];
   [self setFilterButtons:nil];
   [super viewDidUnload];
}

#pragma mark - Core Image filter methods

- (CIColor *)randomCIColor
{
   CIColor *randomColor = [CIColor colorWithRed:RAND_IN_RANGE(0.0, 1.0)
                                          green:RAND_IN_RANGE(0.0, 1.0)
                                           blue:RAND_IN_RANGE(0.0, 1.0)];
   return randomColor;
}

- (CIColor *)randomCIColorAlpha
{
   CIColor *randomColor = [CIColor colorWithRed:RAND_IN_RANGE(0.0, 1.0)
                                          green:RAND_IN_RANGE(0.0, 1.0)
                                           blue:RAND_IN_RANGE(0.0, 1.0)
                                          alpha:RAND_IN_RANGE(0.0, 1.0)];
   return randomColor;
}

- (void)setFilterButtons:(NSArray *)filterButtonsFromIB
{
   // Sort the filterButtons array by tag.
   filterButtons = [filterButtonsFromIB sortedArrayUsingComparator:^NSComparisonResult(UIButton *button1, UIButton *button2) {
      return [button1 tag] > [button2 tag];
   }];
}

- (CIFilter *)hueAdjustFilter
{
   CIFilter *hueAdjust = [CIFilter filterWithName:@"CIHueAdjust"];
   [hueAdjust setDefaults];
   CGFloat inputAngle = RAND_IN_RANGE(-M_PI, M_PI);
   [hueAdjust setValue: [NSNumber numberWithFloat: inputAngle] forKey:@"inputAngle"];
   return hueAdjust;
}

- (CIFilter *)colorTintFilter
{
   CIColor *tintColor = [self randomCIColor];
   CIFilter *tintFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
   [tintFilter setValue:tintColor forKey:@"inputColor"];
   return tintFilter;
}

- (CIFilter *)falseColorFilter
{
   CIColor *color0 = [self randomCIColor];
   CIColor *color1 = [CIColor colorWithRed:(1.0 - [color0 red])
                                     green:(1.0 - [color0 green])
                                      blue:(1.0 - [color0 blue])];
   CIFilter *falseColor = [CIFilter filterWithName:@"CIFalseColor"];
   [falseColor setValue:color0 forKey:@"inputColor0"];
   [falseColor setValue:color1 forKey:@"inputColor1"];
   return falseColor;
}

- (CIFilter *)invertColorFilter
{
   CIFilter *invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
   return invertFilter;
}

- (CIFilter *)filterWithAffineTransform:(CGAffineTransform)transform
{
   CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
   [transformFilter setDefaults];
   [transformFilter setValue:[NSValue valueWithCGAffineTransform:transform] forKey:@"inputTransform"];
   return transformFilter;
}

// Run through the filter list producing new randomized versions and updating the filter button images.
// Filters are saved in an array so they can be reused on the large image.
- (void)randomizeFilters
{
   [[self imageFilters] removeAllObjects];
   [[self filteredThumbnailPreviewImages] removeAllObjects];
   
   // Hue adjust filter
   CIFilter *hueAdjustFilter = [self hueAdjustFilter];
   [[self imageFilters] addObject:hueAdjustFilter];
   
   // Color tint filter
   CIFilter *tintFilter = [self colorTintFilter];
   [[self imageFilters] addObject:tintFilter];
   
   // False color filter
   CIFilter *falseColorFilter = [self falseColorFilter];
   [[self imageFilters] addObject:falseColorFilter];
   
   // Invert color filter
   CIFilter *invertFilter = [self invertColorFilter];
   [[self imageFilters] addObject:invertFilter];
   
   // Rotate 180 degrees filter
   CIFilter *rotateFilter = [self filterWithAffineTransform:CGAffineTransformMakeRotation(M_PI)];
   [[self imageFilters] addObject:rotateFilter];
   
   // Mirror image filter
   CIFilter *mirrorFilter = [self filterWithAffineTransform:CGAffineTransformMakeScale(-1, 1)];
   [[self imageFilters] addObject:mirrorFilter];
   
   // Skew filter
   CIFilter *skewFilter = [self filterWithAffineTransform:CGAffineTransformMake(1, tan(M_PI/12), tan(M_PI/16), 1, 0, 0)];
   [[self imageFilters] addObject:skewFilter];
   
   CIImage *thumbnailCIImage = [CIImage imageWithCGImage:[[self filteredThumbnailImage] CGImage]];
   
   dispatch_apply([[self imageFilters] count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
      CIFilter *filter = [[self imageFilters] objectAtIndex:i];
      [filter setValue:thumbnailCIImage forKey:kCIInputImageKey];
      CIImage *filterResult = [filter outputImage];
      
      CGImageRef filteredCGImage = [[self ciContext] createCGImage:filterResult fromRect:[filterResult extent]];
      UIImage *filteredImage = [UIImage imageWithCGImage:filteredCGImage];
      CFRelease(filteredCGImage);
      
      [[self filteredThumbnailPreviewImages] addObject:filteredImage];
      
      dispatch_async(dispatch_get_main_queue(), ^(void) {
         UIButton *filterButton = [[self filterButtons] objectAtIndex:i];
         [filterButton setImage:filteredImage forState:UIControlStateNormal];
      });
   });
}

- (void)showFilters:(id)sender
{
   if ([self imageFilters] == nil) {
      [self setImageFilters:[NSMutableArray arrayWithCapacity:[[self filterButtons] count]]];
      
      [self setCiContext:[CIContext contextWithOptions:nil]];
      
      [self setFilteredThumbnailPreviewImages:[NSMutableArray array]];
   }
   
   [self setFilteredThumbnailImage:[[self delegate] photoBrowserViewController:self smallImageAtIndex:[self currentIndex]]];
   UIImage *largeImage = [[self delegate] photoBrowserViewController:self imageAtIndex:[self currentIndex]];
   [self setFilteredLargeImage:largeImage];
   
   [self randomizeFilters];
   
   [[self view] bringSubviewToFront:[self filterViewContainer]];
   [UIView animateWithDuration:0.3 animations:^(void) {
      [[self filterViewContainer] setAlpha:1.0];
   }];
}

- (void)hideFilters
{
   // Hide filter container
   [UIView animateWithDuration:0.3 animations:^(void) {
      [[self filterViewContainer] setAlpha:0.0];
   }];
}

- (IBAction)enhanceImage:(id)sender {
   CIImage *largeCIImage = [CIImage imageWithCGImage:[[self filteredLargeImage] CGImage]];
   NSArray *autoAdjustmentFilters = [largeCIImage autoAdjustmentFilters];
   CIImage *enhancedImage = largeCIImage;
   for (CIFilter *filter in autoAdjustmentFilters) {
      [filter setValue:enhancedImage forKey:kCIInputImageKey];
      enhancedImage = [filter outputImage];
   }
   [self applySpecifiedFilter:[autoAdjustmentFilters lastObject]];
}

- (IBAction)zoomToFaces:(id)sender {
   NSDictionary *detectorOptions = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy];
   CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
   
   CIImage *largeCIImage = [CIImage imageWithCGImage:[[self filteredLargeImage] CGImage]];
   NSArray *faces = [faceDetector featuresInImage:largeCIImage options:nil];
   NSLog(@"Found %d faces", [faces count]);
   
   if ([faces count] > 0) {
      
      CGRect faceZoomRect = CGRectZero;
      
      for (CIFaceFeature *face in faces) {
         NSLog(@"Feature: %@ at %@", face, NSStringFromCGRect([face bounds]));
         
         if (CGRectEqualToRect(faceZoomRect, CGRectZero)) {
            faceZoomRect = [face bounds];
         } else {
            faceZoomRect = CGRectUnion(faceZoomRect, [face bounds]);
         }
      }
      faceZoomRect = CGRectIntersection([largeCIImage extent], CGRectInset(faceZoomRect, -50.0, -50.0)) ;
      NSLog(@"Face zoom rect: %@", NSStringFromCGRect(faceZoomRect));
      
      CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
      [cropFilter setValue:largeCIImage forKey:kCIInputImageKey];
      [cropFilter setValue:[CIVector vectorWithCGRect:faceZoomRect] forKey:@"inputRectangle"];
      
      [self applySpecifiedFilter:cropFilter];
   } else {
      UIAlertView *noFacesAlert = [[UIAlertView alloc] initWithTitle:@"No Faces"
                                                             message:@"Sorry, I couldn't find any faces in this picture."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
      [noFacesAlert show];
   }
}

- (void)applySpecifiedFilter:(CIFilter *)filter
{
   CIImage *filteredLargeImage = [filter outputImage];
   CGImageRef filteredLargeCGImage = [[self ciContext] createCGImage:filteredLargeImage fromRect:[filteredLargeImage extent]];
   UIImage *filteredImage = [UIImage imageWithCGImage:filteredLargeCGImage];
   [[[self photoViewCache] objectAtIndex:[self currentIndex]] setImage:filteredImage];
   [self setFilteredLargeImage:filteredImage];
   CFRelease(filteredLargeCGImage);
}

- (IBAction)applyFilter:(id)sender {
   CIFilter *filter = [[self imageFilters] objectAtIndex:[sender tag]];
   if ([[filter inputKeys] containsObject:kCIInputImageKey]) {
      CIImage *largeCIImage = [CIImage imageWithCGImage:[[self filteredLargeImage] CGImage]];
      [filter setValue:largeCIImage forKey:kCIInputImageKey];
   }
   [self applySpecifiedFilter:filter];
   [self setFilteredThumbnailImage:[[self filteredThumbnailPreviewImages] objectAtIndex:[sender tag]]];
   [self randomizeFilters];
}

- (IBAction)revertToOriginal:(id)sender {
   [self setFilteredThumbnailImage:[[self delegate] photoBrowserViewController:self smallImageAtIndex:[self currentIndex]]];
   [self randomizeFilters];
   UIImage *originalImage = [[self delegate] photoBrowserViewController:self imageAtIndex:[self currentIndex]];
   [[[self photoViewCache] objectAtIndex:[self currentIndex]] setImage:originalImage];
   [self setFilteredLargeImage:originalImage];
}

- (IBAction)saveImage:(id)sender {
   // Save the filtered large image
   if ([self filteredLargeImage] != nil) {
      [[self delegate] photoBrowserViewController:self updateToNewImage:[self filteredLargeImage] atIndex:[self currentIndex]];
   }
   
   [self hideFilters];
}

- (IBAction)cancel:(id)sender {
   // Restore original large image
   UIImage *originalImage = [[self delegate] photoBrowserViewController:self imageAtIndex:[self currentIndex]];
   [[[self photoViewCache] objectAtIndex:[self currentIndex]] setImage:originalImage];
   
   [self hideFilters];
}
@end
