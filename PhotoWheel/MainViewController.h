//
//  MainViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, assign, readonly) CGRect selectedPhotoFrame;
@property (nonatomic, strong, readonly) UIImage *selectedPhotoImage;

@end
