//
//  ImageDownloader.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, getter = isDownloading) BOOL downloading;
@property (nonatomic, strong) NSMutableData *receivedData;
@end

@implementation ImageDownloader

@synthesize delegate = delegate_;
@synthesize URL = URL_;
@synthesize image = image_;
@synthesize downloading = downloading_;
@synthesize receivedData = receivedData_;

- (UIImage *)image
{
   if (image_ == nil && [self isDownloading] == NO) {
      if ([self URL]) {
         self.receivedData = [[NSMutableData alloc] init];
         NSURLRequest *request = [NSURLRequest requestWithURL:[self URL]];
         NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
         [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
         [connection start];
         [self setDownloading:YES];
      }
   }
   return image_;
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
   [self setDownloading:NO];
   
   id <ImageDownloaderDelegate> delegate = [self delegate];
   if ([delegate respondsToSelector:@selector(imageDownloaderDidFinish:)]) {
      [delegate imageDownloaderDidFinish:self];
   }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
   [self setReceivedData:nil];
   [self setDownloading:NO];
   
   id <ImageDownloaderDelegate> delegate = [self delegate];
   if ([delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)]) {
      [delegate imageDownloader:self didFailWithError:error];
   }
}


@end
