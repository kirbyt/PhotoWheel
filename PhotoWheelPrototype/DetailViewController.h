//
//  DetailViewController.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/15/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"
#import "PhotoAlbum.h"
#import "Photo.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, WheelViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet WheelView *wheelView;

@property (strong, nonatomic) PhotoAlbum *photoAlbum;

- (IBAction)styleValueChanged:(id)sender;

@end
