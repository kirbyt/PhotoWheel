//
//  RootViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NameEditorViewController.h"

@class DetailViewController;


@interface RootViewController : UITableViewController <UIPopoverControllerDelegate, NameEditorViewControllerDelegate>
{

}
		
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *data;

- (IBAction)addPhotoWheel:(id)sender;


@end
