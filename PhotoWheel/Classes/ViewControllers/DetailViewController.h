//
//  DetailViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> 
{
}


@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIView *photoWheelPlaceholderView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)pickImage:(id)sender;

@end
