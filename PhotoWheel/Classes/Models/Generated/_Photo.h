//
//  _Photo.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/28/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class _PhotoAlbum;

@interface _Photo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) _PhotoAlbum * photoAlbum;

@end
