//
//  UIBezierPath+ShadowPath.h
//  ShadowBoxing
//
//  Created by Joe Ricioppo on 4/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIBezierPath.h>

@interface UIBezierPath (ShadowPath)

+ (UIBezierPath*)bezierPathWithCurvedShadowForRect:(CGRect)rect;

@end
