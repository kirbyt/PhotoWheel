//
//  ExternalSlideShowViewController.m
//  PhotoWheel
//
//  Created by Tom Harrington on 11/28/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "ExternalSlideShowViewController.h"
#import "Photo.h"

@interface ExternalSlideShowViewController ()
@end

@implementation ExternalSlideShowViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentIndex:(NSInteger)rawNewCurrentIndex
{
   NSInteger currentIndex = rawNewCurrentIndex;
   if ((currentIndex == [self currentIndex]) &&
       ([[[self view] subviews] count] != 0))
   {
      return;
   }
   
   if (currentIndex < 0) {
      currentIndex = [[self photos] count] - 1;
   }
   if (currentIndex >= [[self photos] count]) {
      currentIndex = 0;
   }
   
   // Create a new image view for the current photo
   Photo *newPhoto = [[self photos] objectAtIndex:currentIndex];
   UIImage *newImage = [newPhoto largeImage];
   UIImageView *newPhotoView = [[UIImageView alloc] initWithImage:newImage];
   [newPhotoView setContentMode:UIViewContentModeScaleAspectFit];
   CGRect photoViewFrame = [[self view] bounds];
   [newPhotoView setFrame:photoViewFrame];
   [newPhotoView setAutoresizingMask:
      (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
   
   if ([self currentPhotoView] == nil) {
      // If there's no photo view yet, just add the new one.
      [[self view] addSubview:newPhotoView];
   } else {
      // If there's already a photo view, replace it with animation
      NSInteger transitionOptions;
      // Use the incoming value of the new index to decide if we're
      // moving forward or backward through the photos. Curl up for
      // moving forward, down for moving backward.
      if (rawNewCurrentIndex > [self currentIndex]) {
         transitionOptions = UIViewAnimationOptionTransitionCurlUp;
      } else {
         transitionOptions = UIViewAnimationOptionTransitionCurlDown;
      }
      
      // Replace the current photo view with the new one.
      [UIView transitionFromView:[self currentPhotoView]
                          toView:newPhotoView
                        duration:1.0
                         options:transitionOptions
                      completion:^(BOOL finished) {
                      }];
   }
   
   [self setCurrentPhotoView:newPhotoView];
   _currentIndex = currentIndex;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//   [super viewWillAppear:animated];
//   [self setCurrentIndex:[self startIndex]];
//}

- (BOOL)shouldAutorotate
{
   return NO;
}

@end
