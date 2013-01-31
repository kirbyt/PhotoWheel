/**
 **   UIApplication+WPSKit
 **
 **   Created by Kirby Turner.
 **   Copyright 2011 White Peak Software. All rights reserved.
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

#import <UIKit/UIKit.h>

@interface UIApplication (WPSKit)

#pragma mark - User Domain

/**
 Returns a string to the user's directory.
 This will create the directory if it does not exists.
 */
+ (NSString *)wps_userDomainPathForDirectory:(NSSearchPathDirectory)searchPathDirectory pathComponent:(NSString *)pathComponent;
/**
 Returns the URL to the user directory.
 This will not create the directory.
 */
+ (NSURL *)wps_userDomainURLForDirectory:(NSSearchPathDirectory)searchPathDirectory pathComponent:(NSString *)pathComponent;


#pragma mark Document Directory

/**
 Returns a string with the path to the user's document directory.
 This will create the directory if it does not exist.
 */
+ (NSString *)wps_documentDirectory;
/**
 Returns a string with the path to the user's document directory plus the appended path component.
 This will create the directory if it does not exist.
 */
+ (NSString *)wps_documentDirectoryByAppendingPathComponent:(NSString *)pathComponent;
/**
 Returns the URL to the user's document directory.
 This will not create the directory.
 */
+ (NSURL *)wps_documentDirectoryURL;
/**
 Returns the URL to the user's document directory plus the appended path component.
 This will not create the directory.
 */
+ (NSURL *)wps_documentDirectoryURLByAppendingPathComponent:(NSString *)pathComponent;


#pragma mark - Cache Directory

/**
 Returns a string with the path to the user's cache directory.
 This will create the directory if it does not exist.
 */
+ (NSString *)wps_cacheDirectory;
/**
 Returns the URL to the user's cache directory plus appended path component.
 This will create the directory if it does not exist.
 */
+ (NSString *)wps_cacheDirectoryByAppendingPathComponent:(NSString *)pathComponent;
/**
 Returns the URL to the user's cache directory.
 This will not create the directory.
 */
+ (NSURL *)wps_cacheDirectoryURL;
/**
 Returns the URL to the user's cache directory plus appended path component.
 This will not create the directory.
 */
+ (NSURL *)wps_cacheDirectoryURLByAppendingPathComponent:(NSString *)pathComponent;


#pragma mark - Temporary Directory

/**
 Returns a string to the user's temporary directory.
 */
+ (NSString *)wps_temporaryDirectory;
/**
 Returns a string to the user's temporary directory plus appended path component.
 This will create the directory if it does not exist.
 */
+ (NSString *)wps_temporaryDirectoryByAppendingPathComponent:(NSString *)pathComponent;
/**
 Returns the URL to the user's temporary directory.
 */
+ (NSURL *)wps_temporaryDirectoryURL;
/**
 Returns the URL to the user's temporary directory plus appended path component.
 This will not create the directory.
 */
+ (NSURL *)wps_temporaryDirectoryURLByAppendingPathComponent:(NSString *)pathComponent;


#pragma mark - Network Activity
@property (nonatomic, assign, readonly) NSInteger wps_networkActivityCount;

- (void)wps_pushNetworkActivity;
- (void)wps_popNetworkActivity;
- (void)wps_resetNetworkActivity;

@end
