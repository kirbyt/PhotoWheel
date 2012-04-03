//
//  SlideShowViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/22/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "SlideShowViewController.h"
#import "PhotoBrowserViewController.h"

@implementation SlideShowViewController

@synthesize delegate = _delegate;
@synthesize currentIndex = _currentIndex;
@synthesize startIndex = _startIndex;
@synthesize currentPhotoView = _currentPhotoView;

- (void)setCurrentIndex:(NSInteger)rawNewCurrentIndex
{
   if ((rawNewCurrentIndex == [self currentIndex]) && ([[[self view] subviews] count] != 0))
   {
      return;
   }
   // If the new index is outside the existing range, wrap 
   // around to the other end.
   NSInteger photoCount = [[self delegate] photoBrowserViewControllerNumberOfPhotos:nil];
   NSInteger newCurrentIndex = rawNewCurrentIndex;
   if (newCurrentIndex >= photoCount) {
      newCurrentIndex = 0;
   }
   if (newCurrentIndex < 0) {
      newCurrentIndex = photoCount - 1;
   }
   
   // Create a new image view for the current photo
   UIImage *newImage = [[self delegate] photoBrowserViewController:nil imageAtIndex:newCurrentIndex];
   UIImageView *newPhotoView = [[UIImageView alloc] initWithImage:newImage];
   [newPhotoView setContentMode:UIViewContentModeScaleAspectFit];
   [newPhotoView setFrame:[[self view] bounds]];
   [newPhotoView setAutoresizingMask:
    (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
   
   if ([self currentPhotoView] == nil) {
      // If there's no photo view yet, just add it
      [[self view] addSubview:newPhotoView];
   } else {
      // If there is a photo view, do a nice animation
      NSInteger transitionOptions;
      // Use the original value of the new index to decide if 
      // we're moving forward or backward through the photos.
      // Curl up for moving forward, down for moving backward.
      if (rawNewCurrentIndex > [self currentIndex]) {
         transitionOptions = UIViewAnimationOptionTransitionCurlUp;
      } else {
         transitionOptions = UIViewAnimationOptionTransitionCurlDown;
      }
      // Replace the current photo view with the new one on screen
      [UIView transitionFromView:[self currentPhotoView] toView:newPhotoView duration:1.0 options:transitionOptions completion:^(BOOL finished) {
         
      }];
   }
   [self setCurrentPhotoView:newPhotoView];
   
   // Finally, do the actual set
   _currentIndex = newCurrentIndex;
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   [self setCurrentIndex:[self startIndex]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return NO;
}

@end
