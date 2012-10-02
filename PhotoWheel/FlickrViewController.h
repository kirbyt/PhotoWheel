//
//  FlickrViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 10/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *gridView;
@property (nonatomic, weak) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectID *objectID;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
