//
//  PhotoWheelImageViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/9/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoNubViewController.h"
#import "PhotoNubView.h"
#import "PhotoWheelViewController.h"
#import "PhotoNubMenuViewController.h"
#import "Nub.h"


@interface PhotoNubViewController ()
@property (nonatomic, retain, readwrite) UIPopoverController *popoverController;
@property (nonatomic, retain) PhotoNubMenuViewController *menuViewController;
@end


@implementation PhotoNubViewController

@synthesize photoWheelViewController = photoWheelViewController_;
@synthesize popoverController = popoverController_;
@synthesize menuViewController = menuViewController_;
@synthesize nub = nub_;

- (void)dealloc
{
   [popoverController_ release], popoverController_ = nil;
   [nub_ release], nub_ = nil;
   [super dealloc];
}

- (void)loadView
{
   CGRect wheelSubviewFrame = CGRectMake(-(NUB_IMAGE_SIZE_WIDTH * 0.5), -(NUB_IMAGE_SIZE_HEIGHT * 0.5), NUB_IMAGE_SIZE_WIDTH, NUB_IMAGE_SIZE_HEIGHT);

   UIImage *defaultImage = [UIImage imageNamed:@"photoDefault.png"];
   PhotoNubView *newView = [[PhotoNubView alloc] initWithFrame:wheelSubviewFrame];
   [newView setImage:defaultImage];
   [self setView:newView];
   [newView release];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
   [doubleTapGesture setNumberOfTapsRequired:2];
   [[self view] addGestureRecognizer:doubleTapGesture];
   [doubleTapGesture release];
   
   UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
   [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
   [[self view] addGestureRecognizer:tapGesture];
   [tapGesture release];
   
   UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
   [[self view] addGestureRecognizer:pinchGesture];
   [pinchGesture release];
}

- (void)updateNubDisplay
{
   UIImage *image = [[self nub] smallImage];
   PhotoNubView *view = (PhotoNubView *)[self view];
   [view setImage:image];
}

- (void)setNub:(Nub *)nub
{
   if (nub_ != nub) {
      [nub retain];
      [nub_ release];
      nub_ = nub;
      
      [self updateNubDisplay];
   }
}


#pragma mark - Menu Handlers

- (void)menuDidSelectImage:(UIImage *)image
{
   [[self popoverController] dismissPopoverAnimated:YES];
   [self setPopoverController:nil];
   
   [[self nub] saveImage:image];
   [self updateNubDisplay];
}

- (void)menuDidCancel
{
   [[self popoverController] dismissPopoverAnimated:YES];
   [self setPopoverController:nil];
}


#pragma mark - UIPopoverControllerDelegate

// This is called when the popover is by the user touching outside
// of the popover. It is not called when the popover is dismissed
// programatically.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
   [self setPopoverController:nil];
}


#pragma mark - UIGestureRecognizer Handlers

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
   PhotoNubMenuViewController *menuViewController = [[PhotoNubMenuViewController alloc] init];
   [self setMenuViewController:menuViewController];
   [menuViewController setViewController:self];
   [menuViewController release];
   
   UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[self menuViewController]];
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
   [navController release];

   [newPopover setDelegate:self];
   [newPopover setPopoverContentSize:CGSizeMake(320, 200)];
   [self setPopoverController:newPopover];
   [newPopover release];
   
   CGRect rect = [[self view] bounds];
   [[self popoverController] presentPopoverFromRect:rect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
   CGRect bounds = [[self view] bounds];
   CGPoint point = CGPointMake(bounds.size.width/2, bounds.size.height/2);
   point = [[self view] convertPoint:point toView:[[self view] superview]];
   
   NSInteger index = [[[self nub] sortOrder] intValue];
   [[self photoWheelViewController] showImageBrowserFromPoint:point startAtIndex:index];
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
   NSLog(@"pinch/zoom");
}


@end
