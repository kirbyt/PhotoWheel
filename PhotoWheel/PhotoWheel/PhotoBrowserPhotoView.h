//
//  PhotoBrowserPhotoView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/27/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserViewController;

@interface PhotoBrowserPhotoView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, weak) PhotoBrowserViewController *photoBrowserViewController;

- (void)setImage:(UIImage *)newImage;
- (void)turnOffZoom;


@end
