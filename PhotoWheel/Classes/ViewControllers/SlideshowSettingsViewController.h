//
//  SlideshowSettingsViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SlideshowSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
