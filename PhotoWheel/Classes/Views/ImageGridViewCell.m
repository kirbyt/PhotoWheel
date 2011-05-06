//
//  PhotoGridViewCell.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "ImageGridViewCell.h"

@implementation ImageGridViewCell

+ (ImageGridViewCell *)imageGridViewCell
{
   ImageGridViewCell *newCell = [[ImageGridViewCell alloc] init];
   return [newCell autorelease];
}

+ (CGSize)size
{
   return CGSizeMake(100, 100);
}


- (id)init
{
   CGSize size = [[self class] size];
   CGRect frame = CGRectMake(0, 0, size.width, size.height);
   self = [super initWithFrame:frame];
   if (self) {
      [self setBackgroundColor:[UIColor yellowColor]];
   }
   return self;
}

- (void)setImage:(UIImage *)image
{
   
}

@end
