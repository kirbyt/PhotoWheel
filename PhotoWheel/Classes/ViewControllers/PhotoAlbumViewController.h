//
//  PhotoAlbumViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/4/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"

@class PhotoAlbum;
@class MainViewController;

@interface PhotoAlbumViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, GridViewDataSource>
{
    
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UIImageView *topShadowImageView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITextField *titleTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addPhotoButton;
@property (nonatomic, retain) IBOutlet GridView *gridView;
@property (nonatomic, retain) PhotoAlbum *photoAlbum;
@property (nonatomic, assign) MainViewController *mainViewController;

- (IBAction)showActionMenu:(id)sender;
- (IBAction)addPhoto:(id)sender;

- (void)layoutForLandscape;
- (void)layoutForPortrait;

@end
