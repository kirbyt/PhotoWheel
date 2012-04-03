//
//  ImageGridViewCell.m
//  PhotoWheel
//
//  Created by Kirby Turner on 9/29/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "ImageGridViewCell.h"

@interface ImageGridViewCell ()
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) UIImageView *selectedIndicator;
@end

@implementation ImageGridViewCell

@synthesize imageView = _imageView;
@synthesize selectedIndicator = _selectedIndicator;

- (void)commonInitWithSize:(CGSize)size
{
   CGRect frame = CGRectMake(0, 0, size.width, size.height);
   [self setBackgroundColor:[UIColor clearColor]];
   
   self.imageView = [[UIImageView alloc] initWithFrame:frame];
   [self addSubview:[self imageView]];
   
   NSInteger baseSize = 29;
   self.selectedIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(size.width - baseSize - 4, size.height - baseSize - 4, baseSize, baseSize)];
   [[self selectedIndicator] setHidden:YES];
   
   [self addSubview:[self selectedIndicator]];
}

- (id)init
{
   CGSize size = CGSizeMake(100, 100);
   self = [self initWithSize:size];
   if (self) {
      
   }
   return self;
}

- (id)initWithSize:(CGSize)size
{
   CGRect frame = CGRectMake(0, 0, size.width, size.height);
   self = [super initWithFrame:frame];
   if (self) {
      [self commonInitWithSize:size];
   }
   return self;
}

- (void)setSelected:(BOOL)selected
{
   [super setSelected:selected];
   [[self selectedIndicator] setHidden:!selected];
}

+ (ImageGridViewCell *)imageGridViewCellWithSize:(CGSize)size
{
   ImageGridViewCell *newCell = [[ImageGridViewCell alloc] initWithSize:size];
   return newCell;
}

@end
