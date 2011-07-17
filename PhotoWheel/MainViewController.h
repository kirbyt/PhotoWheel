//
//  MainViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"


@interface MainViewController : UIViewController <WheelViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet WheelView *wheelView;

- (void)displayPhotoBrowser;
- (IBAction)addPhotoAlbum:(id)sender;

@end
