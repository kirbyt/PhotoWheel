//
//  MainSlideShowViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/22/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "MainSlideShowViewController.h"
#import "ClearToolbar.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MainSlideShowViewController ()
@property (nonatomic, strong) NSTimer *slideAdvanceTimer;
@property (nonatomic, assign, getter = isChromeHidden) BOOL chromeHidden;
@property (nonatomic, strong) NSTimer *chromeHideTimer;
@property (nonatomic, strong) SlideShowViewController *externalDisplaySlideshowController;
@property (nonatomic, strong) UIWindow *externalScreenWindow;

- (void)toggleChrome:(BOOL)hide;
- (void)hideChrome;
- (void)startChromeDisplayTimer;
- (void)cancelChromeDisplayTimer; 
- (void)toggleChromeDisplay;

- (void)updateNavBarButtonsForPlayingState:(BOOL)playing;
- (UIScreen *)getExternalScreen;
- (void)configureExternalScreen:(UIScreen *)externalScreen;
@end

@implementation MainSlideShowViewController

@synthesize slideAdvanceTimer = _slideAdvanceTimer;
@synthesize chromeHidden = _chromeHidden;
@synthesize chromeHideTimer = _chromeHideTimer;
@synthesize externalDisplaySlideshowController = _externalDisplaySlideshowController;
@synthesize externalScreenWindow = _externalScreenWindow;

- (UIScreen *)getExternalScreen
{
   NSArray *screens = [UIScreen screens];
   UIScreen *externalScreen = nil;
   if ([screens count] > 1) {
      // The internal screen is guaranteed to be at index 0.
      externalScreen = [screens lastObject];
   }
   return externalScreen;
}

