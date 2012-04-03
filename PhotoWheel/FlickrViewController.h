//
//  FlickrViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 10/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"

@interface FlickrViewController : UIViewController <GridViewDataSource, 
UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet GridView *gridView;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectID *objectID;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
