//
//  PhotoAlbum.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "_PhotoAlbum.h"

@class Photo;

@interface PhotoAlbum : _PhotoAlbum

+ (PhotoAlbum *)newPhotoAlbumWithName:(NSString *)albumName inContext:(NSManagedObjectContext *)context;
+ (NSMutableArray *)allPhotoAlbumsInContext:(NSManagedObjectContext *)context;
- (Photo *)keyPhoto;

@end
