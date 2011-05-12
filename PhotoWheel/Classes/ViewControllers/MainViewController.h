//
//  MainViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/22/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"

@class PhotoAlbum;

@interface MainViewController : UIViewController <NSFetchedResultsControllerDelegate, WheelViewDataSource>
{
    
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UIImageView *discImageView;
@property (nonatomic, retain) IBOutlet WheelView *photoWheelView;
@property (nonatomic, retain) IBOutlet UIButton *addPhotoAlbumButton;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIView *photoAlbumViewPlaceholder;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)addPhotoAlbum:(id)sender;
- (IBAction)showAbout:(id)sender;

@end
