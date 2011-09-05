//
//  UIImageAdditions.h
//
//  Created by Kirby Turner on 2/7/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (PWCategory)

- (UIImage *)pw_imageScaleAspectToMaxSize:(CGFloat)newSize;
- (UIImage *)pw_imageScaleAndCropToMaxSize:(CGSize)newSize;

@end
