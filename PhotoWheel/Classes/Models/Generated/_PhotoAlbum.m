//
//  _PhotoAlbum.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "_PhotoAlbum.h"
#import "_Photo.h"


@implementation _PhotoAlbum
@dynamic name;
@dynamic uuid;
@dynamic photos;

- (void)addPhotosObject:(_Photo *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"photos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"photos"] addObject:value];
    [self didChangeValueForKey:@"photos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removePhotosObject:(_Photo *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"photos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"photos"] removeObject:value];
    [self didChangeValueForKey:@"photos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addPhotos:(NSSet *)value {    
    [self willChangeValueForKey:@"photos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"photos"] unionSet:value];
    [self didChangeValueForKey:@"photos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removePhotos:(NSSet *)value {
    [self willChangeValueForKey:@"photos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"photos"] minusSet:value];
    [self didChangeValueForKey:@"photos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
