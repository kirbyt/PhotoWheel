//
//  SpinGestureRecognizer.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinGestureRecognizer : UIGestureRecognizer

/**
 The rotation of the gesture in radians since its last change.
 */
@property (nonatomic, assign) CGFloat rotation;

@end
