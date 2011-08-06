//
//  ImageGridViewCell.m
//  PhotoWheel
//
//  Created by Kirby Turner on 7/18/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "ImageGridViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ImageGridViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ImageGridViewCell

@synthesize imageView = imageView_;

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
      [self setBackgroundColor:[UIColor clearColor]];
      
      self.imageView = [[UIImageView alloc] initWithFrame:frame];
      [self addSubview:[self imageView]];
   }
   return self;
}


- (void)setImage:(UIImage *)image withShadow:(BOOL)shadow
{
   CALayer *layer = [self layer];
   id imageRef = (__bridge id)[image CGImage];
   [layer setContents:imageRef];
   [layer setShouldRasterize:YES];
   [layer setShadowOffset:CGSizeMake(0, 3)];
   
   if (shadow) {
      [layer setShadowOpacity:0.7];
   } else {
      [layer setShadowOpacity:0.0];
   }
}

+ (ImageGridViewCell *)imageGridViewCellWithSize:(CGSize)size
{
   ImageGridViewCell *newCell = [[ImageGridViewCell alloc] initWithSize:size];
   return newCell;
}

@end
