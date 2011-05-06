//
//  AddPhotoViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "AddPhotoViewController.h"


@implementation AddPhotoViewController

- (void)dealloc
{
   [super dealloc];
}

- (id)init
{
   self = [super initWithNibName:@"AddPhotoView" bundle:nil];
   if (self) {
      [self setContentSizeForViewInPopover:CGSizeMake(320, 100)];
   }
   return self;
}

@end
