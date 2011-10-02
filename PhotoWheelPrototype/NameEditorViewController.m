//
//  NameEditorViewController.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "NameEditorViewController.h"

@implementation NameEditorViewController

@synthesize nameTextField = _nameTextField;
@synthesize delegate = _delegate;
@synthesize indexPath = _indexPath;
@synthesize defaultNameText = _defaultNameText;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

#pragma mark - Actions methods

- (IBAction)cancel:(id)sender
{
   id<NameEditorViewControllerDelegate> delegate = [self delegate];
   if (delegate && 
       [delegate respondsToSelector:@selector(nameEditorViewControllerDidCancel:)]) 
   {
      [delegate nameEditorViewControllerDidCancel:self];
   }
   [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
   id<NameEditorViewControllerDelegate> delegate = [self delegate];
   if (delegate && 
       [delegate respondsToSelector:@selector(nameEditorViewControllerDidFinish:)]) 
   {
      [delegate nameEditorViewControllerDidFinish:self]; 
   }
   [self dismissModalViewControllerAnimated:YES];
}

@end
