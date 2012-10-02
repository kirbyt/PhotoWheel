//
//  ImageGridViewCell.h
//  PhotoWheel
//
//  Created by Kirby Turner on 9/29/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGridViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *selectedImageView;

@end
