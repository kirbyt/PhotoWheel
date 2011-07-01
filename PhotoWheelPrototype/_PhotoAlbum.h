//
//  _PhotoAlbum.h
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 6/30/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class _Photo;

@interface _PhotoAlbum : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSNumber *userSortPosition;
@end

@interface _PhotoAlbum (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(_Photo *)value;
- (void)removePhotosObject:(_Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end
