//
//  ExternalSlideShowViewController.h
//  PhotoWheel
//
//  Created by Tom Harrington on 11/28/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExternalSlideShowViewController : UIViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) UIView *currentPhotoView;

@end
