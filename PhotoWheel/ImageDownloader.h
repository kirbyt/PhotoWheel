//
//  ImageDownloader.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject

@property (nonatomic, weak) id<ImageDownloaderDelegate> delegate;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong, readonly) UIImage *image;

@end

@protocol ImageDownloaderDelegate <NSObject>
@optional
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
- (void)imageDownloader:(ImageDownloader *)downloader didFailWithError:(NSError *)error;
@end