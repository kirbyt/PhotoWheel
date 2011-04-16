//
//  PhotoWheel.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheel.h"
#import "NSString+KTString.h"


@implementation PhotoWheel

+ (NSString *)entityName
{
   return NSStringFromClass([self class]);
}

+ (PhotoWheel *)insertNewInManagedObjectContext:(NSManagedObjectContext *)context
{
   PhotoWheel *newPhotoWheel = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
   [newPhotoWheel setUuid:[NSString kt_stringWithUUID]];
   return newPhotoWheel;
}

@end
