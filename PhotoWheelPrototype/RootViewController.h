//
//  RootViewController.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/15/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NameEditorViewController.h"

@class DetailViewController;

@interface RootViewController : UITableViewController <NameEditorViewControllerDelegate>

@property (strong, nonatomic) NSMutableOrderedSet *data;
@property (strong, nonatomic) DetailViewController *detailViewController;

@end
