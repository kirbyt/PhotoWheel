//
//  PhotoBrowserPhotoView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 10/1/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserViewController;                                      // 1

@interface PhotoBrowserPhotoView : UIScrollView <UIScrollViewDelegate>  // 2

@property (nonatomic, assign) NSInteger index;                          // 3
@property (nonatomic, weak) PhotoBrowserViewController 
*photoBrowserViewController;                                            // 4

- (void)setImage:(UIImage *)newImage;                                   // 5
- (void)turnOffZoom;                                                    // 6

@end
