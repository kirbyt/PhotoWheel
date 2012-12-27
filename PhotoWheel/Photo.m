//
//  Photo.m
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 10/30/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (UIImage *)image:(UIImage *)image scaleAspectToMaxSize:(CGFloat)newSize
{
   CGSize size = [image size];
   CGFloat ratio;
   if (size.width > size.height) {
      ratio = newSize / size.width;
   } else {
      ratio = newSize / size.height;
   }
   
   CGRect rect =
      CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
   UIGraphicsBeginImageContext(rect.size);
   [image drawInRect:rect];
   UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
   return scaledImage;
}

- (UIImage *)image:(UIImage *)image scaleAndCropToMaxSize:(CGSize)size
{
   // Adjust for retina display.
   CGFloat scale = [[UIScreen mainScreen] scale];
   CGSize newSize = CGSizeMake(size.width * scale, size.height * scale);

   CGFloat largestSize =
      (newSize.width > newSize.height) ? newSize.width : newSize.height;
   CGSize imageSize = [image size];
   
   // Scale the image while maintaining the aspect and making sure the
   // the scaled image is not smaller then the given new size. In
   // other words we calculate the aspect ratio using the largest
   // dimension from the new size and the smaller dimension from the
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
   
   CGImageRef croppedImageRef =
      CGImageCreateWithImageInRect([scaledImage CGImage], cropRect);
   UIImage *newImage = [UIImage imageWithCGImage:croppedImageRef];
   CGImageRelease(croppedImageRef);
   
   return newImage;
}

- (void)createScaledImagesForImage:(UIImage *)originalImage
{
   // Save thumbnail
   CGSize thumbnailSize = CGSizeMake(75.0, 75.0);
   UIImage *thumbnailImage = [self image:originalImage scaleAndCropToMaxSize:thumbnailSize];
   NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage,
                                                          0.8);
   [self setThumbnailImageData:thumbnailImageData];
   
   // Save small image
   CGSize smallSize = CGSizeMake(100.0, 100.0);
   UIImage *smallImage = [self image:originalImage scaleAndCropToMaxSize:smallSize];
   NSData *smallImageData = UIImageJPEGRepresentation(smallImage, 0.8);
   [self setSmallImageData:smallImageData];
   
   // Save large (screen-size) image
   CGRect screenBounds = [[UIScreen mainScreen] bounds];
   // Calculate size for retina displays
   CGFloat scale = [[UIScreen mainScreen] scale];
   CGFloat maxScreenSize = MAX(screenBounds.size.width,
                               screenBounds.size.height) * scale;
   
   CGSize imageSize = [originalImage size];
   CGFloat maxImageSize = MAX(imageSize.width,
                              imageSize.height) * scale;
   
   CGFloat maxSize = MIN(maxScreenSize, maxImageSize);
   UIImage *largeImage = [self image:originalImage
                scaleAspectToMaxSize:maxSize];
   NSData *largeImageData = UIImageJPEGRepresentation(largeImage, 0.8);
   [self setLargeImageData:largeImageData];
}

- (void)saveImage:(UIImage *)newImage
{
   NSData *originalImageData = UIImageJPEGRepresentation(newImage, 0.8);
   [self setOriginalImageData:originalImageData];
   [self createScaledImagesForImage:newImage];
}

- (UIImage *)originalImage
{
   return [UIImage imageWithData:[self originalImageData]];
}

- (UIImage *)largeImage
{
   return [UIImage imageWithData:[self largeImageData]];
}

- (UIImage *)thumbnailImage
{
   return [UIImage imageWithData:[self thumbnailImageData]];
}

- (UIImage *)smallImage
{
   return [UIImage imageWithData:[self smallImageData]];
}

- (NSURL *)fileURLForAttributeNamed:(NSString *)attributeName
{
   if ([[self objectID] isTemporaryID]) {
      NSError *error = nil;
      [[self managedObjectContext]
       obtainPermanentIDsForObjects:[NSArray arrayWithObject:self]
       error:&error];
   }
   NSUInteger filenameID = [[[[self objectID] URIRepresentation]
                             absoluteURL] hash];
   NSString *filename = [NSString stringWithFormat:@"%@-%d",
                         attributeName, filenameID];
   NSURL *documentsDirectory = [[[NSFileManager defaultManager]
                                 URLsForDirectory:NSDocumentDirectory
                                 inDomains:NSUserDomainMask]
                                lastObject];
   return [documentsDirectory URLByAppendingPathComponent:filename];
}

- (void)setImageData:(NSData *)imageData
   forAttributeNamed:(NSString *)attributeName
{
   // Do the set
   [self willChangeValueForKey:attributeName];
   [self setPrimitiveValue:imageData forKey:attributeName];
   [self didChangeValueForKey:attributeName];
   
   // Now write to a file, since the attribute is transient.
   [imageData writeToURL:[self fileURLForAttributeNamed:attributeName]
              atomically:YES];
}

- (void)setLargeImageData:(NSData *)largeImageData
{
   [self setImageData:largeImageData
       forAttributeNamed:@"largeImageData"];
}

- (void)setSmallImageData:(NSData *)smallImageData
{
   [self setImageData:smallImageData
       forAttributeNamed:@"smallImageData"];
}

- (void)setThumbnailImageData:(NSData *)thumbnailImageData
{
   [self setImageData:thumbnailImageData
       forAttributeNamed:@"thumbnailImageData"];
}

- (NSData *)imageDataForAttributeNamed:(NSString *)attributeName
{
   // Get the existing data for the attribute, if possible.
   [self willAccessValueForKey:attributeName];
   NSData *imageData = [self primitiveValueForKey:attributeName];
   [self didAccessValueForKey:attributeName];
   
   // If we don't already have image data, get it.
   if (imageData == nil) {
      NSURL *fileURL = [self fileURLForAttributeNamed:attributeName];
      if ([[NSFileManager defaultManager] fileExistsAtPath:
           [fileURL path]]) {
         // Read image data from the appropriate file, if it exists.
         imageData = [NSData dataWithContentsOfURL:fileURL];
         [self willChangeValueForKey:attributeName];
         [self setPrimitiveValue:imageData forKey:attributeName];
         [self didChangeValueForKey:attributeName];
      } else {
         // If the file doesn't exist, create it.
         [self createScaledImagesForImage:[self originalImage]];
         [self willAccessValueForKey:attributeName];
         imageData = [self primitiveValueForKey:attributeName];
         [self didAccessValueForKey:attributeName];
      }
   }
   
   return imageData;
}

- (NSData *)largeImageData
{
   return [self imageDataForAttributeNamed:@"largeImageData"];
}

- (NSData *)smallImageData
{
   return [self imageDataForAttributeNamed:@"smallImageData"];
}

- (NSData *)thumbnailImageData
{
   return [self imageDataForAttributeNamed:@"thumbnailImageData"];
}

@end
