//
//  SlideShowViewController.m
//  PhotoWheel
//
//  Created by Tom Harrington on 8/18/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "SlideShowViewController.h"
#import "PhotoBrowserViewController.h"

@interface SlideShowViewController ()
@end

@implementation SlideShowViewController
@synthesize delegate = delegate_;
@synthesize currentIndex = currentIndex_;
@synthesize startIndex = startIndex_;
@synthesize currentPhotoView = currentPhotoView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   if (self) {
      // Custom initialization
   }
   return self;
}

- (void)didReceiveMemoryWarning
{
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   [self setCurrentIndex:[self startIndex]];
}

#pragma mark - Rotation handling
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // Return YES for the external screen slide show
   return NO;
}

#pragma mark - Custom setters
- (void)setCurrentIndex:(NSInteger)rawNewCurrentIndex
{
   if (rawNewCurrentIndex == [self currentIndex]) {
      return;
   }
   // If the new index is outside the existing range, wrap around to the other end.
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
   [newPhotoView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   
   if ([self currentPhotoView] == nil) {
      // If there's no photo view yet, just add it
      [[self view] addSubview:newPhotoView];
   } else {
      // If there is a photo view, do a nice animation
      NSInteger transitionOptions;
      // Use the original value of the new index to decide if we're moving forward or backward through the photos.
      // Curl up for moving forward, down for moving backward.
      if (rawNewCurrentIndex > [self currentIndex]) {
         transitionOptions = UIViewAnimationOptionTransitionCurlUp;
      } else {
         transitionOptions = UIViewAnimationOptionTransitionCurlDown;
      }
      // Replace the current photo view with the new one on screen
      [UIView transitionFromView:[self currentPhotoView] 
                          toView:newPhotoView
                        duration:1.0
                         options:transitionOptions
                      completion:^(BOOL finished) {
                         
                      }];
   }
   [self setCurrentPhotoView:newPhotoView];
   
   // Finally do the actual set
   currentIndex_ = newCurrentIndex;
}
@end
