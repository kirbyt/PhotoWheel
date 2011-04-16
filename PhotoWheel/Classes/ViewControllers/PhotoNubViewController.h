//
//  PhotoWheelImageViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/9/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoWheelViewController;
@class Nub;

@interface PhotoNubViewController : UIViewController <UIPopoverControllerDelegate>
{
    
}

@property (nonatomic, assign) PhotoWheelViewController *photoWheelViewController;
@property (nonatomic, retain, readonly) UIPopoverController *popoverController;
@property (nonatomic, retain) Nub *nub;

- (void)menuDidSelectImage:(UIImage *)image;
- (void)menuDidCancel;

@end
