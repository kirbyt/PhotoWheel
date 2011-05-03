//
//  Photo.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "Photo.h"
#import "_PhotoAlbum.h"
#import "NSString+KTString.h"
#import "UIImage+KTCategory.h"
#import "UIApplication+KTApplication.h"


@interface Photo ()
- (NSString *)rootPath;
- (NSString *)imagePathWithFormat:(NSString *)format;
- (NSString *)thumbnailImagePath;
- (NSString *)smallImagePath;
- (NSString *)largeImagePath;
- (NSString *)originalImagePath;
- (void)saveImage:(UIImage *)image withPath:(NSString *)path;
- (void)saveAsThumbnailImage:(UIImage *)image;
- (void)saveAsSmallImage:(UIImage *)image;
- (void)saveAsLargeImage:(UIImage *)image;
- (void)saveAsOriginalImage:(UIImage *)image;
- (void)threaded_saveImage:(id)data;
@end

@implementation Photo

#pragma mark - Convenience Methods
+ (NSString *)entityName
{
   return NSStringFromClass([self class]);
}

+ (Photo *)insertNewInManagedObjectContext:(NSManagedObjectContext *)context
{
   Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
   [newPhoto setFileName:[NSString kt_stringWithUUID]];
   return newPhoto;
}

#pragma mark - Instance Methods

- (UIImage *)thumbnailImage
{
   UIImage *image = [UIImage imageWithContentsOfFile:[self thumbnailImagePath]];
   return image;
}

- (UIImage *)smallImage
{
   UIImage *image = [UIImage imageWithContentsOfFile:[self smallImagePath]];
   return image;
}

- (UIImage *)largeImage
{
   UIImage *image = [UIImage imageWithContentsOfFile:[self largeImagePath]];
   return image;
}

- (UIImage *)originalImage
{
   UIImage *image = [UIImage imageWithContentsOfFile:[self originalImagePath]];
   return image;
}

- (void)saveImage:(UIImage *)image
{
   [self performSelectorInBackground:@selector(threaded_saveImage:) withObject:image];
}

#pragma mark - Helper Methods

- (NSString *)rootPath
{
   NSString *photoAlbumUUID = [[self photoAlbum] uuid];
   NSString *packgeName = [photoAlbumUUID stringByAppendingPathExtension:@"photowheel"];
   NSString *path = [[UIApplication kt_documentPath] stringByAppendingPathComponent:packgeName];
   
   // Create the package if it does not already exists.
   BOOL isDirectory = NO;
   NSFileManager *fileManager = [[NSFileManager alloc] init];
   if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory) {
      NSDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSFileExtensionHidden, [NSNumber numberWithUnsignedLong:'phwl'], NSFileHFSCreatorCode, nil];
      NSError *error = nil;
      BOOL success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:&error];
      if (!success) {
         /*
          Replace this implementation with code to handle the error appropriately.
          
          abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
          
          */
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
   }
   [fileManager release];
   
   return path;
}

- (NSString *)imagePathWithFormat:(NSString *)format
{
   NSString *imageName = [NSString stringWithFormat:format, [self fileName]];
   NSString *path = [[self rootPath] stringByAppendingPathComponent:imageName];
   return path;
}

- (NSString *)thumbnailImagePath
{
   return [self imagePathWithFormat:@"%@-t.jpg"];
}

- (NSString *)smallImagePath
{
   return [self imagePathWithFormat:@"%@-s.jpg"];
}

- (NSString *)largeImagePath
{
   return [self imagePathWithFormat:@"%@-l.jpg"];
}

- (NSString *)originalImagePath
{
   return [self imagePathWithFormat:@"%@-o.jpg"];
}

- (void)saveImage:(UIImage *)image withPath:(NSString *)path
{
   NSData *jpg = UIImageJPEGRepresentation(image, 0.8);  // 1.0 = least compression, best quality
   [jpg writeToFile:path atomically:YES];
}

- (void)saveAsThumbnailImage:(UIImage *)image
{
   [self willChangeValueForKey:@"thumbnailImage"];
   CGSize size = CGSizeMake(75, 75);
   UIImage *newImage = [image kt_imageScaleAndCropToMaxSize:size];
   
   [self saveImage:newImage withPath:[self thumbnailImagePath]];
   [self didChangeValueForKey:@"thumbnailImage"];
}

- (void)saveAsSmallImage:(UIImage *)image
{
   [self willChangeValueForKey:@"smallImage"];
   CGSize size = CGSizeMake(100, 100);
   UIImage *newImage = [image kt_imageScaleAndCropToMaxSize:size];
   
   [self saveImage:newImage withPath:[self smallImagePath]];
   [self didChangeValueForKey:@"smallImage"];
}

- (void)saveAsLargeImage:(UIImage *)image
{
   [self willChangeValueForKey:@"largeImage"];
   CGRect screenBounds = [[UIScreen mainScreen] bounds];
   CGFloat scale = [[UIScreen mainScreen] scale];  // Needed to calculate size for retina displays.
   CGFloat maxScreenSize = MAX(screenBounds.size.width, screenBounds.size.height) * scale;

   CGSize imageSize = [image size];
   CGFloat maxImageSize = MAX(imageSize.width, imageSize.height) * scale;
   
   CGFloat maxSize = MIN(maxScreenSize, maxImageSize);

   UIImage *newImage = [image kt_imageScaleAspectToMaxSize:maxSize];
   
   [self saveImage:newImage withPath:[self largeImagePath]];
   [self didChangeValueForKey:@"largeImage"];
}

- (void)saveAsOriginalImage:(UIImage *)image
{
   [self willChangeValueForKey:@"originalImage"];
   [self saveImage:image withPath:[self originalImagePath]];
   [self didChangeValueForKey:@"originalImage"];
}

- (void)threaded_saveImage:(id)data
{
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   
   UIImage *image = data;
   
   [self saveAsThumbnailImage:image];
   [self saveAsSmallImage:image];
   [self saveAsLargeImage:image];
   [self saveAsOriginalImage:image];
   
   [pool drain];
}

@end
