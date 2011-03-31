//
//  UIViewController+KTCompositeView.m
//  CompositeViewsSample
//
//  Created by Kirby Turner on 11/1/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "UIViewController+KTCompositeView.h"


@implementation UIViewController (KTCompositeView)

- (void)addSubview:(UIView *)subview toPlaceholder:(UIView *)placeholder
{
   if (subview) {
      // Size the subview to fill the placeholder.
      CGRect frame = [placeholder bounds];
      [subview setFrame:frame];
      // Replace the background color in the placeholder with the 
      // color used in the subview.
      [placeholder setBackgroundColor:[subview backgroundColor]];
      
      [placeholder addSubview:subview];
   }
}

@end
