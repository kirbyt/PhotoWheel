//
//  PhotoWheelImageViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/9/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoWheelViewController;

@interface PhotoNubViewController : UIViewController <UIPopoverControllerDelegate>
{
    
}

@property (nonatomic, assign) PhotoWheelViewController *photoWheelViewController;
@property (nonatomic, retain) UIPopoverController *popoverController;


@end
