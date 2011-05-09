//
//  IconButton.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/8/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "IconButton.h"

#define VIEW_WIDTH 75
#define VIEW_HEIGHT 75

@interface IconButton ()
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *label;
@end

@implementation IconButton

@synthesize imageView = imageView_;
@synthesize label = label_;

- (void)dealloc
{
   [imageView_ release], imageView_ = nil;
   [label_ release], label_ = nil;
   [super dealloc];
}

- (void)commonInit
{
   UIImageView *newImageView = [[UIImageView alloc] init];
   [newImageView setContentMode:UIViewContentModeCenter];
   [newImageView setImage:[UIImage imageNamed:@"photoDefault.png"]];
   [self setImageView:newImageView];
   [newImageView release];
   
   UILabel *newLabel = [[UILabel alloc] init];
   [newLabel setTextColor:[UIColor colorWithWhite:0.375 alpha:1.000]];
   [newLabel setTextAlignment:UITextAlignmentCenter];
   [newLabel setText:NSStringFromClass([self class])];
   [self setLabel:newLabel];
   [newLabel release];
   
   [self addSubview:[self imageView]];
   [self addSubview:[self label]];
}

- (id)init
{
   self = [super initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT)];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, VIEW_WIDTH, VIEW_HEIGHT)];
   if (self) {
      [self commonInit];
   }
   return self;
}

+ (IconButton *)iconButtonWithImage:(UIImage*)image title:(NSString *)title
{
   IconButton *newIconButton = [[IconButton alloc] init];
   [newIconButton setImage:image];
   [newIconButton setTitle:title];
   
   return [newIconButton autorelease];
}

- (void)setImage:(UIImage *)image
{
   [[self imageView] setImage:image];
}

- (void)setTitle:(NSString *)title
{
   [[self label] setText:title];
}

- (void)layoutSubviews
{
   CGSize viewSize = [self frame].size;
   CGRect imageFrame = CGRectMake(0, 0, viewSize.width, viewSize.height - 31);
   CGRect labelFrame = CGRectMake(0, viewSize.height - 21, viewSize.width, 21);
   
   [[self imageView] setFrame:imageFrame];
   [[self label] setFrame:labelFrame];
}


@end
