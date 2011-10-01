//
//  PhotoAlbum.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbum.h"
#import "Photo.h"

@implementation PhotoAlbum

- (void)awakeFromInsert
{
   [super awakeFromInsert];
   [self setDateAdded:[NSDate date]];
}

+ (PhotoAlbum *)newPhotoAlbumWithName:(NSString *)albumName
                            inContext:(NSManagedObjectContext *)context
{
   PhotoAlbum *newAlbum = [NSEntityDescription
                           insertNewObjectForEntityForName:@"PhotoAlbum"
                           inManagedObjectContext:context];
   [newAlbum setName:albumName];
   
   NSMutableOrderedSet *photos = [newAlbum mutableOrderedSetValueForKey:@"photos"];
   for (int index=0; index<10; index++) {
      Photo *placeholderPhoto = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"Photo"
                                 inManagedObjectContext:context];
      [photos addObject:placeholderPhoto];
   }
   return newAlbum;
}

+ (NSMutableArray *)allPhotoAlbumsInContext:(NSManagedObjectContext *)context
{
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                   initWithEntityName:@"PhotoAlbum"];
   
   NSArray *sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                             ascending:YES]];
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   NSError *error = nil;
   NSArray *photoAlbums = [context executeFetchRequest:fetchRequest
                                                 error:&error];
   
   if (photoAlbums != nil) {
      return [photoAlbums mutableCopy];
   } else {
      return [NSMutableArray array];
   }
}

@end
