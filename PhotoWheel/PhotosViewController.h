//
//  PhotosViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 11/12/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosViewController : UIViewController

@property (nonatomic, assign, readonly) NSInteger selectedPhotoIndex;
@property (nonatomic, assign, readonly) CGRect selectedPhotoFrame;

- (NSArray *)photos;
- (UIImage *)selectedPhotoImage;

@end
