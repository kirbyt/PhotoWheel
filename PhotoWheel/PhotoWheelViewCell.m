//
//  PhotoWheelViewCell.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 10/17/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelViewCell.h"

@implementation PhotoWheelViewCell

+ (PhotoWheelViewCell *)photoWheelViewCell
{
   NSString *nibName = NSStringFromClass([self class]);
   UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
   NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
   // Verify that the top-level object is in fact of the correct type.
   NSAssert2([nibObjects count] > 0 &&
             [[nibObjects objectAtIndex:0] isKindOfClass:[self class]],
             @"Nib '%@' does not contain top-level view of type %@.",
             nibName, nibName);
   return [nibObjects objectAtIndex:0];
}

@end
