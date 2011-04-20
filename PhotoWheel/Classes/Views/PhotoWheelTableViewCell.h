//
//  PhotoWheelTableViewCell.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/19/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoWheel;
@class PhotoWheelView;

@interface PhotoWheelTableViewCell : UITableViewCell
{
    
}

@property (nonatomic, retain) IBOutlet PhotoWheelView *photoWheel1;
@property (nonatomic, retain) IBOutlet PhotoWheelView *photoWheel2;
@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;

+ (NSString *)cellIdentifier;
+ (NSString *)nibName;
+ (UINib *)nib;
+ (id)cellForTableView:(UITableView *)tableView;

@end
