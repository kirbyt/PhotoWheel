//
//  DetailViewController.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/15/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, WheelViewDataSource>

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet WheelView *wheelView;

- (IBAction)styleValueChanged:(id)sender;

@end
