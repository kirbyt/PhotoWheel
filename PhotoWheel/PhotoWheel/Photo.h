//
//  Photo.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "_Photo.h"

@interface Photo : _Photo

- (void)saveImage:(UIImage *)newImage;

- (UIImage *)originalImage;
- (UIImage *)largeImage;
- (UIImage *)thumbnailImage;
- (UIImage *)smallImage;

@end
