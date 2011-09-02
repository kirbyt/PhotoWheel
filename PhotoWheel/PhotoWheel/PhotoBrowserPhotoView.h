//
//  PhotoBrowserPhotoView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/30/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserViewController;

@interface PhotoBrowserPhotoView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) PhotoBrowserViewController *photoBrowserViewController;

- (void)setImage:(UIImage *)newImage;
- (void)turnOffZoom;

- (CGPoint)pointToCenterAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;

@end
