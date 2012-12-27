//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/25/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "Photo.h"
#import "PhotoBrowserPhotoView.h"
#import "SendEmailController.h"
#import "MainScreenSlideShowViewController.h"
#import <CoreImage/CoreImage.h>

#define ACTIONSHEET_TAG_DELETE 1
#define ACTIONSHEET_TAG_ACTIONS 2

#define RAND_IN_RANGE(low,high) (low + (high - low) * \
(arc4random_uniform(RAND_MAX) / (double)RAND_MAX))

@interface PhotoBrowserViewController () <UIActionSheetDelegate, SendEmailControllerDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) SendEmailController *sendEmailController;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *photoViewCache;
@property (nonatomic, assign, getter=isChromeHidden) BOOL chromeHidden;
@property (nonatomic, strong) NSTimer *chromeHideTimer;
@property (nonatomic, assign) CGFloat statusBarHeight;
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIPopoverController *activityPopover;
@property (nonatomic, strong) MainScreenSlideShowViewController *slideShowController;

@property (readwrite, strong) CIContext *ciContext;
@property (nonatomic, strong) NSMutableArray *imageFilters;
@property (nonatomic, strong) NSMutableArray *filteredThumbnailPreviewImages;
@property (nonatomic, strong) UIImage *filteredThumbnailImage;
@property (nonatomic, strong) UIImage *filteredLargeImage;

@property (nonatomic, assign) CGFloat filterRadiusFactor;
@property (nonatomic, assign) CGFloat filterCenterFactor;
@end

@implementation PhotoBrowserViewController

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
   [scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
   [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight];
   [scrollView setAutoresizesSubviews:YES];
   [scrollView setPagingEnabled:YES];
   [scrollView setShowsVerticalScrollIndicator:NO];
   [scrollView setShowsHorizontalScrollIndicator:NO];
   
   [self addButtonsToNavigationBar];
   [self initPhotoViewCache];
   
   // Must store the status bar size while it is still visible.
   UIApplication *app = [UIApplication sharedApplication];
   CGRect statusBarFrame = [app statusBarFrame];
   if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
      [self setStatusBarHeight:statusBarFrame.size.width];
   } else {
      [self setStatusBarHeight:statusBarFrame.size.height];
   }
}

- (void)viewWillAppear:(BOOL)animated 
{
   [super viewWillAppear:animated];
   [self setScrollViewContentSize];
   
   if ([self slideShowController] == nil) {
       [self setCurrentIndex:[self startAtIndex]];
       [self scrollToIndex:[self startAtIndex]];
    } else {
       [self setCurrentIndex:[[self slideShowController] currentIndex]];
       [self scrollToIndex:[[self slideShowController] currentIndex]];
       [self setSlideShowController:nil];
    }
       
   [self setTitleWithCurrentIndex];
   [self startChromeDisplayTimer];
   [[self filterViewContainer] setAlpha:0.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self cancelChromeDisplayTimer];
   [super viewWillDisappear:animated];
}

#pragma mark - Helpers

- (NSInteger)numberOfPhotos  
{
   NSInteger numberOfPhotos = [[self photos] count];
   return numberOfPhotos;
}

- (UIImage*)imageAtIndex:(NSInteger)index 
{
   Photo *photo = [[self photos] objectAtIndex:index];
   UIImage *image = [photo largeImage];
   return image;
}

#pragma mark - Helper methods

- (void)initPhotoViewCache
{
   // Set up the photo's view cache. We keep only three views in
   // memory. NSNull is used as a placeholder for the other
   // elements in the view cache array.
   
   NSInteger numberOfPhotos = [self numberOfPhotos];
   NSMutableArray *cache = nil;
   cache = [[NSMutableArray alloc] initWithCapacity:numberOfPhotos];
   for (int i=0; i < numberOfPhotos; i++) {
      [cache addObject:[NSNull null]];
   }
   [self setPhotoViewCache:cache];
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
   NSString *title = nil;
   title = [NSString stringWithFormat:@"%1$i of %2$i", index, count, nil];
   [self setTitle:title];
}

