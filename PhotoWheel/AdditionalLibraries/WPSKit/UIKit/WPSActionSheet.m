/**
 **   WPSActionSheet
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

#import "WPSActionSheet.h"

@interface WPSActionSheet ()
@property (nonatomic, copy) WPSActionSheetCompletionBlock completion;
@end

@implementation WPSActionSheet

@synthesize completion = _completion;

- (id)initWithCompletion:(WPSActionSheetCompletionBlock)completion
{
   self = [super init];
   if (self) {
      [self setDelegate:self];
      [self setCompletion:completion];
   }
   return self;
}

- (id)initWithTitle:(NSString *)title completion:(WPSActionSheetCompletionBlock)completion cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
   self = [super init];
   if (self) {
      
      [self setTitle:title];
      [self setDelegate:self];
      
      if (destructiveButtonTitle) {
         [self addButtonWithTitle:destructiveButtonTitle];
         [self setDestructiveButtonIndex:0];
      }
      
      va_list args;
      va_start(args, otherButtonTitles);
      for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
      {
         [self addButtonWithTitle:arg];
      }
      va_end(args);
      
      if (cancelButtonTitle) {
         [self addButtonWithTitle:cancelButtonTitle];
         [self setCancelButtonIndex:[self numberOfButtons] - 1];
      }
      
      [self setCompletion:completion];
   }
   return self;
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   WPSActionSheetCompletionBlock completion = [self completion];
   completion(buttonIndex);
}

@end
