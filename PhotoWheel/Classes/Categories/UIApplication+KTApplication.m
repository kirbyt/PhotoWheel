//
//  UIApplication+KTApplication.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/16/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "UIApplication+KTApplication.h"


@implementation UIApplication (UIApplication_KTApplication)

+ (NSString *)kt_documentPath
{
   NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *path = [searchPaths objectAtIndex:0];
   return path;
}

@end
