//
//  ImageGridViewCell.h
//  PhotoWheel
//
//  Created by Kirby Turner on 7/18/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "GridView.h"

@interface ImageGridViewCell : GridViewCell

+ (ImageGridViewCell *)imageGridViewCell;
+ (CGSize)size;

- (void)setImage:(UIImage *)image withShadow:(BOOL)shadow;

@end