- (void)addButtonsToNavigationBar
{
   UIBarButtonItem *trashButton = nil;
   trashButton = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                  target:self
                  action:@selector(deletePhoto:)];
   [trashButton setStyle:UIBarButtonItemStyleBordered];
   
   UIBarButtonItem *actionButton = nil;
   actionButton = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                   target:self
                   action:@selector(showActionMenu:)];
   [actionButton setStyle:UIBarButtonItemStyleBordered];
   [self setActionButton:actionButton];
   
   UIBarButtonItem *slideshowButton = nil;
   slideshowButton = [[UIBarButtonItem alloc]
                      initWithTitle:@"Slideshow"
                      style:UIBarButtonItemStyleBordered
                      target:self
                      action:@selector(slideshow:)];
   
   UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Edit"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(showFilters:)];
   
   NSArray *buttons = @[filterButton, slideshowButton, actionButton, trashButton];
   [[self navigationItem] setRightBarButtonItems:buttons];
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
   
   NSMutableArray *photoViewCache = [self photoViewCache];
   id currentView = [photoViewCache objectAtIndex:index];
   if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]]==NO) {
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
   
   NSMutableArray *photoViewCache = [self photoViewCache];
   id currentView = [photoViewCache objectAtIndex:index];
   if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]]) {
      [currentView removeFromSuperview];
      [photoViewCache replaceObjectAtIndex:index withObject:[NSNull null]];
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

   if ([[self filterViewContainer] alpha] > 0) {
      [self cancel:self];
   }
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
   NSTimer *timer = nil;
   timer = [NSTimer scheduledTimerWithTimeInterval:5.0
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
   NSInteger count = [self numberOfPhotos];
   NSInteger indexToDelete = [self currentIndex];
   [self unloadPage:indexToDelete];
   
   // Delete the photo from photos, and send notification
   // to delete the photo from the Core Data store.
   NSMutableArray *photos = [[self photos] mutableCopy];
   [photos removeObjectAtIndex:indexToDelete];
   [self setPhotos:photos];

   NSDictionary *userInfo = nil;
   userInfo = @{@"index":[NSNumber numberWithInteger:indexToDelete]};
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc postNotificationName:kPhotoWheelDidDeletePhotoAtIndex
                     object:nil
                   userInfo:userInfo];
   
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

- (void)deletePhoto:(id)sender
{
   [self cancelChromeDisplayTimer];
   UIActionSheet *actionSheet = nil;
   actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate:self
                                    cancelButtonTitle:nil
                               destructiveButtonTitle:@"Delete Photo"
                                    otherButtonTitles:nil, nil];
   [actionSheet setTag:ACTIONSHEET_TAG_DELETE];
   [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)showActionMenu:(id)sender
{
   [self cancelChromeDisplayTimer];

   if ([self activityPopover]) {
      [[self activityPopover] dismissPopoverAnimated:YES];
      [self setActivityPopover:nil];

   } else {
      UIImage *currentPhoto = [self imageAtIndex:[self currentIndex]];
      NSArray *activityItems = @[@"Share me", currentPhoto];
      UIActivityViewController *activityVC = nil;
      activityVC = [[UIActivityViewController alloc]
                    initWithActivityItems:activityItems
                    applicationActivities:nil];
      
      UIPopoverController *popover = nil;
      popover = [[UIPopoverController alloc]
                 initWithContentViewController:activityVC];
      [popover setDelegate:self];
      [popover presentPopoverFromBarButtonItem:sender
                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                      animated:YES];
      [self setActivityPopover:popover];
   }
}

- (void)slideshow:(id)sender
{
   [self performSegueWithIdentifier:@"SlideshowSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue identifier] isEqualToString:@"SlideshowSegue"]) {
      MainScreenSlideShowViewController *slideShowController = [segue destinationViewController];
      [slideShowController setPhotos:[self photos]];
      [slideShowController setCurrentIndex:[self currentIndex]];
      [self setSlideShowController:slideShowController];
      
      [self setTitle:@"Photo Browser"];
   }
}

#pragma mark - Printing

- (void)printCurrentPhoto
{
   [self cancelChromeDisplayTimer];
   UIImage *currentPhoto = [self imageAtIndex:[self currentIndex]];
   
   UIPrintInteractionController *controller =
   [UIPrintInteractionController sharedPrintController];
   if(!controller){
      NSLog(@"Couldn't get shared UIPrintInteractionController!");
      return;
   }
   
   UIPrintInteractionCompletionHandler completionHandler =
   ^(UIPrintInteractionController *printController, BOOL completed,
     NSError *error)
   {
      [self startChromeDisplayTimer];
      if(completed && error)
         NSLog(@"FAILED! due to error in domain %@ with error code %u",
               error.domain, error.code);
   };
   
   UIPrintInfo *printInfo = [UIPrintInfo printInfo];
   [printInfo setOutputType:UIPrintInfoOutputPhoto];
   [printInfo setJobName:[NSString stringWithFormat:@"photo-%i",
                          [self currentIndex]]];
   
   [controller setPrintInfo:printInfo];
   [controller setPrintingItem:currentPhoto];
   
   [controller presentFromBarButtonItem:[self actionButton]
                               animated:YES
                      completionHandler:completionHandler];
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
   } else if ([actionSheet tag] == ACTIONSHEET_TAG_ACTIONS) {
      // Button index 0 can be Email or Print. It depends on whether or
      // not the device supports that feature.
      if (buttonIndex == 0) {
         if ([SendEmailController canSendMail]) {
            [self emailCurrentPhoto];
         } else if ([UIPrintInteractionController isPrintingAvailable]) {
            [self printCurrentPhoto];
         }
      } else {
         // If there is a button index 1, it
         // will also be Print.
         [self printCurrentPhoto];
      }
   }
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   [[self scrollView] setScrollEnabled:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   [self setScrollViewContentSize];
   [self alignScrollViewSubviews];
   [self scrollToIndex:[self currentIndex]];
   [self repositionNavigationBar];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   [[self scrollView] setScrollEnabled:YES];
}

- (void)alignScrollViewSubviews
{
   NSMutableArray *cache = [self photoViewCache];
   NSArray *subviews = [[self scrollView] subviews];
   [subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      NSInteger indexInCache = [cache indexOfObject:obj];
      [obj setFrame:[self frameForPageAtIndex:indexInCache]];
      [obj restoreAfterRotation];
   }];
}

