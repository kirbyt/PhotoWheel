//
//  SpinGestureRecognizer.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 10/18/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "SpinGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation SpinGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   // Fail when more than 1 finger detected.
   if ([[event touchesForGestureRecognizer:self] count] > 1) {
      [self setState:UIGestureRecognizerStateFailed];
   }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   // Perform final check to make sure a tap was not misinterpreted.
   if ([self state] == UIGestureRecognizerStateChanged) {
      [self setState:UIGestureRecognizerStateEnded];
   } else {
      [self setState:UIGestureRecognizerStateFailed];
   }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   [self setState:UIGestureRecognizerStateFailed];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   if ([self state] == UIGestureRecognizerStatePossible) {
      [self setState:UIGestureRecognizerStateBegan];
   } else {
      [self setState:UIGestureRecognizerStateChanged];
   }
   
   // We can look at any touch object since we know we
   // have only 1. If there were more than 1,
   // touchesBegan:withEvent: would have failed the recognizer.
   UITouch *touch = [touches anyObject];
   
   // To rotate with one finger, we simulate a second finger.
   // The second finger is on the opposite side of the virtual
   // circle that represents the rotation gesture.
   
   UIView *view = [self view];
   CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
   CGPoint currentTouchPoint = [touch locationInView:view];
   CGPoint previousTouchPoint = [touch previousLocationInView:view];
   
   CGFloat angleInRadians = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x);
   
   [self setRotation:angleInRadians];
}

@end
