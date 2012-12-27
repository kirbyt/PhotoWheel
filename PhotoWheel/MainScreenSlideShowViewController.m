//
//  MainScreenSlideShowViewController.m
//  PhotoWheel
//
//  Created by Tom Harrington on 11/28/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "MainScreenSlideShowViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MainScreenSlideShowViewController ()
@property (nonatomic, strong) NSTimer *slideAdvanceTimer;
@property (nonatomic, assign, getter = isChromeHidden) BOOL chromeHidden;
@property (nonatomic, strong) NSTimer *chromeHideTimer;
@property (nonatomic, strong) ExternalSlideShowViewController *externalDisplaySlideshowController;
@property (nonatomic, strong) UIWindow *externalScreenWindow;
@end

@implementation MainScreenSlideShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Make sure to set wantsFullScreenLayout or the photo
    // will not display behind the status bar.
    [self setWantsFullScreenLayout:YES];

    [self updateNavBarButtonsForPlayingState:YES];

    // Check for an extra screen existing right now
    UIScreen *externalScreen = [self getExternalScreen];
    if (externalScreen != nil) {
        [self configureExternalScreen:externalScreen];
    }
    
    // Add observers for screen connect/disconnect
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil];
    [nc addObserver:self selector:@selector(screenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(advanceSlide:) userInfo:nil repeats:YES];
    [self setSlideAdvanceTimer:timer];
    [self startChromeDisplayTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self cancelChromeDisplayTimer];
    [[self slideAdvanceTimer] invalidate];
    [self setSlideAdvanceTimer:nil];
    [self setExternalDisplaySlideshowController:nil];
    [self setExternalScreenWindow:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIScreenDidConnectNotification object:nil];
    [nc removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    [super setCurrentIndex:currentIndex];
    [[self externalDisplaySlideshowController] setCurrentIndex:currentIndex];
   
    [[self currentPhotoView] setUserInteractionEnabled:YES];
    UITapGestureRecognizer *photoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [[self currentPhotoView] addGestureRecognizer:photoTapRecognizer];
}

- (void)updateNavBarButtonsForPlayingState:(BOOL)playing
{
    UIBarButtonItem *rewindButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(backOnePhoto:)];
    [rewindButton setStyle:UIBarButtonItemStyleBordered];
    UIBarButtonItem *playPauseButton;
    if (playing) {
        playPauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause:)];
    } else {
        playPauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(resume:)];
    }
    [playPauseButton setStyle:UIBarButtonItemStyleBordered];
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardOnePhoto:)];
    [forwardButton setStyle:UIBarButtonItemStyleBordered];
    
    NSArray *slideShowControls = @[forwardButton, playPauseButton, rewindButton];
   
    [[self navigationItem] setRightBarButtonItems:slideShowControls];
}

#pragma mark - Actions
- (void)advanceSlide:(NSTimer *)timer
{
    [self setCurrentIndex:[self currentIndex] + 1];
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

- (void)photoTapped:(id)sender
{
    // When the photo is tapped, show the chrome
    [self toggleChromeDisplay];
}

#pragma mark - External screen management
- (void)screenDidConnect:(NSNotification *)notification
{
    UIScreen *newExternalScreen = [notification object];
    [self configureExternalScreen:newExternalScreen];
}

- (void)screenDidDisconnect:(NSNotification *)notification
{
    [self setExternalDisplaySlideshowController:nil];
    [self setExternalScreenWindow:nil];
}

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
    [self setExternalScreenWindow:[[UIWindow alloc] initWithFrame:[externalScreen applicationFrame]]];
    [[self externalScreenWindow] setScreen:externalScreen];
    
    // Create a ExternalSlideShowViewController to handle slides on the
    // external screen
    ExternalSlideShowViewController *externalSlideController = [[ExternalSlideShowViewController alloc] init];
    [self setExternalDisplaySlideshowController:externalSlideController];
    [externalSlideController setPhotos:[self photos]];
    [externalSlideController setCurrentIndex:[self currentIndex]];
    
    // Add the external slideshow view to the external window and
    // resize it to fit
    [[self externalScreenWindow] addSubview:[externalSlideController view]];
    [[externalSlideController view] setFrame:[[self externalScreenWindow] frame]];
   
    // Set the external screen view's background color to match the
    // one configured in the storyboard
    [[externalSlideController view] setBackgroundColor:[[self view] backgroundColor]];
   
    // Show the window
    [[self externalScreenWindow] makeKeyAndVisible];
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
   timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideChrome) userInfo:nil repeats:NO];
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
