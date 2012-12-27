//
//  ImageDownloader.m
//  PhotoWheel
//
//  Created by Kirby Turner on 12/17/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, strong, readwrite) UIImage *image;                // 4
@property (nonatomic, strong) NSMutableData *receivedData;              // 5
@property (nonatomic, copy) ImageDownloaderCompletionBlock completion;  // 6
@end

@implementation ImageDownloader

- (void)downloadImageAtURL:(NSURL *)URL
                completion:(void(^)(UIImage *image, NSError*))completion// 7
{
   if (URL) {
      [self setCompletion:completion];
      [self setReceivedData:[[NSMutableData alloc] init]];
      NSURLRequest *request = [NSURLRequest requestWithURL:URL];
      NSURLConnection *connection = [[NSURLConnection alloc]
                                     initWithRequest:request
                                     delegate:self
                                     startImmediately:NO];
      [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSRunLoopCommonModes];              // 8
      [connection start];                                               // 9
   }
}

#pragma mark - NSURLConnection delegate methods                         // 10

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response                            // 11
{
   [[self receivedData] setLength:0];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data                                       // 12
{
   [[self receivedData] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection        // 13
{
   [self setImage:[UIImage imageWithData:[self receivedData]]];
   [self setReceivedData:nil];
   
   ImageDownloaderCompletionBlock completion = [self completion];
   completion([self image], nil);
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error                                     // 14
{
   [self setReceivedData:nil];
   
   ImageDownloaderCompletionBlock completion = [self completion];
   completion(nil, error);
}

@end
