//
//  PhotoWheelViewCell.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoWheelViewCell

@synthesize imageView = _imageView;
@synthesize label = _label;

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
