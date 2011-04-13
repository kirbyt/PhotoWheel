//
//  PhotoNubMenuViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/10/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoNubViewController;

@interface PhotoNubMenuViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    
}

@property (nonatomic, assign) PhotoNubViewController *viewController;

@end
