//
//  Nub.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "Nub.h"
#import "NSString+KTString.h"


@implementation Nub

+ (NSString *)entityName
{
   return NSStringFromClass([self class]);
}

+ (Nub *)insertNewInManagedObjectContext:(NSManagedObjectContext *)context
{
   Nub *newNub = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
   [newNub setBaseFileName:[NSString stringWithUUID]];
   return newNub;
}

@end
