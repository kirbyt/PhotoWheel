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

#import "NSString+WPSKit.h"

@implementation NSString (WPSKit)

+ (NSString *)wps_stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
   NSString *result = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:encoding];
   return result;
}

+ (NSString *)wps_stringWithData:(NSData *)data
{
   return [self wps_stringWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)wps_stringWithUUID
{
   CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
   CFStringRef	uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
   
   // Create a new auto-release NSString to hold the UUID. This approach
   // is used to avoid leaking in a garbage collected environment.
   // 
   // From the Apple docs:
   // It is important to appreciate the asymmetry between Core Foundation and 
   // Cocoa—where retain, release, and autorelease are no-ops. If, for example, 
   // you have balanced a CFCreate… with release or autorelease, you will leak 
   // the object in a garbage collected environment:
   // http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/GarbageCollection/Articles/gcCoreFoundation.html
   //
   NSString *result = [NSString stringWithString:(__bridge NSString *)uuidString];
   
   CFRelease(uuidRef);
   CFRelease(uuidString);
   
   return result;
}

- (BOOL)wps_isURL
{
   NSURL *URL = [NSURL URLWithString:self];
   return (URL != nil);
}

- (BOOL)wps_containsSubstring:(NSString*)substring
{
   NSRange textRange = [[self lowercaseString] rangeOfString:[substring lowercaseString]];
   return (textRange.location != NSNotFound);
}

- (NSString*)wps_URLEncodedStringWithEncoding:(NSStringEncoding)encoding
{
   static NSString * const kTMLegalCharactersToBeEscaped = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\|~ ";
   
   CFStringRef encodedStringRef = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, (__bridge CFStringRef)kTMLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
   NSString *encodedString = (__bridge_transfer NSString *)encodedStringRef;
   // Note: Do not need to call CFRelease(encodedStringRef). This is done
   // for us by using __bridge_transfer.
   return [encodedString copy];
}

@end
