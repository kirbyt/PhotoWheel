//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoBrowserViewControllerDelegate;

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) id<PhotoBrowserViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger startAtIndex;
@property (nonatomic, assign, getter = pushedFromFrame) CGRect pushFromFrame;

- (void)toggleChromeDisplay;

@property (strong, nonatomic) IBOutlet UIView *filterViewContainer;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;

- (IBAction)enhanceImage:(id)sender;
- (IBAction)zoomToFaces:(id)sender;
- (IBAction)applyFilter:(id)sender;

- (IBAction)revertToOriginal:(id)sender;
- (IBAction)saveImage:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@protocol PhotoBrowserViewControllerDelegate <NSObject>
@required
- (NSInteger)photoBrowserViewControllerNumberOfPhotos:(PhotoBrowserViewController *)photoBrowser;
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser imageAtIndex:(NSInteger)index;
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser smallImageAtIndex:(NSInteger)index;
- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser deleteImageAtIndex:(NSInteger)index;
- (void)photoBrowserViewController:(PhotoBrowserViewController *)photoBrowser updateToNewImage:(UIImage *)image atIndex:(NSInteger)index;

@end