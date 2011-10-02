//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 10/1/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendEmailController.h"                                            // 1

@protocol PhotoBrowserViewControllerDelegate;

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate, 
UIActionSheetDelegate, SendEmailControllerDelegate>                        // 2

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) id<PhotoBrowserViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger startAtIndex;
@property (nonatomic, assign, getter = isChromeHidden) BOOL chromeHidden;
@property (nonatomic, strong) NSTimer *chromeHideTimer;
@property (nonatomic, assign) CGFloat statusBarHeight;

- (void)toggleChrome:(BOOL)hide;
- (void)hideChrome;
- (void)startChromeDisplayTimer;
- (void)cancelChromeDisplayTimer;
- (void)toggleChromeDisplay;

@end

@protocol PhotoBrowserViewControllerDelegate <NSObject>
@required
- (NSInteger)photoBrowserViewControllerNumberOfPhotos:
(PhotoBrowserViewController *)photoBrowser;
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser 
                           imageAtIndex:(NSInteger)index;

@optional
- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser 
                deleteImageAtIndex:(NSInteger)index;

@end
