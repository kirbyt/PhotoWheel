//
//  PhotoBrowserPhotoView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/1/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserPhotoView.h"
#import "PhotoBrowserViewController.h"                                  // 7

@interface PhotoBrowserPhotoView ()                                     // 8
@property (nonatomic, strong) UIImageView *imageView;                   // 9

- (void)loadSubviewsWithFrame:(CGRect)frame;                            // 10
- (BOOL)isZoomed;                                                       // 11
@end

@implementation PhotoBrowserPhotoView

@synthesize photoBrowserViewController = _photoBrowserViewController;   // 12
@synthesize imageView = _imageView;

@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame                                       // 13
{
   self = [super initWithFrame:frame];
   if (self) {
      [self setDelegate:self];
      [self setMaximumZoomScale:5.0];
      [self setShowsHorizontalScrollIndicator:NO];
      [self setShowsVerticalScrollIndicator:NO];
      [self loadSubviewsWithFrame:frame];
      [self setBackgroundColor:[UIColor clearColor]];
      [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|
       UIViewAutoresizingFlexibleHeight];
      
      UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] 
                                           initWithTarget:self 
                                           action:@selector(doubleTapped:)];
      [doubleTap setNumberOfTapsRequired:2];
      [self addGestureRecognizer:doubleTap];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                     initWithTarget:self 
                                     action:@selector(tapped:)];
      [tap requireGestureRecognizerToFail:doubleTap];
      [self addGestureRecognizer:tap];
   }
   return self;
}

- (void)loadSubviewsWithFrame:(CGRect)frame                             // 14
{
   frame.origin = CGPointMake(0, 0);
   UIImageView *newImageView = [[UIImageView alloc] initWithFrame:frame];
   [newImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|
    UIViewAutoresizingFlexibleHeight];
   [newImageView setContentMode:UIViewContentModeScaleAspectFit];
   [self addSubview:newImageView];
   
   [self setImageView:newImageView];
}

- (void)setImage:(UIImage *)newImage                                    // 15
{
   [[self imageView] setImage:newImage];
}

- (BOOL)isZoomed                                                        // 16
{
   return !([self zoomScale] == [self minimumZoomScale]);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center      // 17
{
   // The following is derived from the ScrollViewSuite sample project 
   // provided by Apple:
   //
   // http://developer.apple.com/library/ios/#samplecode/ScrollViewSuite/Introduction/Intro.html
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

- (void)zoomToLocation:(CGPoint)location                                // 18
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

- (void)turnOffZoom                                                     // 19
{
   if ([self isZoomed]) {
      [self zoomToLocation:CGPointZero];
   }
}

#pragma mark - Touch gestures

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer               // 20
{
   [self zoomToLocation:[recognizer locationInView:self]];
}

- (void)tapped:(UITapGestureRecognizer *)recognizer                     // 21
{
   [[self photoBrowserViewController] toggleChromeDisplay];
}

#pragma mark  - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView       // 22
{
   return [self imageView];
}

@end
