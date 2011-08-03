//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendEmailController.h"

@protocol PhotoBrowserViewControllerDelegate;

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, SendEmailControllerDelegate>

@property (nonatomic, strong) id<PhotoBrowserViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger startAtIndex;
@property (nonatomic, assign, getter = pushedFromFrame) CGRect pushFromFrame;

- (void)toggleChromeDisplay;

@end

@protocol PhotoBrowserViewControllerDelegate <NSObject>
@required
- (NSInteger)photoBrowserViewControllerNumberOfPhotos:(PhotoBrowserViewController *)photoBrowser;
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser imageAtIndex:(NSInteger)index;
- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser deleteImageAtIndex:(NSInteger)index;

@end