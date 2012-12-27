//
//  _Photo.h
//  PhotoWheel
//
//  Created by Kirby Turner on 12/27/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class _PhotoAlbum;

@interface _Photo : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSData * largeImageData;
@property (nonatomic, retain) NSData * originalImageData;
@property (nonatomic, retain) NSData * smallImageData;
@property (nonatomic, retain) NSData * thumbnailImageData;
@property (nonatomic, retain) _PhotoAlbum *photoAlbum;

@end
