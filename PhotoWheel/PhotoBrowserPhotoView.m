//
//  PhotoBrowserPhotoView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/26/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserPhotoView.h"
#import "PhotoBrowserViewController.h"

@interface PhotoBrowserPhotoView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation PhotoBrowserPhotoView

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self setDelegate:self];
      [self setMaximumZoomScale:5.0];
      [self setShowsHorizontalScrollIndicator:NO];
      [self setShowsVerticalScrollIndicator:NO];
      [self loadSubviewsWithFrame:frame];
      [self setBackgroundColor:[UIColor clearColor]];
      [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight];
      
      UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
      [doubleTap setNumberOfTapsRequired:2];
      [self addGestureRecognizer:doubleTap];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
      [tap requireGestureRecognizerToFail:doubleTap];
      [self addGestureRecognizer:tap];
   }
   return self;
}

- (void)loadSubviewsWithFrame:(CGRect)frame
{
   frame.origin = CGPointMake(0, 0);
   UIImageView *newImageView = [[UIImageView alloc] initWithFrame:frame];
   [newImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   [newImageView setContentMode:UIViewContentModeScaleAspectFit];
   [self addSubview:newImageView];
   
   [self setImageView:newImageView];
}

- (void)setImage:(UIImage *)newImage
{
   [[self imageView] setImage:newImage];
}

- (BOOL)isZoomed
{
   return !([self zoomScale] == [self minimumZoomScale]);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
   // The following is derived from the ScrollViewSuite sample project
   // provided by Apple:
   // http://bit.ly/pYoPat
   
   CGRect zoomRect;
   
   // The zoom rect is in the content view's coordinates.
   // At a zoom scale of 1.0, it would be the size of the
   // imageScrollView's bounds.
   // As the zoom scale decreases, so more content is visible,
   // the size of the rect grows.
   zoomRect.size.height = [self frame].size.height / scale;
   zoomRect.size.width = [self frame].size.width  / scale;
   
   // Choose an origin so as to get the right center.
   zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
   zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
   
   return zoomRect;
}

- (void)zoomToLocation:(CGPoint)location
{
   float newScale;
   CGRect zoomRect;
   if ([self isZoomed]) {
      zoomRect = [self bounds];
   } else {
      newScale = [self maximumZoomScale];
      zoomRect = [self zoomRectForScale:newScale withCenter:location];
   }
   
   [self zoomToRect:zoomRect animated:YES];
}

- (void)turnOffZoom
{
   if ([self isZoomed]) {
      [self zoomToLocation:CGPointZero];
   }
}

#pragma mark - Touch gestures

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
   [self zoomToLocation:[recognizer locationInView:self]];
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
   [[self photoBrowserViewController] toggleChromeDisplay];
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   return [self imageView];
}

#pragma mark - Rotation

- (void)restoreAfterRotation
{
   [self turnOffZoom];
   [self setContentSize:[self bounds].size];
   [[self imageView] setFrame:[self bounds]];
}

@end
