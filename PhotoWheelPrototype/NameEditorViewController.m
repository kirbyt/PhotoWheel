//
//  NameEditorViewController.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/16/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "NameEditorViewController.h"

@implementation NameEditorViewController

@synthesize nameTextField = nameTextField_;
@synthesize delegate = delegate_;
@synthesize indexPath = indexPath_;
@synthesize defaultNameText = defaultNameText_;

- (id)initWithDefaultNib 
{
   self = [super initWithNibName:@"NameEditorViewController" bundle:nil];
   if (self) {
      // Custom initialization.
   }
   return self;
}
- (void)viewDidLoad
{
   [super viewDidLoad];
   if ([self isEditing]) {
      [[self nameTextField] setText:[self defaultNameText]];
   }
}

- (void)viewDidUnload
{
   [self setNameTextField:nil];
   [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

#pragma mark - Actions Methods

- (IBAction)cancel:(id)sender
{
   id<NameEditorViewControllerDelegate> delegate = [self delegate];
   if (delegate && [delegate respondsToSelector:@selector(nameEditorViewControllerDidCancel:)]) {
      [delegate nameEditorViewControllerDidCancel:self];
   }
}

- (IBAction)done:(id)sender
{
   id<NameEditorViewControllerDelegate> delegate = [self delegate];
   if (delegate && [delegate respondsToSelector:@selector(nameEditorViewControllerDidFinish:)]) {
      [delegate nameEditorViewControllerDidFinish:self]; 
   }
}

@end
