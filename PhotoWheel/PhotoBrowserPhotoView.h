//
//  PhotoBrowserPhotoView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 7/31/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserViewController;

@interface PhotoBrowserPhotoView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, assign) PhotoBrowserViewController *scroller;
@property (nonatomic, assign) NSInteger index;

- (void)setImage:(UIImage *)newImage;
- (void)turnOffZoom;

- (CGPoint)pointToCenterAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;

@end
