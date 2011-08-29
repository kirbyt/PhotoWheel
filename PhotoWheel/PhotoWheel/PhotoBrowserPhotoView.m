//
//  PhotoBrowserPhotoView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/27/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserPhotoView.h"
#import "PhotoBrowserViewController.h"

@interface PhotoBrowserPhotoView ()
@property (nonatomic, strong) UIImageView *imageView;

- (void)loadSubviewsWithFrame:(CGRect)frame;
- (BOOL)isZoomed;
@end

@implementation PhotoBrowserPhotoView

@synthesize photoBrowserViewController = photoBrowserViewController_;
@synthesize imageView = imageView_;

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self setDelegate:self];
      [self setMaximumZoomScale:5.0];
      [self setShowsHorizontalScrollIndicator:NO];
      [self setShowsVerticalScrollIndicator:NO];
      [self loadSubviewsWithFrame:frame];
      
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
   UIImageView *newImageView = [[UIImageView alloc] initWithFrame:frame];
   [newImageView setContentMode:UIViewContentModeScaleAspectFit];
   [self addSubview:newImageView];
   
   [self setImageView:newImageView];
}

- (void)setImage:(UIImage *)newImage 
{
   [[self imageView] setImage:newImage];
}

- (void)layoutSubviews 
{
   [super layoutSubviews];
   
   UIImageView *imageView = [self imageView];
   if ([self isZoomed] == NO && CGRectEqualToRect([self bounds], [imageView frame]) == NO) {
      [imageView setFrame:[self bounds]];
   }
}

- (BOOL)isZoomed
{
   return !([self zoomScale] == [self minimumZoomScale]);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center 
{
   // The following is derived from ScrollViewSuite sample project provided by Apple.
   // http://developer.apple.com/library/ios/#samplecode/ScrollViewSuite/Introduction/Intro.html

   CGRect zoomRect;
   
   // the zoom rect is in the content view's coordinates. 
   //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
   //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
   zoomRect.size.height = [self frame].size.height / scale;
   zoomRect.size.width = [self frame].size.width  / scale;
   
   // choose an origin so as to get the right center.
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

#pragma mark - Touch Gestures

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
   [self zoomToLocation:[recognizer locationInView:self]];
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
   [[self photoBrowserViewController] toggleChromeDisplay];
}

#pragma mark  - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   return [self imageView];
}

@end
