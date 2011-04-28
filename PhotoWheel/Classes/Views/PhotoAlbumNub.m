//
//  PhotoAlbumNub.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/28/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoAlbumNub.h"


@implementation PhotoAlbumNub

- (void)dealloc
{
   [super dealloc];
}

+ (PhotoAlbumNub *)photoAlbumNub
{
   NSString *nibName = NSStringFromClass([self class]);
   UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
   NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
   // Verify that the top level object is in fact of the correct type.
   NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' does not contain top level view of type %@.", nibName, nibName);
   return [nibObjects objectAtIndex:0];
}

- (void)setImage:(UIImage *)image
{
   id imageView = [self viewWithTag:1];
   [imageView setImage:image];
}

- (void)setTitle:(NSString *)title
{
   id label = [self viewWithTag:2];
   [label setText:title];
}

@end