- (void)repositionNavigationBar
{
   if ([self isChromeHidden]) {
      UINavigationBar *navbar = [[self navigationController] navigationBar];
      CGRect frame = [navbar frame];
      frame.origin.y = [self statusBarHeight];
      [navbar setFrame:frame];
   }
}

#pragma mark - Email and SendEmailControllerDelegate methods

- (void)emailCurrentPhoto
{
   UIImage *currentPhoto = [self imageAtIndex:[self currentIndex]];
   NSSet *photos = [NSSet setWithObject:currentPhoto];
   
   SendEmailController *controller = [[SendEmailController alloc]
                                      initWithViewController:self];
   [controller setPhotos:photos];
   [controller sendEmail];
   
   [self setSendEmailController:controller];
}

- (void)sendEmailControllerDidFinish:(SendEmailController *)controller
{
   if ([controller isEqual:[self sendEmailController]]) {
      [self setSendEmailController:nil];
   }
}

#pragma mark - UIPopoverControllerDelegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
   if (popoverController == [self activityPopover]) {
      [self setActivityPopover:nil];
   }
}

#pragma mark - Filters

- (void)showFilters:(id)sender
{
   if ([self imageFilters] == nil) {
      [self setImageFilters:[NSMutableArray arrayWithCapacity:[[self filterButtons] count]]];
      
      CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @NO}];
      [self setCiContext:context];
      
      [self setFilteredThumbnailPreviewImages:[NSMutableArray array]];
   }
   
   Photo *currentPhoto = [[self photos] objectAtIndex:[self currentIndex]];
   [self setFilteredThumbnailImage:[currentPhoto smallImage]];
   [self setFilteredLargeImage:[currentPhoto originalImage]];
   
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

