//
//  ImageGridViewCell.h
//  PhotoWheel
//
//  Created by Kirby Turner on 9/29/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "GridView.h"

@interface ImageGridViewCell : GridViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIImageView *selectedIndicator;

+ (ImageGridViewCell *)imageGridViewCellWithSize:(CGSize)size;
- (id)initWithSize:(CGSize)size;

@end
