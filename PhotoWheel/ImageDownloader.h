//
//  ImageDownloader.h
//  PhotoWheel
//
//  Created by Kirby Turner on 12/17/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ImageDownloaderCompletionBlock)(UIImage *image, NSError *);

@interface ImageDownloader : NSObject

@property (nonatomic, strong, readonly) UIImage *image;

- (void)downloadImageAtURL:(NSURL *)URL completion:(ImageDownloaderCompletionBlock)completion;

@end
