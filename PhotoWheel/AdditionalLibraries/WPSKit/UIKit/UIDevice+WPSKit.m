//
//  UIDevice+WPSKit.m
//  WPSKitSamples
//
//  Created by Kirby Turner on 3/15/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "UIDevice+WPSKit.h"

@implementation UIDevice (WPSKit)

+ (BOOL)wps_isiPad
{
   return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

+ (BOOL)wps_isiPhone
{
   return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

@end
