//
//  Photo.m
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 6/30/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "Photo.h"
#import "UIImage+PWCategory.h"

@implementation Photo

- (void)saveImage:(UIImage *)newImage;
{
	NSData *originalImageData = UIImageJPEGRepresentation(newImage, 0.8);
	[self setOriginalImageData:originalImageData];
	
	// Save thumbnail
	CGSize thumbnailSize = CGSizeMake(75.0, 75.0);
	UIImage *thumbnailImage = [newImage pw_imageScaleAndCropToMaxSize:thumbnailSize];
	NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.8);
	[self setThumbnailImageData:thumbnailImageData];

	// Save small image
	CGSize smallSize = CGSizeMake(100.0, 100.0);
	UIImage *smallImage = [newImage pw_imageScaleAndCropToMaxSize:smallSize];
	NSData *smallImageData = UIImageJPEGRepresentation(smallImage, 0.8);
	[self setSmallImageData:smallImageData];
	
	// Save large (screen-sized) image
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	CGFloat scale = [[UIScreen mainScreen] scale];  // Needed to calculate size for retina displays.
	CGFloat maxScreenSize = MAX(screenBounds.size.width, screenBounds.size.height) * scale;
	
	CGSize imageSize = [newImage size];
	CGFloat maxImageSize = MAX(imageSize.width, imageSize.height) * scale;
	
	CGFloat maxSize = MIN(maxScreenSize, maxImageSize);
	UIImage *largeImage = [newImage pw_imageScaleAspectToMaxSize:maxSize];
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

- (UIImage *)smallImage
{
	return [UIImage imageWithData:[self smallImageData]];
}

@end
