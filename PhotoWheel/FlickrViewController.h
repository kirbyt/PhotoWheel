//
//  FlickrViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"
#import "ImageDownloader.h"


@interface FlickrViewController : UIViewController <UISearchBarDelegate, GridViewDataSource, ImageDownloaderDelegate>

@property (nonatomic, strong) IBOutlet GridView *gridView;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectID *objectID;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
