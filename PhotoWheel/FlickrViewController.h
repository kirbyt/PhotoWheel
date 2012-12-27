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

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) PhotoAlbum *photoAlbum;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
