//
//  IconMenuView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/27/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "IconMenuView.h"
#import "IconButton.h"


@interface IconMenuView ()
- (void)layoutButtons;
@end


@implementation IconMenuView

@synthesize buttons = buttons_;

- (void)dealloc
{
   [buttons_ release], buttons_ = nil;
   [super dealloc];
}

- (void)setButtons:(NSArray *)buttons
{
   if (buttons_ != buttons) {
      [buttons retain];
      [buttons_ release];
      buttons_ = buttons;
      [self layoutButtons];
   }
}

- (void)layoutButtons
{
   NSArray *buttons = [self buttons];
   
   if ([buttons count] > 0) {
      // Evenly distribute the buttons across the view.
      CGRect buttonFrame = [[buttons objectAtIndex:0] frame];
      CGRect viewFrame = [self frame];
      NSInteger width = viewFrame.size.width;
      NSInteger height = viewFrame.size.height;
      CGFloat space = ((width / [buttons count]) / 2) - (buttonFrame.size.width / 2);
      NSInteger x = space;
      NSInteger y = (height - buttonFrame.size.height) / 2;
      for (IconButton *button in buttons) {
         CGRect newFrame = CGRectMake(x, y, buttonFrame.size.width, buttonFrame.size.height);
         [button setFrame:newFrame];
         [self addSubview:button];
         x = x + buttonFrame.size.width + (space * 2);
      }
   }
}

@end
