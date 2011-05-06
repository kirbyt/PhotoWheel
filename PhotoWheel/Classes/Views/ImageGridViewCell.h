//
//  PhotoGridViewCell.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"


@interface ImageGridViewCell : GridViewCell
{
    
}

+ (ImageGridViewCell *)imageGridViewCell;
+ (CGSize)size;

- (void)setImage:(UIImage *)image;

@end
