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
@property (nonatomic, strong) UIImageView *selectedIndicator;
@end

@implementation ImageGridViewCell

@synthesize selected = selected_;
@synthesize imageView = imageView_;
@synthesize selectedIndicator = selectedIndicator_;

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
      
      NSInteger baseSize = 29;
      self.selectedIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(size.width - baseSize - 4, size.height - baseSize - 4, baseSize, baseSize)];
      [self addSubview:[self selectedIndicator]];
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

- (void)setSelected:(BOOL)selected
{
   selected_ = selected;
   
   UIImage *image = nil;
   if (selected) {
      image = [UIImage imageNamed:@"addphoto.png"];
   }
   [[self selectedIndicator] setImage:image];
}

+ (ImageGridViewCell *)imageGridViewCellWithSize:(CGSize)size
{
   ImageGridViewCell *newCell = [[ImageGridViewCell alloc] initWithSize:size];
   return newCell;
}

@end
