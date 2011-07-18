//
//  Photo.h
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 6/30/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "_Photo.h"

@interface Photo : _Photo

- (void)saveImage:(UIImage *)newImage;

- (UIImage *)originalImage;
- (UIImage *)largeImage;
- (UIImage *)thumbnailImage;
- (UIImage *)smallImage;

@end
