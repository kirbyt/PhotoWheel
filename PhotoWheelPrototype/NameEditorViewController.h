//
//  NameEditorViewController.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NameEditorViewControllerDelegate;

@interface NameEditorViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) id<NameEditorViewControllerDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic, copy) NSString *defaultNameText;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

- (id)initWithDefaultNib;

@end


@protocol NameEditorViewControllerDelegate <NSObject>
@optional
- (void)nameEditorViewControllerDidFinish:(NameEditorViewController *)controller;
- (void)nameEditorViewControllerDidCancel:(NameEditorViewController *)controller;
@end
