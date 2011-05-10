//
//  PhotoView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/10/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoView.h"
#import "PhotoBrowserViewController.h"

@interface PhotoView ()
@property (nonatomic, retain) UIImageView *imageView;
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center;
- (void)zoomToPoint:(CGPoint)point;
@end

@implementation PhotoView

@synthesize photoBrowserViewController = photoBrowserViewController_;
@synthesize index = index_;
@synthesize imageView = imageView_;

- (void)dealloc
{
   [imageView_ release], imageView_ = nil;
   [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self setDelegate:self];
      [self setMaximumZoomScale:5.0];
      [self setShowsHorizontalScrollIndicator:NO];
      [self setShowsVerticalScrollIndicator:NO];
      
      UIImageView *newImageView = [[UIImageView alloc] initWithFrame:frame];
      [newImageView setContentMode:UIViewContentModeScaleAspectFit];
      [self setImageView:newImageView];
      [newImageView release];
      
      [self addSubview:[self imageView]];
      
      UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
      [doubleTap setNumberOfTapsRequired:2];
      [self addGestureRecognizer:doubleTap];

      UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
      [singleTap requireGestureRecognizerToFail:doubleTap];
      [singleTap setNumberOfTapsRequired:1];
      [self addGestureRecognizer:singleTap];

      [singleTap release];
      [doubleTap release];
   }
   return self;
}

- (void)layoutSubviews
{
   [super layoutSubviews];
   
   if ([self isZooming] == NO && CGRectEqualToRect([self bounds], [[self imageView] frame]) == NO) {
      [[self imageView] setFrame:[self bounds]];
   }
}

#pragma mark - Gesture Recognizer Handlers

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
   CGPoint touchPoint = [recognizer locationInView:self];
   [self zoomToPoint:touchPoint];
}

- (void)singleTapped:(UITapGestureRecognizer *)recognizer
{
   [[self photoBrowserViewController] toggleChromeDisplay];
}

#pragma mark - Helper Methods for Zooming

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
   CGRect zoomRect;
   
   // The zoom rect is in the content view's coordinates. 
   //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
   //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
   zoomRect.size.height = [self frame].size.height / scale;
   zoomRect.size.width = [self frame].size.width  / scale;
   
   // Choose an origin so as to get the right center.
   zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
   zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
   
   return zoomRect;
}

- (void)zoomToPoint:(CGPoint)point
{
   CGFloat newScale;
   CGRect zoomRect;
   if ([self isZooming]) {
      zoomRect = [self bounds];
   } else {
      newScale = [self maximumZoomScale];
      zoomRect = [self zoomRectForScale:newScale withCenter:point];
   }
   
   [self zoomToRect:zoomRect animated:YES];
}

#pragma mark - Public Methods

- (void)setImage:(UIImage *)image
{
   [[self imageView] setImage:image];
}

- (void)turnOffZoom
{
   if ([self isZooming]) {
      [self zoomToPoint:CGPointZero];
   }
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   return [self imageView];
}

#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

- (void)setMaxMinZoomScalesForCurrentBounds
{
   CGSize boundsSize = self.bounds.size;
   CGSize imageSize = [self imageView].bounds.size;
   
   // calculate min/max zoomscale
   CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
   CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
   CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
   
   // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
   // maximum zoom scale to 0.5.
   CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
   
   // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
   if (minScale > maxScale) {
      minScale = maxScale;
   }
   
   self.maximumZoomScale = maxScale;
   self.minimumZoomScale = minScale;
}

// returns the center point, in image coordinate space, to try to restore after rotation. 
- (CGPoint)pointToCenterAfterRotation
{
   CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
   return [self convertPoint:boundsCenter toView:imageView_];
}

// returns the zoom scale to attempt to restore after rotation. 
- (CGFloat)scaleToRestoreAfterRotation
{
   CGFloat contentScale = self.zoomScale;
   
   // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
   // allowable scale when the scale is restored.
   if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
      contentScale = 0;
   
   return contentScale;
}

- (CGPoint)maximumContentOffset
{
   CGSize contentSize = self.contentSize;
   CGSize boundsSize = self.bounds.size;
   return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
   return CGPointZero;
}

// Adjusts content offset and scale to try to preserve the old zoomscale and center.
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
{    
   // Step 1: restore zoom scale, first making sure it is within the allowable range.
   self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
   
   
   // Step 2: restore center point, first making sure it is within the allowable range.
   
   // 2a: convert our desired center point back to our own coordinate space
   CGPoint boundsCenter = [self convertPoint:oldCenter fromView:[self imageView]];
   // 2b: calculate the content offset that would yield that center point
   CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0, 
                                boundsCenter.y - self.bounds.size.height / 2.0);
   // 2c: restore offset, adjusted to be within the allowable range
   CGPoint maxOffset = [self maximumContentOffset];
   CGPoint minOffset = [self minimumContentOffset];
   offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
   offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
   self.contentOffset = offset;
}

@end
