//
//  MasterViewController.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NameEditorViewController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController 
<NameEditorViewControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
