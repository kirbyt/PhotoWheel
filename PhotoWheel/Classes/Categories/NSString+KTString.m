//
//  NSString+KTString.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/15/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "NSString+KTString.h"


@implementation NSString (NSString_KTString)

+ (NSString *)kt_stringWithUUID
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
   NSString *result = [NSString stringWithString:(NSString *)uuidString];
   
   CFRelease(uuidRef);
   CFRelease(uuidString);
   
   return result;
}

@end
