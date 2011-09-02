//
//  PhotoAlbum.m
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 6/30/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbum.h"

@implementation PhotoAlbum

+ (NSMutableArray *)allPhotoAlbumsInContext:(NSManagedObjectContext *)context;
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PhotoAlbum"];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"userSortPosition" ascending:YES]];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSError *error = nil;
	NSArray *photoAlbums = [context executeFetchRequest:fetchRequest error:&error];
	
	if (photoAlbums != nil) {
		return [photoAlbums mutableCopy];
	} else {
		return [NSMutableArray array];
	}
}

+ (PhotoAlbum *)newPhotoAlbumWithName:(NSString *)albumName inContext:(NSManagedObjectContext *)context;
{
	PhotoAlbum *newAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"PhotoAlbum" inManagedObjectContext:context];
	[newAlbum setName:albumName];
	
	NSMutableOrderedSet *photos = [newAlbum mutableOrderedSetValueForKey:@"photos"];
	for (int index=0; index<10; index++) {
		Photo *placeholderPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		[photos addObject:placeholderPhoto];
	}
	return newAlbum;
}

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self setDateAdded:[NSDate date]];
}

@end
