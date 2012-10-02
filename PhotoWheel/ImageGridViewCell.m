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
   [self setImageView:nil];
   [[self selectedImageView] setImage:[UIImage imageNamed:@"addphoto.png"]];
   [[self selectedImageView] setHidden:YES];
}

- (void)setSelected:(BOOL)selected
{
   [super setSelected:selected];
   [[self selectedImageView] setHidden:!selected];
}

@end
