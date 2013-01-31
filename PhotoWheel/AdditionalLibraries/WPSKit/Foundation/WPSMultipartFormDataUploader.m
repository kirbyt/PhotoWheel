/**
 **   WPSMultipartFormDataUploader
 **
 **   Created by Kirby Turner.
 **   Copyright (c) 2012 White Peak Software. All rights reserved.
 **
 **   Permission is hereby granted, free of charge, to any person obtaining 
 **   a copy of this software and associated documentation files (the 
 **   "Software"), to deal in the Software without restriction, including 
 **   without limitation the rights to use, copy, modify, merge, publish, 
 **   distribute, sublicense, and/or sell copies of the Software, and to permit 
 **   persons to whom the Software is furnished to do so, subject to the 
 **   following conditions:
 **
 **   The above copyright notice and this permission notice shall be included 
 **   in all copies or substantial portions of the Software.
 **
 **   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
 **   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 **   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
 **   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
 **   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 **   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 **   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **
 **/

#import "WPSMultipartFormDataUploader.h"
#import "UIApplication+WPSKit.h"
#import "NSString+WPSKit.h"

@interface WPSMultipartFormDataUploader ()
@property (nonatomic, copy) WPSMultipartFormDataUploaderCompletionBlock completion;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign) NSInteger numberOfAttempts;
- (NSURLRequest *)multipartFormRequestWithURL:(NSURL *)URL orderedFields:(NSArray *)fields;
- (void)startConnection;
- (void)incrementNumberOfAttempts;
@end

@implementation WPSMultipartFormDataUploader

@synthesize completion = _completion;
@synthesize receivedData = _receivedData;
@synthesize request = _request;
@synthesize retryCount = _retryCount;
@synthesize numberOfAttempts = _numberOfAttempts;

- (void)postToURL:(NSURL *)URL fields:(NSDictionary *)fields completion:(WPSMultipartFormDataUploaderCompletionBlock)completion
{
   NSMutableArray *orderedFields = [NSMutableArray array];
   [fields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      NSArray *item = [NSArray arrayWithObjects:key, obj, nil];
      [orderedFields addObject:item];
   }];
   
   [self postToURL:URL orderedFields:orderedFields completion:completion];
}

- (void)postToURL:(NSURL *)URL orderedFields:(NSArray *)fields completion:(WPSMultipartFormDataUploaderCompletionBlock)completion
{
   [self setCompletion:completion];
   [self setNumberOfAttempts:0];
   
   NSURLRequest *request = [self multipartFormRequestWithURL:URL orderedFields:fields];
   [self setRequest:request];
   [self startConnection];
}

- (void)startConnection
{
   [self setReceivedData:[[NSMutableData alloc] init]];

   NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self startImmediately:NO];
   [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
   [connection start];
   [[UIApplication sharedApplication] wps_pushNetworkActivity];
   [self incrementNumberOfAttempts];
}

- (void)incrementNumberOfAttempts
{
   NSInteger numberOfAttempts = [self numberOfAttempts];
   [self setNumberOfAttempts:numberOfAttempts + 1];
}

- (NSURLRequest *)multipartFormRequestWithURL:(NSURL *)URL orderedFields:(NSArray *)fields
{
   // Derived from code posted at: http://www.cocoadev.com/index.pl?HTTPFileUpload
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
   [request setTimeoutInterval:10];
   [request setHTTPMethod:@"POST"];
   
   NSString *boundary = @"0xKhTmLbOuNdArY";
   NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
   [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
   
   NSMutableData *body = [NSMutableData data];
   [fields enumerateObjectsUsingBlock:^(id itemArray, NSUInteger index, BOOL *stop) {
      if ([itemArray isKindOfClass:[NSArray class]] && [itemArray count] >= 2) {
         id key = [itemArray objectAtIndex:0];
         id value = [itemArray objectAtIndex:1];
         
         [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         
         if ([value isKindOfClass:[NSData class]]) {
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:value];

         } else if ([value isKindOfClass:[NSURL class]] && [value isFileURL]) {
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, [[value path] lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithContentsOfFile:[value path]]];
            
         } else {
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
         }
         
         [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
      }
   }];
   [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
   
   [request setHTTPBody:body];
   return request;
}

#pragma mark - NSURLConnection delegate methods

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
   [[UIApplication sharedApplication] wps_popNetworkActivity];
   
   WPSMultipartFormDataUploaderCompletionBlock completion = [self completion];
   completion([self receivedData], nil);
   [self setReceivedData:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   [[UIApplication sharedApplication] wps_popNetworkActivity];
   [self setReceivedData:nil];
   
   if ([self numberOfAttempts] < [self retryCount]) {
      [self performSelector:@selector(startConnection) withObject:nil afterDelay:1.0];
   } else {
      WPSMultipartFormDataUploaderCompletionBlock completion = [self completion];
      completion(nil, error);
   }
}

@end
