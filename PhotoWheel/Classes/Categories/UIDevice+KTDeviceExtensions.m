//
//  UIDevice+KTDeviceExtensions.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/10/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "UIDevice+KTDeviceExtensions.h"


@implementation UIDevice (UIDevice_KTDeviceExtensions)

+ (BOOL)kt_hasCamera
{
   BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   return hasCamera;
}

@end
