//
//  _PhotoAlbum.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface _PhotoAlbum : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSSet* photos;

@end
