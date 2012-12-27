//
//  SpinGestureRecognizer.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 10/18/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinGestureRecognizer : UIGestureRecognizer

/**
 The rotation of the gesture in radians since its last change.
 */
@property (nonatomic, assign) CGFloat rotation;

@end