- (void)setFilterButtons:(NSArray *)filterButtonsFromIB
{
   _filterButtons = [filterButtonsFromIB sortedArrayUsingComparator:^NSComparisonResult(UIButton *button1, UIButton *button2) {
      return [button1 tag] > [button2 tag];
   }];
}

- (CIFilter *)hueAdjustFilter
{
   CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"];
   CGFloat inputAngle = RAND_IN_RANGE(-M_PI, M_PI);
   [filter setValue:@(inputAngle) forKey:@"inputAngle"];
   return filter;
}

- (CIFilter *)invertColorFilter
{
   CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
   return filter;
}

- (CIFilter *)affineTileFilter
{
   CGFloat scaleFactor = RAND_IN_RANGE(0.2, 0.8);
   CGAffineTransform transform = CGAffineTransformMakeScale(scaleFactor,
                                                            scaleFactor);
   transform = CGAffineTransformRotate(transform,
                                       RAND_IN_RANGE(0.2, M_PI/2));
   
   CIFilter *filter = [CIFilter filterWithName:@"CIAffineTile"];
   [filter setValue:[NSValue valueWithBytes:&transform
                                   objCType:@encode(CGAffineTransform)]
             forKey:@"inputTransform"];
   return filter;
}

- (CIFilter *)posterizeFilter
{
   CIFilter *filter = [CIFilter filterWithName:@"CIColorPosterize"];
   CGFloat posterizeLevel = RAND_IN_RANGE(2.0, 30.0);
   [filter setValue:@(posterizeLevel) forKey:@"inputLevels"];
   
   return filter;
}

- (CIFilter *)bumpDistortionFilter
{
   CIFilter *filter = [CIFilter filterWithName:@"CIBumpDistortion"];
   [filter setValue:@(RAND_IN_RANGE(-1.0, 1.0)) forKey:@"inputScale"];
   return filter;
}

- (CIFilter *)twirlFilter
{
   CIFilter *filter = [CIFilter filterWithName:@"CITwirlDistortion"];
   [filter setValue:@(RAND_IN_RANGE(-M_PI, M_PI)) forKey:@"inputAngle"];
   return filter;
}

