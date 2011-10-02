//
//  ImageGridViewCell.h
//  PhotoWheel
//
//  Created by Kirby Turner on 9/29/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "GridView.h"

@interface ImageGridViewCell : GridViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;         // 1
@property (nonatomic, strong, readonly) UIImageView *selectedIndicator; // 2

+ (ImageGridViewCell *)imageGridViewCellWithSize:(CGSize)size;          // 3
- (id)initWithSize:(CGSize)size;

@end
