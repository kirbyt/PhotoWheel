//
//  DetailViewController.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"

@class PhotoAlbum;

@interface DetailViewController : UIViewController 
<UISplitViewControllerDelegate, WheelViewDataSource, UIActionSheetDelegate, 
UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (strong, nonatomic) IBOutlet WheelView *wheelView;

@property (strong, nonatomic) PhotoAlbum *photoAlbum;

@property (assign, nonatomic) NSUInteger selectedWheelViewCellIndex;

@end
