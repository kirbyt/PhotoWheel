//
//  PhotoWheelTableViewCell.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/19/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoWheelTableViewCell.h"
#import "PhotoWheelView.h"
#import "PhotoWheel.h"


@implementation PhotoWheelTableViewCell

@synthesize photoWheelView = photoWheelView_;
@synthesize label = label_;
@synthesize photoWheel = photoWheel_;

- (void)dealloc
{
   [photoWheelView_ release], photoWheelView_ = nil;
   [label_ release], label_ = nil;
   [photoWheel_ release], photoWheel_ = nil;   
   
   [super dealloc];
}

- (void)awakeFromNib
{
   [[self photoWheelView] setStyle:PhotoWheelStyleCarousel];
}

- (void)reload
{
   [[self label] setText:[[self photoWheel] name]];
   [[self photoWheelView] setPhotoWheel:[self photoWheel]];
}

- (void)setPhotoWheel:(PhotoWheel *)photoWheel
{
   if (photoWheel_ != photoWheel) {
      [photoWheel retain];
      [photoWheel_ release];
      photoWheel_ = photoWheel;
      
      [self reload];
   }
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
