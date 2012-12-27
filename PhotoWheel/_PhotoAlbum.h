//
//  _PhotoAlbum.h
//  PhotoWheel
//
//  Created by Kirby Turner on 12/27/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class _Photo;

@interface _PhotoAlbum : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photos;
@end

@interface _PhotoAlbum (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(_Photo *)value;
- (void)removePhotosObject:(_Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
