//
//  NameEditorViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "NameEditorViewController.h"


@implementation NameEditorViewController

@synthesize textField = textField_;
@synthesize delegate = delegate_;

- (void)dealloc
{
   [textField_ release];
   [super dealloc];
}

- (id)init
{
   self = [super initWithNibName:@"NameEditorView" bundle:nil];
   if (self) {
      
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self setContentSizeForViewInPopover:CGSizeMake(320, 108)];
   [self setModalInPopover:YES];
}

- (void)viewDidUnload 
{
   [self setTextField:nil];
   [super viewDidUnload];
}

- (IBAction)save:(id)sender 
{
   if ([self delegate] && [[self delegate] respondsToSelector:@selector(nameEditorDidSaveWithName:)]) {
      NSString *name = [[self textField] text];
      [[self delegate] nameEditorDidSaveWithName:name];
   }
}

- (IBAction)cancel:(id)sender 
{
   if ([self delegate] && [[self delegate] respondsToSelector:@selector(nameEditorDidCancel)]) {
      [[self delegate] nameEditorDidCancel];
   }
}

@end
