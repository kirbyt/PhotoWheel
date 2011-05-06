//
//  PhotoGridViewCell.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoGridViewCell.h"

@interface PhotoGridViewCell ()
@property (nonatomic, retain) UIImageView *imageView;
@end

@implementation PhotoGridViewCell

@synthesize imageView = imageView_;

- (void)dealloc
{
   [imageView_ release], imageView_ = nil;
   [super dealloc];
}

- (id)init
{
   CGSize size = [[self class] size];
   CGRect frame = CGRectMake(0, 0, size.width, size.height);
   self = [super initWithFrame:frame];
   if (self) {
      [self setBackgroundColor:[UIColor clearColor]];
      
      UIImageView *newImageView = [[UIImageView alloc] initWithFrame:frame];
      [self setImageView:newImageView];
      [newImageView release];
      
      [self addSubview:[self imageView]];
   }
   return self;
}

- (void)setImage:(UIImage *)image
{
   [[self imageView] setImage:image];
}

+ (PhotoGridViewCell *)imageGridViewCell
{
   PhotoGridViewCell *newCell = [[PhotoGridViewCell alloc] init];
   return [newCell autorelease];
}

+ (CGSize)size
{
   return CGSizeMake(100, 100);
}



@end
