//
//  PhotoWheel.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheel.h"
#import "Nub.h"


@implementation PhotoWheel
@dynamic uuid;
@dynamic name;
@dynamic nubs;

- (void)addNubsObject:(Nub *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"nubs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"nubs"] addObject:value];
    [self didChangeValueForKey:@"nubs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeNubsObject:(Nub *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"nubs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"nubs"] removeObject:value];
    [self didChangeValueForKey:@"nubs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addNubs:(NSSet *)value {    
    [self willChangeValueForKey:@"nubs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"nubs"] unionSet:value];
    [self didChangeValueForKey:@"nubs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeNubs:(NSSet *)value {
    [self willChangeValueForKey:@"nubs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"nubs"] minusSet:value];
    [self didChangeValueForKey:@"nubs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
