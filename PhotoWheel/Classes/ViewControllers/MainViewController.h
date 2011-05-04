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
@property (nonatomic, retain) IBOutlet UIButton *emailButton;
@property (nonatomic, retain) IBOutlet UIButton *slideshowButton;
@property (nonatomic, retain) IBOutlet UIButton *printButton;
@property (nonatomic, retain) IBOutlet UIButton *removeAlbumButton;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)addPhotoAlbum:(id)sender;
- (IBAction)removePhotoAlbum:(id)sender;
- (IBAction)printPhotoAlbum:(id)sender;
- (IBAction)emailPhotoAlbum:(id)sender;
- (IBAction)slideshow:(id)sender;

@end
