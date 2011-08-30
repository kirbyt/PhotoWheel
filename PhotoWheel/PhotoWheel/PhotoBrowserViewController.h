//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/26/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoBrowserViewControllerDelegate;

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) id<PhotoBrowserViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger startAtIndex;

- (void)toggleChromeDisplay;

@end

@protocol PhotoBrowserViewControllerDelegate <NSObject>
@required
- (NSInteger)photoBrowserViewControllerNumberOfPhotos:(PhotoBrowserViewController *)photoBrowser;
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser imageAtIndex:(NSInteger)index;

@optional
- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser deleteImageAtIndex:(NSInteger)index;
@end