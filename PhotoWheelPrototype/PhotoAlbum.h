//
//  PhotoAlbum.h
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 6/30/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "_PhotoAlbum.h"

@class Photo;

@interface PhotoAlbum : _PhotoAlbum

+ (NSMutableArray *)allPhotoAlbumsInContext:(NSManagedObjectContext *)context;
+ (PhotoAlbum *)newPhotoAlbumWithName:(NSString *)albumName inContext:(NSManagedObjectContext *)context;
@end
