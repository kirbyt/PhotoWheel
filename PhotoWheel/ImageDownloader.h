//
//  ImageDownloader.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ImageDownloaderCompletionBlock)(UIImage *image, NSError *);

@interface ImageDownloader : NSObject

@property (nonatomic, strong, readonly) UIImage *image;

- (void)downloadImageAtURL:(NSURL *)URL completion:(ImageDownloaderCompletionBlock)completion;

@end
