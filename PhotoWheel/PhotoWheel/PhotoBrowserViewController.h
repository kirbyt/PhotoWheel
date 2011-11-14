//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 10/1/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendEmailController.h"

@protocol PhotoBrowserViewControllerDelegate;

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate, 
UIActionSheetDelegate, SendEmailControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) id<PhotoBrowserViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger startAtIndex;
@property (nonatomic, assign, getter = isChromeHidden) BOOL chromeHidden;
@property (nonatomic, strong) NSTimer *chromeHideTimer;
@property (nonatomic, assign) CGFloat statusBarHeight;
@property (strong, nonatomic) IBOutlet UIView *filterViewContainer;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;

- (void)toggleChrome:(BOOL)hide;
- (void)hideChrome;
- (void)startChromeDisplayTimer;
- (void)cancelChromeDisplayTimer;
- (void)toggleChromeDisplay;

// Actions that modify the image
- (IBAction)enhanceImage:(id)sender;
- (IBAction)zoomToFaces:(id)sender;
- (IBAction)applyFilter:(id)sender;

// Actions that save or restore the image
- (IBAction)revertToOriginal:(id)sender;
- (IBAction)saveImage:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@protocol PhotoBrowserViewControllerDelegate <NSObject>
@required
- (NSInteger)photoBrowserViewControllerNumberOfPhotos:(PhotoBrowserViewController *)photoBrowser;
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser imageAtIndex:(NSInteger)index;
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser smallImageAtIndex:(NSInteger)index;
- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser updateToNewImage:(UIImage *)image atIndex:(NSInteger)index;

@optional
- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser deleteImageAtIndex:(NSInteger)index;

@end
