//
//  _PhotoAlbum.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/28/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class _Photo;

@interface _PhotoAlbum : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) _Photo * photos;

@end
