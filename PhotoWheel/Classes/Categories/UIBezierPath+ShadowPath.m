//
//  UIBezierPath+ShadowPath.m
//  ShadowBoxing
//
//  Created by Joe Ricioppo on 4/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIBezierPath+ShadowPath.h"

static const CGFloat offset = 10.0;
static const CGFloat curve = 5.0;

@implementation UIBezierPath (ShadowPath)

+ (UIBezierPath*)bezierPathWithCurvedShadowForRect:(CGRect)rect {

	UIBezierPath *path = [UIBezierPath bezierPath];	
	
	CGPoint topLeft		 = rect.origin;
	CGPoint bottomLeft	 = CGPointMake(0.0, CGRectGetHeight(rect)+offset);
	CGPoint bottomMiddle = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)-curve);	
	CGPoint bottomRight	 = CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect)+offset);
	CGPoint topRight	 = CGPointMake(CGRectGetWidth(rect), 0.0);
	
	[path moveToPoint:topLeft];	
	[path addLineToPoint:bottomLeft];
	[path addQuadCurveToPoint:bottomRight
				 controlPoint:bottomMiddle];
	[path addLineToPoint:topRight];
	[path addLineToPoint:topLeft];
	[path closePath];
	
	return path;
}

@end
