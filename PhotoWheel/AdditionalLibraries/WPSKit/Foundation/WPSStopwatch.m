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

#import "WPSStopwatch.h"
#import <math.h>

NSString * const kWPSStopwatchStateDidChangeNotification = @"WPSStopwatch.stateDidChange";
NSString * const kWPSStopwatchDidReset = @"WPSStopwatch.didReset";


@interface WPSStopwatch ()
@property (nonatomic, assign) BOOL useWallClockTimer;
@property(nonatomic, assign, readwrite, getter = isStated) BOOL started;

// Fields used by elapse timer.
@property (nonatomic, assign) double conversionToSeconds;
@property (nonatomic, assign, readwrite) uint64_t lastStart;
@property (nonatomic, assign) uint64_t sum;

// Fields used by wall clock timer.
@property(nonatomic, assign, readwrite) NSTimeInterval lastStartTimeInterval;
@property (nonatomic, assign) NSTimeInterval sumTimeInterval;

- (void)broadcastStateDidChangeNotification;
- (void)broadcastDidResetNotification;
@end


@implementation WPSStopwatch

@synthesize lastStart = _lastStart;
@synthesize lastStartTimeInterval = _lastStartTimeInterval;
@synthesize started = _started;
@synthesize useWallClockTimer = _useWallClockTimer;
@synthesize conversionToSeconds = _conversionToSeconds;
@synthesize sum = _sum;
@synthesize sumTimeInterval = _sumTimeInterval;

+ (WPSStopwatch *)stopwatch
{
   WPSStopwatch *stopwatch = [[WPSStopwatch alloc] init];
   return stopwatch;
}

- (id)init 
{
   self = [super init];
   if (self) {
      [self setUseWallClockTimer:NO];
      
      mach_timebase_info_data_t info;
      mach_timebase_info(&info);
      double conversionToSeconds = 1e-9 * ((double)info.numer) / ((double)info.denom);
      [self setConversionToSeconds:conversionToSeconds];
      
      [self reset];
   }
   return self;
}

- (id)initWithLastStart:(uint64_t)lastStart 
{
   self = [self init];
   if (self) {
      [self setLastStart:lastStart];
      [self setStarted:YES];
   }
   return self;
}

- (id)initForWallClockTime 
{
   self = [super init];
   if (self) {
      [self setUseWallClockTimer:YES];
      [self reset];
   }
   return self;
}

- (id)initForWallClockTimeWithLastStart:(NSTimeInterval)lastStart
{
   self = [self initForWallClockTime];
   if (self) {
      [self setLastStartTimeInterval:lastStart];
      [self setStarted:YES];
   }
   return self;
}

- (void)reset 
{
   [self setStarted:NO];
   [self setSum:0];
   [self setSumTimeInterval:0];
}

- (void)start 
{
   if (![self isStated]) {
      if (![self useWallClockTimer]) {
         [self setLastStart:mach_absolute_time()];
      } else {
         [self setLastStartTimeInterval:[NSDate timeIntervalSinceReferenceDate]];
      }
      [self setStarted:YES];
      [self broadcastStateDidChangeNotification];
   }
}

- (void)stop 
{
   if ([self isStated]) {
      if (![self useWallClockTimer]) {
         uint64_t sum = [self sum] + mach_absolute_time() - [self lastStart];
         [self setSum:sum];
      } else {
         NSTimeInterval sum = [self sumTimeInterval] + [NSDate timeIntervalSinceReferenceDate] - [self lastStartTimeInterval];
         [self setSumTimeInterval:sum];
      }
      [self setStarted:NO];
      [self broadcastStateDidChangeNotification];
   }
}

- (void)forceStop 
{
   [self stop];
   [self reset];
   [self broadcastDidResetNotification];
}

#pragma mark Statistic-related Methods

- (double)elapsedSeconds 
{
   double lastElapseTimeInSeconds = 0;
   if ([self isStated]) {
      // Account for time between last start and now.
      if (![self useWallClockTimer]) {
         uint64_t extra = mach_absolute_time() - [self lastStart];
         lastElapseTimeInSeconds = [self conversionToSeconds] * ([self sum] + extra);
      } else {
         NSTimeInterval extraTimeInterval = [NSDate timeIntervalSinceReferenceDate] - [self lastStartTimeInterval];
         lastElapseTimeInSeconds = [self sumTimeInterval] + extraTimeInterval;
      }
      
   } else {
      if (![self useWallClockTimer]) {
         lastElapseTimeInSeconds = [self conversionToSeconds] * [self sum];
      } else {
         lastElapseTimeInSeconds = [self sumTimeInterval];
      }
   }
   return lastElapseTimeInSeconds;
}

- (NSString *)elapsedTime 
{
   NSString *elapsedTime = nil;
   double hours; 
   double minutes;
   double seconds;

   seconds = [self elapsedSeconds];
   
   hours = floor(seconds / 3600.);
   seconds -= 3600. * hours;
   minutes = floor(seconds / 60.);
   seconds -= 60. * minutes;

   // Format the seconds as a string with leading zeros.
   NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
   [formatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
   [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
   [formatter setMaximumFractionDigits:2];
   [formatter setPositiveFormat:@"#00.00"];  // Use @"#00.0" to display milliseconds as decimal value.
   NSString *secondsAsString = [formatter stringFromNumber:[NSNumber numberWithDouble:seconds]];
   
   elapsedTime = [NSString stringWithFormat:@"%.0f:%02.0f:%@", hours, minutes, secondsAsString];
   return elapsedTime;
}

#pragma mark - Broadcast Notification Methods

- (void)broadcastStateDidChangeNotification 
{
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc postNotificationName:kWPSStopwatchStateDidChangeNotification object:self];
}

- (void)broadcastDidResetNotification {
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc postNotificationName:kWPSStopwatchDidReset object:self];
}

@end
