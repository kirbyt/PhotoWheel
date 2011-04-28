//
//  PhotoAlbum.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "_PhotoAlbum.h"

@interface PhotoAlbum : _PhotoAlbum
{

}

+ (NSString *)entityName;
+ (PhotoAlbum *)insertNewInManagedObjectContext:(NSManagedObjectContext *)context;


@end
