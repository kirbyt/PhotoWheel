//
//  PhotoWheelViewCell.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 10/17/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "WheelView.h"

@interface PhotoWheelViewCell : WheelViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *label;

+ (PhotoWheelViewCell *)photoWheelViewCell;

@end
