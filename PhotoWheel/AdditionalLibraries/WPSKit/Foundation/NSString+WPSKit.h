/**
 **   NSString+WPSKit
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

#import <Foundation/Foundation.h>

@interface NSString (WPSKit)

/**
 Returns a string with data using the specific string encoding.
 */
+ (NSString *)wps_stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
/**
 Returns a string with data using NSUTF8StringEncoding.
 */
+ (NSString *)wps_stringWithData:(NSData *)data;

/**
 Returns a string containing a new UUID.
 */
+ (NSString *)wps_stringWithUUID;

/** 
 Returns YES if the string is a validate URL; otherwise NO is returned.
 */
- (BOOL)wps_isURL;

/**
 Returns YES if the string contains the substring.
 Note: The search for the substring is case insensitive.
 */
- (BOOL)wps_containsSubstring:(NSString*)substring;

/**
 Returns a URL encoded string. 
 The string is safe to be used as part of a URL.
 */
- (NSString*)wps_URLEncodedStringWithEncoding:(NSStringEncoding)encoding;

@end
