//
//  PhotoBrowserPhotoView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 11/26/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserViewController;

@interface PhotoBrowserPhotoView : UIScrollView <UIScrollViewDelegate>


@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) PhotoBrowserViewController *photoBrowserViewController;

- (void)setImage:(UIImage *)newImage;
- (void)turnOffZoom;

- (void)restoreAfterRotation;

@end
