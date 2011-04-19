//
//  PhotoWheelTableViewCell.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/19/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoWheel;
@class PhotoWheelViewController;

@interface PhotoWheelTableViewCell : UITableViewCell
{
    
}

@property (nonatomic, retain) IBOutlet UIView *placeholderView1;
@property (nonatomic, retain) IBOutlet UIView *placeholderView2;

@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;

@property (nonatomic, retain) IBOutlet PhotoWheelViewController *photoWheelViewController1;
@property (nonatomic, retain) IBOutlet PhotoWheelViewController *photoWheelViewController2;

+ (NSString *)cellIdentifier;
+ (NSString *)nibName;
+ (UINib *)nib;
+ (id)cellForTableView:(UITableView *)tableView;

@end
