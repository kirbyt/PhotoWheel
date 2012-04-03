//
//  SlideShowViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 10/22/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoBrowserViewControllerDelegate;

@interface SlideShowViewController : UIViewController

@property (nonatomic, strong) id<PhotoBrowserViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, strong) UIView *currentPhotoView;

@end
