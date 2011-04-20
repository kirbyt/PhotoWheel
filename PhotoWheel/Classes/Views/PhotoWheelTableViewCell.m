//
//  PhotoWheelTableViewCell.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/19/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelTableViewCell.h"
#import "PhotoWheelView.h"


@implementation PhotoWheelTableViewCell

@synthesize photoWheel1 = photoWheel1_;
@synthesize photoWheel2 = photoWheel2_;
@synthesize label1 = label1_;
@synthesize label2 = label2_;

- (void)dealloc
{
   
   [photoWheel1_ release], photoWheel1_ = nil;
   [photoWheel2_ release], photoWheel2_ = nil;
   [label1_ release], label1_ = nil;
   [label2_ release], label2_ = nil;
   
   [super dealloc];
}

- (void)awakeFromNib
{
   [[self photoWheel1] setStyle:PhotoWheelStyleCarousel];
   [[self photoWheel2] setStyle:PhotoWheelStyleCarousel];
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
