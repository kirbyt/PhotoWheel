//
//  PhotoAlbum.m
//  PhotoWheelPrototype
//
//  Created by Tom Harrington on 6/30/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbum.h"

@implementation PhotoAlbum

- (Photo *)keyPhoto;
{
	Photo *keyPhoto = [[self photos] anyObject];
	return keyPhoto;
}

@end
