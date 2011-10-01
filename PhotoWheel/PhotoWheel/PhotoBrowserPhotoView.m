//
//  PhotoBrowserPhotoView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/1/11.
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

@synthesize photoBrowserViewController = _photoBrowserViewController;
@synthesize imageView = _imageView;

@synthesize index = _index;

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

- (void)loadSubviewsWithFrame:(CGRect)frame
{
   frame.origin = CGPointMake(0, 0);
   UIImageView *newImageView = [[UIImageView alloc] initWithFrame:frame];
   [newImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|
    UIViewAutoresizingFlexibleHeight];
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
   //
   // http://developer.apple.com/library/ios/#samplecode/ScrollViewSuite/Introduction/Intro.html
   
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

#pragma mark  - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   return [self imageView];
}

#pragma mark - Rotation methods

/**
 ** Methods called during rotation to preserve the zoomScale and the visible 
 ** portion of the image.
 **
 ** The following code comes from the Apple sample project PhotoScroller
 ** available at
 ** http://developer.apple.com/library/prerelease/ios/#samplecode/PhotoScroller/Introduction/Intro.html
 **
 **/

- (void)setMaxMinZoomScalesForCurrentBounds
{
   CGSize boundsSize = self.bounds.size;
   CGSize imageSize = [[self imageView] bounds].size;
   
   // Calculate min/max zoom scale
   CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
   CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
   CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
   
   // On high-resolution screens we have double the pixel density, 
   // so we will be seeing every pixel if we limit the maximum
   // zoom scale to 0.5.
   CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
   
   // Don't let minScale exceed maxScale. (If the image is smaller 
   // than the screen, we don't want to force it to be zoomed.) 
   if (minScale > maxScale) {
      minScale = maxScale;
   }
   
   self.maximumZoomScale = maxScale;
   self.minimumZoomScale = minScale;
}

// Returns the center point, in image coordinate space, to try 
// to restore after rotation. 
- (CGPoint)pointToCenterAfterRotation
{
   CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), 
                                      CGRectGetMidY(self.bounds));
   return [self convertPoint:boundsCenter toView:[self imageView]];
}

// Returns the zoom scale to attempt to restore after rotation. 
- (CGFloat)scaleToRestoreAfterRotation
{
   CGFloat contentScale = self.zoomScale;
   
   // If we're at the minimum zoom scale, preserve that by returning 0, 
   // which will be converted to the minimum allowable scale when the 
   // scale is restored.
   if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
      contentScale = 0;
   
   return contentScale;
}

- (CGPoint)maximumContentOffset
{
   CGSize contentSize = self.contentSize;
   CGSize boundsSize = self.bounds.size;
   return CGPointMake(contentSize.width - boundsSize.width, 
                      contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
   return CGPointZero;
}

// Adjusts content offset and scale to try to preserve the old 
// zoom scale and center.
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
{    
   // Step 1: Restore zoom scale, first making sure it is within 
   // the allowable range.
   self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, 
                                                   oldScale));
   
   
   // Step 2: Restore center point, first making sure it is within 
   // the allowable range.
   
   // Step 2a: Convert the desired center point back to our own 
   // coordinate space.
   CGPoint boundsCenter = [self convertPoint:oldCenter fromView:[self imageView]];
   // Step 2b: Calculate the content offset that would yield that center
   // point.
   CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0, 
                                boundsCenter.y - self.bounds.size.height / 2.0);
   // Step 2c: Restore the offset, adjusted to be within the allowable 
   // range.
   CGPoint maxOffset = [self maximumContentOffset];
   CGPoint minOffset = [self minimumContentOffset];
   offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
   offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
   self.contentOffset = offset;
}

@end
