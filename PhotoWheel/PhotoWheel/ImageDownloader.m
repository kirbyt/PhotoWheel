//
//  ImageDownloader.m
//  PhotoWheel
//
//  Created by Kirby Turner on 9/5/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) ImageDownloaderCompletionBlock completion;
@end

@implementation ImageDownloader

@synthesize image = image_;
@synthesize completion = completion_;
@synthesize receivedData = receivedData_;

- (void)downloadImageAtURL:(NSURL *)URL completion:(void(^)(UIImage *image, NSError*))completion
{
   if (URL) {
      [self setCompletion:completion];
      [self setReceivedData:[[NSMutableData alloc] init]];
      NSURLRequest *request = [NSURLRequest requestWithURL:URL];
      NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
      [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
      [connection start];
   }
}

#pragma mark - NSURLConnection delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
   [[self receivedData] setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
   [[self receivedData] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
   [self setImage:[UIImage imageWithData:[self receivedData]]];
   [self setReceivedData:nil];
   
   ImageDownloaderCompletionBlock completion = [self completion];
   completion([self image], nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
   [self setReceivedData:nil];
   
   ImageDownloaderCompletionBlock completion = [self completion];
   completion(nil, error);
}

@end
