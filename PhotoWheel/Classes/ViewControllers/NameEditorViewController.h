//
//  NameEditorViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NameEditorViewControllerDelegate;

@interface NameEditorViewController : UIViewController
{
}

@property (nonatomic, assign) id<NameEditorViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSIndexPath *editingAtIndexPath;
@property (nonatomic, assign, getter = isEditing) BOOL editing;

- (void)save;

@end


@protocol NameEditorViewControllerDelegate <NSObject>
@optional
- (void)nameEditorDidSave:(NameEditorViewController *)nameEditorViewController;
@end