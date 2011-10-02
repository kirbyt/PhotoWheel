//
//  PhotoAlbumViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 8/13/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"
#import "PhotoBrowserViewController.h"                                  // 1

@interface PhotoAlbumViewController : UIViewController 
<UIActionSheetDelegate, UIImagePickerControllerDelegate, 
UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, 
GridViewDataSource, PhotoBrowserViewControllerDelegate>                 // 2

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectID *objectID;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) IBOutlet GridView *gridView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView *shadowImageView;

- (void)reload;
- (IBAction)showActionMenu:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (UIImage *)selectedImage;
- (CGRect)selectedCellFrame;

@end
