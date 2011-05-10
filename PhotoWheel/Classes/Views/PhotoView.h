//
//  PhotoView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/10/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserViewController;

@interface PhotoView : UIScrollView <UIScrollViewDelegate>
{
    
}

@property (nonatomic, assign) PhotoBrowserViewController *photoBrowserViewController;
@property (nonatomic, assign) NSInteger index;

- (void)setImage:(UIImage *)image;
- (void)turnOffZoom;

@end
