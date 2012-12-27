//
//  AlbumsViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 11/12/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"

@interface AlbumsViewController : UIViewController <NSFetchedResultsControllerDelegate, WheelViewDataSource, WheelViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet WheelView *wheelView;

- (IBAction)addPhotoAlbum:(id)sender;

@end
