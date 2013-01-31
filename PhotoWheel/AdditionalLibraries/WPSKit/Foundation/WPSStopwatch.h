/**
 **   WPSStopwatch
 **
 **   Created by Kirby Turner.
 **   Copyright (c) 2011 White Peak Software. All rights reserved.
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
#import <mach/mach_time.h>

extern NSString * const kWPSStopwatchStateDidChangeNotification;
extern NSString * const kWPSStopwatchDidReset;

@interface WPSStopwatch : NSObject 

@property(nonatomic, assign, readonly) uint64_t lastStart;
@property(nonatomic, assign, readonly) NSTimeInterval lastStartTimeInterval;
@property(nonatomic, assign, readonly, getter = isStated) BOOL started;

+ (WPSStopwatch *)stopwatch;

- (id)initWithLastStart:(uint64_t)lastStart;
- (id)initForWallClockTime;
- (id)initForWallClockTimeWithLastStart:(NSTimeInterval)lastStart;

- (void)reset;
- (void)start;
- (void)stop;
- (void)forceStop;

/**
 Returns the number of seconds elapsed as a decimal.
 This can be called without calling stop for incremental timing.
 */
- (double)elapsedSeconds;
/**
 Returns the elasped time as a formatted string.
 */
- (NSString *)elapsedTime;

@end
