//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/7/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoBrowserViewControllerDataSource;

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>
{
    
}

@property (nonatomic, assign) id<PhotoBrowserViewControllerDataSource> dataSource;
@property (nonatomic, assign) NSInteger startAtIndex;

@end


@protocol PhotoBrowserViewControllerDataSource <NSObject>
@required
- (NSInteger)photoBrowserViewControllerNumberOfPhotos:(PhotoBrowserViewController *)controller;

@optional
- (UIImage *)photoBrowserViewController:(PhotoBrowserViewController *)controller photoAtIndex:(NSInteger)index;
- (BOOL)photoBrowserViewController:(PhotoBrowserViewController *)controller deletePhotoAtIndex:(NSInteger)index;

@end