- (CIFilter *)circleSplashDistortionFilter
{
   CIFilter *filter = [CIFilter
                       filterWithName:@"CICircleSplashDistortion"];
   return filter;
}
- (void)randomizeFilters
{
   [[self imageFilters] removeAllObjects];
   [[self filteredThumbnailPreviewImages] removeAllObjects];
   
   // Hue adjust filter
   CIFilter *hueAdjustFilter = [self hueAdjustFilter];
   [[self imageFilters] addObject:hueAdjustFilter];
   
   // Invert color filter
   CIFilter *invertFilter = [self invertColorFilter];
   [[self imageFilters] addObject:invertFilter];
   
   // Affine tile filter
   CIFilter *affineTileFilter = [self affineTileFilter];
   [[self imageFilters] addObject:affineTileFilter];
   
   // Posterize filter
   CIFilter *posterizeFilter = [self posterizeFilter];
   [[self imageFilters] addObject:posterizeFilter];
   
   // Bump distort filter
   CIFilter *bumpDistortFilter = [self bumpDistortionFilter];
   [[self imageFilters] addObject:bumpDistortFilter];
   
   // Twirl distort filter
   CIFilter *twirlDistortFilter = [self twirlFilter];
   [[self imageFilters] addObject:twirlDistortFilter];
   
   // Circle splash filter
   CIFilter *circleSplashDistortionFilter =
   [self circleSplashDistortionFilter];
   [[self imageFilters] addObject:circleSplashDistortionFilter];
   
   CIImage *thumbnailCIImage = [CIImage imageWithCGImage:
                                [[self filteredThumbnailImage] CGImage]];
   CGRect extents = [thumbnailCIImage extent];
   
   [self setFilterCenterFactor:RAND_IN_RANGE(0.1, 0.9)];
   [self setFilterRadiusFactor:RAND_IN_RANGE(0.1, 0.9)];
   
   for (int i=0; i<[[self imageFilters] count]; i++) {
      CIFilter *filter = [[self imageFilters] objectAtIndex:i];
      [filter setValue:thumbnailCIImage forKey:@"inputImage"];
      
      if ([[filter attributes] objectForKey:@"inputRadius"] != nil) {
         NSNumber *radius;
         radius = @(extents.size.width * [self filterRadiusFactor]);
         [filter setValue:radius forKey:@"inputRadius"];
      }
      if ([[filter attributes] objectForKey:@"inputCenter"] != nil) {
         CGPoint fCenter;
         fCenter.x = (extents.size.width * [self filterCenterFactor]);
         fCenter.y = (extents.size.height * [self filterCenterFactor]);
         
         CIVector *inputCenter = [CIVector vectorWithX:fCenter.x
                                                     Y:fCenter.y];
         [filter setValue:inputCenter forKey:@"inputCenter"];
      }
      CIImage *filterResult = [filter outputImage];
      
      CGImageRef filteredCGImage = [[self ciContext]
                                    createCGImage:filterResult
                                    fromRect:[thumbnailCIImage extent]];
      UIImage *filteredImage = [UIImage imageWithCGImage:filteredCGImage];
      CFRelease(filteredCGImage);
      
      [[self filteredThumbnailPreviewImages] addObject:filteredImage];
      
      UIButton *filterButton = [[self filterButtons] objectAtIndex:i];
      [filterButton setImage:filteredImage
                    forState:UIControlStateNormal];
   }
}
- (void)applySpecifiedFilter:(CIFilter *)filter
{
   CIImage *inputCIImage = [filter valueForKey:@"inputImage"];;
   
   // Set input radius or center, where needed.
   CGRect inputExtents = [inputCIImage extent];
   if ([[filter attributes] objectForKey:@"inputRadius"] != nil) {
      NSNumber *radius;
      radius = @(inputExtents.size.width * [self filterRadiusFactor]);
      [filter setValue:radius forKey:@"inputRadius"];
   }
   if ([[filter attributes] objectForKey:@"inputCenter"] != nil) {
      CGPoint fCenter;
      fCenter.x = (inputExtents.size.width * [self filterCenterFactor]);
      fCenter.y = (inputExtents.size.height * [self filterCenterFactor]);
      
      CIVector *inputCenter = [CIVector vectorWithX:fCenter.x
                                                  Y:fCenter.y];
      [filter setValue:inputCenter forKey:@"inputCenter"];
   }
   
   CIImage *filteredLargeImage = [filter outputImage];
   
   // Make sure we're not trying to use infinite extent to create an image
   CGRect cgImageRect;
   if (!CGRectIsInfinite([filteredLargeImage extent])) {
      cgImageRect = [filteredLargeImage extent];
   } else {
      cgImageRect = inputExtents;
   }
   CGImageRef filteredLargeCGImage = [[self ciContext]
                                      createCGImage:filteredLargeImage
                                      fromRect:cgImageRect];
   
   // Convert the result to a UIImage, display it, and save it for later.
   UIImage *filteredImage = [UIImage imageWithCGImage:filteredLargeCGImage];
   [[[self photoViewCache] objectAtIndex:[self currentIndex]]
    setImage:filteredImage];
   [self setFilteredLargeImage:filteredImage];
   CFRelease(filteredLargeCGImage);
}

