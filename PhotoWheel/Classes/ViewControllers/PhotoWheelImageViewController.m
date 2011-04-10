//
//  PhotoWheelImageViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/9/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelImageViewController.h"
#import "PhotoWheelImageView.h"
#import "PhotoWheelViewController.h"
#import "PhotoNubMenuViewController.h"


#define WHEEL_IMAGE_SIZE_WIDTH 80
#define WHEEL_IMAGE_SIZE_HEIGHT 80

@interface PhotoWheelImageViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@end


@implementation PhotoWheelImageViewController

@synthesize photoWheelViewController = photoWheelViewController_;
@synthesize popoverController = popoverController_;

- (void)dealloc
{
   [popoverController_ release], popoverController_ = nil;
   [super dealloc];
}

- (void)loadView
{
   CGRect wheelSubviewFrame = CGRectMake(-(WHEEL_IMAGE_SIZE_WIDTH * 0.5), -(WHEEL_IMAGE_SIZE_HEIGHT * 0.5), WHEEL_IMAGE_SIZE_WIDTH, WHEEL_IMAGE_SIZE_HEIGHT);

   UIImage *defaultImage = [UIImage imageNamed:@"photoDefault.png"];
   PhotoWheelImageView *newView = [[PhotoWheelImageView alloc] initWithFrame:wheelSubviewFrame];
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
   if (popoverController == [self popoverController]) {
      [self setPopoverController:nil];
   }
}

#pragma mark -
#pragma mark UIGestureRecognizer Handlers

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
   PhotoNubMenuViewController *menuViewController = [[PhotoNubMenuViewController alloc] init];
   UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
   UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
   [newPopover setDelegate:self];
   [newPopover setPopoverContentSize:CGSizeMake(320, 200)];
   [self setPopoverController:newPopover];

   [newPopover release];
   [menuViewController release];
   [navController release];
   
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
