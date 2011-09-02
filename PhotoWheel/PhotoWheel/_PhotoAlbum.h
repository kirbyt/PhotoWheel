//
//  _PhotoAlbum.h
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 7/1/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface _PhotoAlbum : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * userSortPosition;
@property (nonatomic, retain) NSOrderedSet *photos;
@property (nonatomic, retain) Photo *keyPhoto;
@end

@interface _PhotoAlbum (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
@end
