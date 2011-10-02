//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 10/1/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoBrowserViewControllerDelegate;

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate, 
UIActionSheetDelegate>                                                     // 1

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) id<PhotoBrowserViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger startAtIndex;
@property (nonatomic, assign, getter = isChromeHidden) BOOL chromeHidden; // 1
@property (nonatomic, strong) NSTimer *chromeHideTimer;                   // 2
@property (nonatomic, assign) CGFloat statusBarHeight;                    // 3

- (void)toggleChrome:(BOOL)hide;                                          // 4
- (void)hideChrome;                                                       // 5
- (void)startChromeDisplayTimer;                                          // 7
- (void)cancelChromeDisplayTimer;                                         // 8
- (void)toggleChromeDisplay;                                              // 1

@end

@protocol PhotoBrowserViewControllerDelegate <NSObject>
@required
- (NSInteger)photoBrowserViewControllerNumberOfPhotos:
(PhotoBrowserViewController *)photoBrowser;
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser 
                           imageAtIndex:(NSInteger)index;

@optional
- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser 
                deleteImageAtIndex:(NSInteger)index;                       // 2

@end
