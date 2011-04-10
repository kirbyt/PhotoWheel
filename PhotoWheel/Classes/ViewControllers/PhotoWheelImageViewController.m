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


#define WHEEL_IMAGE_SIZE_WIDTH 80
#define WHEEL_IMAGE_SIZE_HEIGHT 80


@implementation PhotoWheelImageViewController

@synthesize photoWheelViewController = photoWheelViewController_;

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
#pragma mark UIGestureRecognizer Handlers

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
   NSLog(@"tap");
   UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Pick Image" otherButtonTitles:nil];
   CGRect rect = [[self view] bounds];
   [actionSheet showFromRect:rect inView:[self view] animated:YES];
}

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
   NSLog(@"tap tap");

   CGRect bounds = [[self view] bounds];
   CGPoint point = CGPointMake(bounds.size.width/2, bounds.size.height/2);
   point = [[self view] convertPoint:point toView:[[self view] superview]];
   NSLog(@"point=%@ bounds=%@", NSStringFromCGPoint(point), NSStringFromCGRect(bounds));
   
   [[self photoWheelViewController] showImageBrowserFromPoint:point];
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
   NSLog(@"pinch/zoom");
}


#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   [actionSheet release];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
   [actionSheet release];
}


@end