- (void)configureExternalScreen:(UIScreen *)externalScreen
{
   // Clear any existing external screen items
   [self setExternalDisplaySlideshowController:nil];
   [self setExternalScreenWindow:nil];
   
   // Create a new window and move it to the external screen
   [self setExternalScreenWindow:[[UIWindow alloc]
                                  initWithFrame:[externalScreen applicationFrame]]];
   [[self externalScreenWindow] setScreen:externalScreen];
   
   // Create a SlideShowViewController to handle slides on the 
   // external screen
   SlideShowViewController *externalSlideController =
   [[SlideShowViewController alloc] init];
   [self setExternalDisplaySlideshowController:externalSlideController];
   [externalSlideController setDelegate:[self delegate]];
   [externalSlideController setStartIndex:[self currentIndex]];
   
   // Add the external slideshow view to the external window and 
   // resize it to fit
   [[self externalScreenWindow] addSubview:[externalSlideController view]];
   [[externalSlideController view] setFrame:[[self externalScreenWindow] frame]];
   
   // Set the external screen view's background color to match the 
   // one configured in the storyboard
   [[externalSlideController view]
    setBackgroundColor:[[self view] backgroundColor]];
   
   // Show the window
   [[self externalScreenWindow] makeKeyAndVisible];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self updateNavBarButtonsForPlayingState:YES];
   
   // Check for an extra screen existing right now
   UIScreen *externalScreen = [self getExternalScreen];
   if (externalScreen != nil) {
      [self configureExternalScreen:externalScreen];
   }
   
   NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
   // Add observers for screen connect/disconnect
   [notificationCenter addObserverForName:UIScreenDidConnectNotification
                                   object:nil
                                    queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification *note) 
    {
       UIScreen *newExternalScreen = [note object];
       [self configureExternalScreen:newExternalScreen];
    }];
   
   [notificationCenter addObserverForName:UIScreenDidDisconnectNotification
                                   object:nil
                                    queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification *note)
    {
       [self setExternalDisplaySlideshowController:nil];
       [self setExternalScreenWindow:nil];
    }];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
   [super setCurrentIndex:currentIndex];
   [[self externalDisplaySlideshowController] setCurrentIndex:currentIndex];
   
   [[self currentPhotoView] setUserInteractionEnabled:YES];
   UITapGestureRecognizer *photoTapRecognizer =
   [[UITapGestureRecognizer alloc]
    initWithTarget:self
    action:@selector(photoTapped:)];
   [[self currentPhotoView] addGestureRecognizer:photoTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                     target:self
                                                   selector:@selector(advanceSlide:)
                                                   userInfo:nil
                                                    repeats:YES];
   [self setSlideAdvanceTimer:timer];

   UINavigationBar *navBar = [[self navigationController] navigationBar];
   [navBar setBarStyle:UIBarStyleBlack];
   [navBar setTranslucent:YES];
   
   [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self cancelChromeDisplayTimer];
   [[self slideAdvanceTimer] invalidate];
   [self setSlideAdvanceTimer:nil];
   [self setExternalDisplaySlideshowController:nil];
   [self setExternalScreenWindow:nil];
   
   [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
   [super viewDidUnload];
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateNavBarButtonsForPlayingState:(BOOL)playing
{
   UIBarButtonItem *rewindButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                    target:self
                                    action:@selector(backOnePhoto:)];
   [rewindButton setStyle:UIBarButtonItemStyleBordered];
   UIBarButtonItem *playPauseButton;
   if (playing) {
      playPauseButton = [[UIBarButtonItem alloc]
                         initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                         target:self
                         action:@selector(pause:)];
   } else {
      playPauseButton = [[UIBarButtonItem alloc]
                         initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                         target:self
                         action:@selector(resume:)];
   }
   [playPauseButton setStyle:UIBarButtonItemStyleBordered];
   UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                     target:self
                                     action:@selector(forwardOnePhoto:)];
   [forwardButton setStyle:UIBarButtonItemStyleBordered];
   
   // Add the AirPlay selector
   MPVolumeView *airPlaySelectorView = [[MPVolumeView alloc] init];
   [airPlaySelectorView setShowsVolumeSlider:NO];
   [airPlaySelectorView setShowsRouteButton:YES];
   CGSize airPlaySelectorSize = [airPlaySelectorView
                                 sizeThatFits:CGSizeMake(44.0, 44.0)];
   [airPlaySelectorView setFrame:
    CGRectMake(0, 0, airPlaySelectorSize.width,
               airPlaySelectorSize.height)];
   UIBarButtonItem *airPlayButton = [[UIBarButtonItem alloc]
                                     initWithCustomView:airPlaySelectorView];
   
   NSArray *toolbarItems = [NSArray arrayWithObjects:
                            airPlayButton, rewindButton, playPauseButton, forwardButton, nil];
   
   UIToolbar *toolbar = [[ClearToolbar alloc]
                         initWithFrame:CGRectMake(0, 0, 200, 44)];
   [toolbar setBackgroundColor:[UIColor clearColor]];
   [toolbar setBarStyle:UIBarStyleBlack];
   [toolbar setTranslucent:YES];
   [toolbar setItems:toolbarItems];
   
   UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithCustomView:toolbar];
   [[self navigationItem]
    setRightBarButtonItem:customBarButtonItem
    animated:YES];
}

#pragma mark - Actions that control the slide display

- (void)advanceSlide:(NSTimer *)timer
{
   [self setCurrentIndex:[self currentIndex] + 1];
}

- (void)photoTapped:(id)sender
{
   // When the photo is tapped, show the chrome
   [self toggleChromeDisplay];
}

- (void)pause:(id)sender
{
   [[self slideAdvanceTimer] setFireDate:[NSDate distantFuture]];
   [self updateNavBarButtonsForPlayingState:NO];
}

- (void)resume:(id)sender
{
   [[self slideAdvanceTimer] setFireDate:[NSDate date]];
   [self updateNavBarButtonsForPlayingState:YES];
}

- (void)backOnePhoto:(id)sender
{
   [self pause:nil];
   [self setCurrentIndex:[self currentIndex] - 1];
}

- (void)forwardOnePhoto:(id)sender
{
   [self pause:nil];
   [self setCurrentIndex:[self currentIndex] + 1];
}

#pragma mark - Rotation handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for the main screen slide show
   return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration 
{
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

#pragma mark - Chrome Helpers (from PhotoBrowserViewController)

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

@end
