//
//  PhotoWheelTableView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/20/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelTableView.h"
#import "PhotoWheelTableViewCell.h"
#import "PhotoWheelView.h"
#import "PhotoNubView.h"


@implementation PhotoWheelTableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
   NSIndexPath *indexPathAtHitPoint = [self indexPathForRowAtPoint:point];
   id cell = [self cellForRowAtIndexPath:indexPathAtHitPoint];
   if (cell) {
      NSArray *subViews = [[cell contentView] subviews];
      for (UIView *view in subViews) {
         if ([view isKindOfClass:[PhotoWheelView class]]) {
            CGPoint convertedPoint = [view convertPoint:point fromView:self];
            if ([view pointInside:convertedPoint withEvent:event]) {
               return view;
            }
         }
      }
   }
   return [super hitTest:point withEvent:event];   
}
@end
