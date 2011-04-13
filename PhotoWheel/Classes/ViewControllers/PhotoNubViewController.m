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


#define WHEEL_IMAGE_SIZE_WIDTH 80
#define WHEEL_IMAGE_SIZE_HEIGHT 80

@interface PhotoNubViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) PhotoNubMenuViewController *menuViewController;
@end


@implementation PhotoNubViewController

@synthesize photoWheelViewController = photoWheelViewController_;
@synthesize popoverController = popoverController_;
@synthesize menuViewController = menuViewController_;

- (void)dealloc
{
   [popoverController_ release], popoverController_ = nil;
   [super dealloc];
}

- (void)loadView
{
   CGRect wheelSubviewFrame = CGRectMake(-(WHEEL_IMAGE_SIZE_WIDTH * 0.5), -(WHEEL_IMAGE_SIZE_HEIGHT * 0.5), WHEEL_IMAGE_SIZE_WIDTH, WHEEL_IMAGE_SIZE_HEIGHT);

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


#pragma mark -
#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
   [self setPopoverController:nil];
}


#pragma mark -
#pragma mark UIGestureRecognizer Handlers

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
   PhotoNubMenuViewController *menuViewController = [[PhotoNubMenuViewController alloc] init];
   [self setMenuViewController:menuViewController];
   [menuViewController release];
   
   UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[self menuViewController]];
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
   [navController release];

   [newPopover setDelegate:self];
   [newPopover setPopoverContentSize:CGSizeMake(320, 200)];
   [menuViewController setPopoverController:newPopover];
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
   
   [[self photoWheelViewController] showImageBrowserFromPoint:point];
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
   NSLog(@"pinch/zoom");
}


@end
