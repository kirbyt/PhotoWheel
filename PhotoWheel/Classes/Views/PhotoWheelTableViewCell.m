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
@synthesize photoWheelViewController1 = photoWheelViewController1_;
@synthesize photoWheelViewController2 = photoWheelViewController2_;

- (void)dealloc
{
   [placeholderView1_ release], placeholderView1_ = nil;
   [placeholderView2_ release], placeholderView2_ = nil;
   [label1_ release], label1_ = nil;
   [label2_ release], label2_ = nil;
   [photoWheelViewController1_ release], photoWheelViewController1_ = nil;
   [photoWheelViewController2_ release], photoWheelViewController2_ = nil;
   
   [super dealloc];
}

- (void)awakeFromNib
{
   [[self photoWheelViewController1] setStyle:PhotoWheelStyleCarousel];
   [[self photoWheelViewController2] setStyle:PhotoWheelStyleCarousel];
   
   [[self placeholderView1] kt_addSubview:[[self photoWheelViewController1] view]];
   [[self placeholderView2] kt_addSubview:[[self photoWheelViewController2] view]];
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
