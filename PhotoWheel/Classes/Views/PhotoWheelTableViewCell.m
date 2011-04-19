//
//  PhotoWheelTableViewCell.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/19/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelTableViewCell.h"
#import "UIView+KTCompositeView.h"
#import "PhotoWheelViewController.h"


@implementation PhotoWheelTableViewCell

@synthesize placeholderView1 = placeholderView1_;
@synthesize placeholderView2 = placeholderView2_;
@synthesize label1 = label1_;
@synthesize label2 = label2_;
@synthesize viewController1 = viewController1_;
@synthesize viewController2 = viewController2_;
@synthesize photoWheel1 = photoWheel1_;
@synthesize photoWheel2 = photoWheel2_;

- (void)dealloc
{
   [placeholderView1_ release], placeholderView1_ = nil;
   [placeholderView2_ release], placeholderView2_ = nil;
   [label1_ release], label1_ = nil;
   [label2_ release], label2_ = nil;
   [viewController1_ release], viewController1_ = nil;
   [viewController2_ release], viewController2_ = nil;
   [photoWheel1_ release], photoWheel1_ = nil;
   [photoWheel2_ release], photoWheel2_ = nil;   
   
   [super dealloc];
}

- (void)awakeFromNib
{
   [[self viewController1] setStyle:PhotoWheelStyleCarousel];
   [[self viewController2] setStyle:PhotoWheelStyleCarousel];
   
   [[self placeholderView1] kt_addSubview:[[self viewController1] view]];
   [[self placeholderView2] kt_addSubview:[[self viewController2] view]];
}

- (void)setPhotoWheel1:(PhotoWheel *)photoWheel1
{
   if (photoWheel1_ != photoWheel1) {
      [photoWheel1 retain];
      [photoWheel1_ release];
      photoWheel1_ = photoWheel1;
      
      [[self viewController1] setPhotoWheel:photoWheel1];
   }
}

- (void)setPhotoWheel2:(PhotoWheel *)photoWheel2
{
   if (photoWheel2_ != photoWheel2) {
      [photoWheel2 retain];
      [photoWheel2_ release];
      photoWheel2_ = photoWheel2;
   }

   [[self viewController2] setPhotoWheel:photoWheel2];
}

#pragma mark - Class Methods

+ (NSString *)cellIdentifier 
{
   return NSStringFromClass([self class]);
}

+ (NSString *)nibName 
{
   return [self cellIdentifier];
}

+ (UINib *)nib 
{ 
   NSBundle *classBundle = [NSBundle bundleForClass:[self class]]; 
   return [UINib nibWithNibName:[self nibName] bundle:classBundle];
}

+ (id)cellForTableView:(UITableView *)tableView
{ 
   NSString *cellID = [self cellIdentifier]; 
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID]; 
   if (cell == nil) {
      NSArray *nibObjects = [[self nib] instantiateWithOwner:nil options:nil]; 
      NSAssert2(([nibObjects count] > 0) && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' does not appear to contain a valid %@", [self nibName], NSStringFromClass([self class]));
      cell = [nibObjects objectAtIndex:0]; 
   }
   return cell;
}


@end
