//
//  PhotoAlbum.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbum.h"
#import "NSString+KTString.h"


@implementation PhotoAlbum

+ (NSString *)entityName
{
   return NSStringFromClass([self class]);
}

+ (PhotoAlbum *)insertNewInManagedObjectContext:(NSManagedObjectContext *)context
{
   PhotoAlbum *newPhotoAlbum = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
   [newPhotoAlbum setUuid:[NSString kt_stringWithUUID]];
   [newPhotoAlbum setDateAdded:[NSDate date]];
   return newPhotoAlbum;
}

- (Photo *)keyPhoto
{
   Photo *keyPhoto = [[self photos] anyObject];
   return keyPhoto;
}


@end
