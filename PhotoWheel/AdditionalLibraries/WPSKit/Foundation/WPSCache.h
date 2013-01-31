/**
 **   WPSCache
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

typedef enum {
   WPSCacheLocationMemory = 1,
   WPSCacheLocationFileSystem
} WPSCacheLocation;

#define kWPSCacheMaxCacheAge 60*60*24*7 // 1 week

@protocol WPSCache <NSObject>
@optional

/**
 Caches the data for the key to the location.
 The cache age defaults to kWPSCacheMaxCacheAge for items cached to the
 file system.
 */
- (void)cacheData:(NSData *)data forKey:(NSString *)key cacheLocation:(WPSCacheLocation)cacheLocation;

/**
 Caches the data for the key to the location for the cache age.
 The cache age only applies to items cached to the file system.
 */
- (void)cacheData:(NSData *)data forKey:(NSString *)key cacheLocation:(WPSCacheLocation)cacheLocation cacheAge:(NSInteger)cacheAge;

/**
 Returns the data found in the cache for the key.
 */
- (NSData *)dataForKey:(NSString *)key;

/**
 Returns the file URL to the cached data for the key.
 nil is returned if the cached item is in memory only.
 */
- (NSURL *)fileURLForKey:(NSString *)key;

/**
 Flushes both the memory and file system caches.
 */
- (void)flushCache;

/**
 Flushes the memory cache.
 */
- (void)flushMemoryCache;

/**
 Flushes the file system cache.
 */
- (void)flushFileSystemCache;

/**
 Removes all stale cache items from the file system.
 You do not have to call this method directly. It is called for you
 when the app is terminated or enters the background.
 */
- (void)cleanStaleCacheFromFileSystem;

@end


@interface WPSCache : NSObject <WPSCache>

+ (id)sharedCache;

@end

