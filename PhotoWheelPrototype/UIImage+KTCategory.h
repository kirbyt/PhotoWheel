//
//  UIImageAdditions.h
//
//  Created by Kirby Turner on 2/7/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (KTCategory)

- (UIImage *)kt_imageScaleAspectToMaxSize:(CGFloat)newSize;
- (UIImage *)kt_imageScaleAndCropToMaxSize:(CGSize)newSize;

@end
