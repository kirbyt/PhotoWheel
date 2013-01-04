//
//  FlickrViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 12/16/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAlbum;

@interface FlickrViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) PhotoAlbum *photoAlbum;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