- (IBAction)applyFilter:(id)sender
{
   CIFilter *filter = [[self imageFilters] objectAtIndex:[sender tag]];
   CIImage *inputCIImage = [CIImage imageWithCGImage:
                            [[self filteredLargeImage] CGImage]];
   [filter setValue:inputCIImage forKey:@"inputImage"];
   
   [self applySpecifiedFilter:filter];
   [self setFilteredThumbnailImage:
    [[self filteredThumbnailPreviewImages] objectAtIndex:[sender tag]]];
   [self randomizeFilters];
}

- (IBAction)enhanceImage:(id)sender {
   CIImage *largeCIImage = [CIImage imageWithCGImage:
                            [[self filteredLargeImage] CGImage]];
   NSArray *autoAdjustmentFilters = [largeCIImage autoAdjustmentFilters];
   CIImage *enhancedImage = largeCIImage;
   for (CIFilter *filter in autoAdjustmentFilters) {
      [filter setValue:enhancedImage forKey:@"inputImage"];
      enhancedImage = [filter outputImage];
   }
   [self applySpecifiedFilter:[autoAdjustmentFilters lastObject]];
}

- (IBAction)zoomToFaces:(id)sender {
   NSDictionary *detectorOptions =
   @{CIDetectorAccuracy : CIDetectorAccuracyLow};
   CIDetector *faceDetector = [CIDetector
                               detectorOfType:CIDetectorTypeFace
                               context:nil
                               options:detectorOptions];
   
   CIImage *largeCIImage = [CIImage imageWithCGImage:[[self filteredLargeImage] CGImage]];
   NSArray *faces = [faceDetector featuresInImage:largeCIImage options:nil];
   
   if ([faces count] > 0) {
      CGRect faceZoomRect = CGRectNull;
      
      for (CIFaceFeature *face in faces) {
         if (CGRectEqualToRect(faceZoomRect, CGRectNull)) {
            faceZoomRect = [face bounds];
         } else {
            faceZoomRect = CGRectUnion(faceZoomRect, [face bounds]);
         }
      }
      
      faceZoomRect = CGRectIntersection([largeCIImage extent], CGRectInset(faceZoomRect, -50.0, -50.0));
      
      CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
      [cropFilter setValue:largeCIImage forKey:@"inputImage"];
      [cropFilter setValue:[CIVector vectorWithCGRect:faceZoomRect] forKey:@"inputRectangle"];
      
      [self applySpecifiedFilter:cropFilter];
   } else {
      UIAlertView *noFacesAlert = [[UIAlertView alloc]
                                   initWithTitle:@"No Faces"
                                   message:@"Sorry, I couldn't find any faces in this picture."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
      [noFacesAlert show];
   }
}
- (IBAction)revertToOriginal:(id)sender {
   // Reload the original image for filtering and regenerate the filters
   [self setFilteredThumbnailImage:[[[self photos] objectAtIndex:[self currentIndex]] smallImage]];
   [self randomizeFilters];
   
   // Restore the original large image to the browser.
   UIImage *originalImage = [[[self photos] objectAtIndex:[self currentIndex]] largeImage];
   [[[self photoViewCache] objectAtIndex:[self currentIndex]] setImage:originalImage];
   [self setFilteredLargeImage:originalImage];
}

- (IBAction)saveImage:(id)sender {
   // Save the filtered large image
   if ([self filteredLargeImage] != nil) {
      Photo *currentPhoto = [[self photos] objectAtIndex:[self currentIndex]];
      [currentPhoto saveImage:[self filteredLargeImage]];
   }
   // Hide the filter UI
   [self hideFilters];
}

- (IBAction)cancel:(id)sender {
   // Restore original large image
   UIImage *originalImage = [[[self photos] objectAtIndex:[self currentIndex]] largeImage];
   [[[self photoViewCache] objectAtIndex:[self currentIndex]] setImage:originalImage];
   // Hide the filter UI
   [self hideFilters];
}

@end
