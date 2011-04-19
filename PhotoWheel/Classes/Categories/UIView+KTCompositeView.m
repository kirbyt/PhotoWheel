//
//  UIView+KTCompositeView.m
//  CompositeViewsSample
//
//  Created by Kirby Turner on 11/1/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "UIView+KTCompositeView.h"


@implementation UIView (KTCompositeView)

- (void)kt_addSubview:(UIView *)subview
{
   if (subview) {
      // Size the subview to fill the placeholder.
      CGRect frame = [self bounds];
      [subview setFrame:frame];
      // Replace the background color in the placeholder with the 
      // color used in the subview.
      [self setBackgroundColor:[subview backgroundColor]];
      
      [self addSubview:subview];
   }
}

@end
