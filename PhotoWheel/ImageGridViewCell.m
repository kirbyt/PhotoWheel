//
//  ImageGridViewCell.m
//  PhotoWheel
//
//  Created by Kirby Turner on 9/29/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "ImageGridViewCell.h"

@implementation ImageGridViewCell

- (void)prepareForReuse
{
   [[self imageView] setImage:nil];
   [[self selectedImageView] setImage:nil];
}

@end
