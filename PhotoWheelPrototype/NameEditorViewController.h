//
//  NameEditorViewController.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/16/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NameEditorViewControllerDelegate;

@interface NameEditorViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) id<NameEditorViewControllerDelegate> delegate;
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
