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

@interface PhotoAlbumViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GridViewDataSource>
{
    
}

@property (nonatomic, retain) IBOutlet UIButton *emailButton;
@property (nonatomic, retain) IBOutlet UIButton *slideshowButton;
@property (nonatomic, retain) IBOutlet UIButton *printButton;
@property (nonatomic, retain) IBOutlet UIButton *removeAlbumButton;
@property (nonatomic, retain) IBOutlet UITextField *titleTextField;
@property (nonatomic, retain) IBOutlet GridView *gridView;
@property (nonatomic, retain) PhotoAlbum *photoAlbum;
@property (nonatomic, assign) MainViewController *mainViewController;

- (IBAction)removePhotoAlbum:(id)sender;
- (IBAction)printPhotoAlbum:(id)sender;
- (IBAction)emailPhotoAlbum:(id)sender;
- (IBAction)slideshow:(id)sender;

- (void)addFromCamera;
- (void)addFromLibrary;
- (void)addFromFlickr;

@end
