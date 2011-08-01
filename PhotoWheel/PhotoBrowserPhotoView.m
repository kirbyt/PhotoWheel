//
//  PhotoBrowserPhotoView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 7/31/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserPhotoView.h"
#import "PhotoBrowserViewController.h"

@interface PhotoBrowserPhotoView ()
@property (nonatomic, strong) UIImageView *imageView;

- (void)loadSubviewsWithFrame:(CGRect)frame;
- (BOOL)isZoomed;
- (void)toggleChromeDisplay;
@end

@implementation PhotoBrowserPhotoView

@synthesize scroller = scroller_;
@synthesize index = index_;
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

- (void)toggleChromeDisplay
{
   [[self scroller] toggleChromeDisplay];
}

- (BOOL)isZoomed
{
   return !([self zoomScale] == [self minimumZoomScale]);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center 
{
   
   CGRect zoomRect;
   
   // the zoom rect is in the content view's coordinates. 
   //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
   //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
   zoomRect.size.height = [self frame].size.height / scale;
   zoomRect.size.width  = [self frame].size.width  / scale;
   
   // choose an origin so as to get the right center.
   zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
   zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
   
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
   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleChromeDisplay) object:nil];
   [self zoomToLocation:[recognizer locationInView:self]];
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
   [self performSelector:@selector(toggleChromeDisplay) withObject:nil afterDelay:0.5];
}

#pragma mark  - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
   UIView *viewToZoom = imageView_;
   return viewToZoom;
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

- (void)setMaxMinZoomScalesForCurrentBounds
{
   CGSize boundsSize = self.bounds.size;
   CGSize imageSize = imageView_.bounds.size;
   
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
   CGPoint boundsCenter = [self convertPoint:oldCenter fromView:imageView_];
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
