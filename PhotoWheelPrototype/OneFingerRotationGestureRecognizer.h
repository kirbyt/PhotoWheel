//
//  OneFingerRotationGesture.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/25/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIkit.h>

@interface OneFingerRotationGestureRecognizer : UIGestureRecognizer

/**
 The rotation of the gesture in radians since its last change.
 */
@property (nonatomic, assign) CGFloat rotation;

@end
