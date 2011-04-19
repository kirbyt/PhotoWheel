//
//  RootViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;


@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
{

}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)addPhotoWheel:(id)sender;
- (IBAction)showInfoScreen:(id)sender;


@end
