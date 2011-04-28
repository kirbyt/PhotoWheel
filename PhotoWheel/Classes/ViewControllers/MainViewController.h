//
//  MainViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/22/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"

@class WheelView;

@interface MainViewController : UIViewController <NSFetchedResultsControllerDelegate, WheelViewDataSource>
{
    
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet WheelView *photoWheelView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)addPhotoAlbum:(id)sender;

@end
