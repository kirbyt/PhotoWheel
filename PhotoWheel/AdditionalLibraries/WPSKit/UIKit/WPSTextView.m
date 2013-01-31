/**
 **   WPSTextView
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

#import "WPSTextView.h"

@interface WPSTextView ()
@property (nonatomic, strong) UILabel *placeholder;
@end

@implementation WPSTextView

@synthesize placeholderText = _placeholderText;
@synthesize placeholderColor = _placeholderColor;
@synthesize placeholder = _placeholder;

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit
{
   [self setPlaceholderText:@""];
   [self setPlaceholderColor:[UIColor lightGrayColor]];
   
   CGRect frame = CGRectMake(8, 8, self.bounds.size.width - 16, 0);
   
   UILabel *placeholder = [[UILabel alloc] initWithFrame:frame];
   [placeholder setLineBreakMode:UILineBreakModeWordWrap];
   [placeholder setNumberOfLines:0];
   [placeholder setBackgroundColor:[UIColor clearColor]];
   [placeholder setAlpha:0];
   [placeholder setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
   [self addSubview:placeholder];
   [placeholder sizeToFit];
   [self sendSubviewToBack:placeholder];
   
   [self setPlaceholder:placeholder];
   
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)awakeFromNib
{
   [super awakeFromNib];
   [self commonInit];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (void)textChanged:(NSNotification *)notification
{
   if ([[self placeholderText] length] == 0) {
      return;
   }
   
   if ([[self text] length] == 0) {
      [[self placeholder] setAlpha:1.0];
   } else {
      [[self placeholder] setAlpha:0.0];
   }
}

- (void)drawRect:(CGRect)rect
{
   if ([[self placeholderText] length] > 0) {
      [[self placeholder] setAlpha:0.0];
      [[self placeholder] setFont:[self font]];
      [[self placeholder] setTextColor:[self placeholderColor]];
      [[self placeholder] setText:[self placeholderText]];
      [[self placeholder] sizeToFit];
   }
   
   if ([[self text] length] == 0 && [[self placeholderText] length] > 0) {
      [[self placeholder] setAlpha:1.0];
   }
}

@end
