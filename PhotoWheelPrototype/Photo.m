//
//  Photo.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (UIImage *)image:(UIImage *)image scaleAspectToMaxSize:(CGFloat)newSize {
   CGSize size = [image size];
   CGFloat ratio;
   if (size.width > size.height) {
      ratio = newSize / size.width;
   } else {
      ratio = newSize / size.height;
   }
   
   CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
   UIGraphicsBeginImageContext(rect.size);
   [image drawInRect:rect];
   UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
   return scaledImage;
}

- (UIImage *)image:(UIImage *)image scaleAndCropToMaxSize:(CGSize)newSize {
   CGFloat largestSize = (newSize.width > newSize.height) ? newSize.width : newSize.height;
   CGSize imageSize = [image size];
   
   // Scale the image while mainting the aspect and making sure the 
   // the scaled image is not smaller then the given new size. In
   // other words we calculate the aspect ratio using the largest
   // dimension from the new size and the small dimension from the
   // actual size.
   CGFloat ratio;
   if (imageSize.width > imageSize.height) {
      ratio = largestSize / imageSize.height;
   } else {
      ratio = largestSize / imageSize.width;
   }
   
   CGRect rect = CGRectMake(0.0, 0.0, ratio * imageSize.width, ratio * imageSize.height);
   UIGraphicsBeginImageContext(rect.size);
   [image drawInRect:rect];
   UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
   
   // Crop the image to the requested new size maintaining
   // the inner most parts of the image.
   CGFloat offsetX = 0;
   CGFloat offsetY = 0;
   imageSize = [scaledImage size];
   if (imageSize.width < imageSize.height) {
      offsetY = (imageSize.height / 2) - (imageSize.width / 2);
   } else {
      offsetX = (imageSize.width / 2) - (imageSize.height / 2);
   }
   
   CGRect cropRect = CGRectMake(offsetX, offsetY,
                                imageSize.width - (offsetX * 2),
                                imageSize.height - (offsetY * 2));
   
   CGImageRef croppedImageRef = CGImageCreateWithImageInRect([scaledImage CGImage], cropRect);
   UIImage *newImage = [UIImage imageWithCGImage:croppedImageRef];
   CGImageRelease(croppedImageRef);
   
   return newImage;
}

- (void)saveImage:(UIImage *)newImage;
{
   NSData *originalImageData = UIImageJPEGRepresentation(newImage, 0.8);
   [self setOriginalImageData:originalImageData];
   // Save thumbnail
   CGSize thumbnailSize = CGSizeMake(75.0, 75.0);
   UIImage *thumbnailImage = [self image:newImage 
                   scaleAndCropToMaxSize:thumbnailSize];
   NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.8);
   [self setThumbnailImageData:thumbnailImageData];
   
   // Save large (screen-size) image
   CGRect screenBounds = [[UIScreen mainScreen] bounds];
   // Calculate size for retina displays
   CGFloat scale = [[UIScreen mainScreen] scale]; 
   CGFloat maxScreenSize = MAX(screenBounds.size.width,
                               screenBounds.size.height) * scale;
   
   CGSize imageSize = [newImage size];
   CGFloat maxImageSize = MAX(imageSize.width, imageSize.height) * scale;
   
   CGFloat maxSize = MIN(maxScreenSize, maxImageSize);
   UIImage *largeImage = [self image:newImage scaleAspectToMaxSize:maxSize];
   NSData *largeImageData = UIImageJPEGRepresentation(largeImage, 0.8);
   [self setLargeImageData:largeImageData];
}

- (UIImage *)originalImage;
{
   return [UIImage imageWithData:[self originalImageData]];
}

- (UIImage *)largeImage;
{
   return [UIImage imageWithData:[self largeImageData]];
}

- (UIImage *)thumbnailImage;
{
   return [UIImage imageWithData:[self thumbnailImageData]];
}

@end
