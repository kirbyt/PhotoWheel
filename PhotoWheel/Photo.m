//
//  Photo.m
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 6/30/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "Photo.h"
#import "UIImage+PWCategory.h"

@interface Photo ()
- (void)createScaledImagesForImage:(UIImage *)originalImage;
@end

@implementation Photo

- (void)saveImage:(UIImage *)newImage;
{
   NSData *originalImageData = UIImageJPEGRepresentation(newImage, 0.8);
   [self setOriginalImageData:originalImageData];
   [self createScaledImagesForImage:newImage];
}

#pragma mark - Utility methods for reading/writing image data in external files
- (void)createScaledImagesForImage:(UIImage *)originalImage
{
   // Save thumbnail
   CGSize thumbnailSize = CGSizeMake(75.0, 75.0);
   UIImage *thumbnailImage = [originalImage pw_imageScaleAndCropToMaxSize:thumbnailSize];
   NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.8);
   [self setThumbnailImageData:thumbnailImageData];
   
   // Save large (screen-sized) image
   CGRect screenBounds = [[UIScreen mainScreen] bounds];
   CGFloat scale = [[UIScreen mainScreen] scale];  // Needed to calculate size for retina displays.
   CGFloat maxScreenSize = MAX(screenBounds.size.width, screenBounds.size.height) * scale;
   
   CGSize imageSize = [originalImage size];
   CGFloat maxImageSize = MAX(imageSize.width, imageSize.height) * scale;
   
   CGFloat maxSize = MIN(maxScreenSize, maxImageSize);
   UIImage *largeImage = [originalImage pw_imageScaleAspectToMaxSize:maxSize];
   NSData *largeImageData = UIImageJPEGRepresentation(largeImage, 0.8);
   [self setLargeImageData:largeImageData];
   
   // Save small image
   CGSize smallSize = CGSizeMake(100.0, 100.0);
   UIImage *smallImage = [originalImage pw_imageScaleAndCropToMaxSize:smallSize];
   NSData *smallImageData = UIImageJPEGRepresentation(smallImage, 0.8);
   [self setSmallImageData:smallImageData];
}

- (NSURL *)fileURLForAttributeNamed:(NSString *)attributeName
{
    if ([[self objectID] isTemporaryID]) {
        NSError *error = nil;
        [[self managedObjectContext] obtainPermanentIDsForObjects:[NSArray arrayWithObject:self] error:&error];
    }
   NSUInteger filenameID = [[[[self objectID] URIRepresentation] absoluteURL] hash];
   NSString *filename = [NSString stringWithFormat:@"%@-%ld", attributeName, filenameID];
   NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentsDirectory URLByAppendingPathComponent:filename];
}

- (void)setImageData:(NSData *)imageData forAttributeNamed:(NSString *)attributeName
{
   // Do the set
   [self willChangeValueForKey:attributeName];
   [self setPrimitiveValue:imageData forKey:attributeName];
   [self didChangeValueForKey:attributeName];
   
   // Now write to a file, since the attribute is transient.
    [imageData writeToURL:[self fileURLForAttributeNamed:attributeName] atomically:YES];
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
        if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
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

#pragma mark - Custom setters for non-synced image data
- (void)setLargeImageData:(NSData *)largeImageData
{
   [self setImageData:largeImageData forAttributeNamed:@"largeImageData"];
}

- (void)setSmallImageData:(NSData *)smallImageData
{
   [self setImageData:smallImageData forAttributeNamed:@"smallImageData"];
}

- (void)setThumbnailImageData:(NSData *)thumbnailImageData
{
   [self setImageData:thumbnailImageData forAttributeNamed:@"thumbnailImageData"];
}

#pragma mark - Custom getters for non-synced image data
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

#pragma mark - Convenience image accessors
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

- (UIImage *)smallImage
{
   return [UIImage imageWithData:[self smallImageData]];
}

@end
