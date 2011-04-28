//
//  Photo.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "_Photo.h"

#define NUB_IMAGE_SIZE_WIDTH 80
#define NUB_IMAGE_SIZE_HEIGHT 80

@interface Photo : _Photo 
{

}

+ (NSString *)entityName;
+ (Photo *)insertNewInManagedObjectContext:(NSManagedObjectContext *)context;

- (UIImage *)smallImage;
- (UIImage *)largeImage;
- (UIImage *)originalImage;
- (void)saveImage:(UIImage *)image;

@end
