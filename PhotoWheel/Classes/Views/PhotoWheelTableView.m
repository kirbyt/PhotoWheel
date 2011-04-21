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
               NSLog(@"photowheel");
               return view;
            }
         }
      }

      // When the UITableView allowSelection property is YES, which is
      // the default, then user interaction on the photo wheel causes
      // the row to be selected. The problem with this is that selecting
      // a row will push a new view onto the stack. We want to override
      // this behavior so that interacting with the photo wheel within
      // the cell does not cause the row to be selected. 
      //
      // To get the desired behavior we must set the UITableView allowSelection
      // property to NO then programmatically select the row. The problem
      // with programmatically selecting the row is that the delegate methods
      // tableView:willSelectRowAtIndexPath and tableView:didSelectRowAtIndexPath:
      // are not called. Therefore, we must call the delegate methods ourself.

      if ([[self delegate] respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
         [[self delegate] tableView:self willSelectRowAtIndexPath:indexPathAtHitPoint];
      }
      
      [self selectRowAtIndexPath:indexPathAtHitPoint animated:YES scrollPosition:UITableViewScrollPositionNone];
      
      if ([[self delegate] respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
         [[self delegate] tableView:self didSelectRowAtIndexPath:indexPathAtHitPoint];
      }
   }
   
   return [super hitTest:point withEvent:event];   
}


@end
