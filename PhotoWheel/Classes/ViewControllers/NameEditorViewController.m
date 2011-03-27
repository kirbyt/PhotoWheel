//
//  NameEditorViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "NameEditorViewController.h"


@implementation NameEditorViewController

@synthesize delegate = delegate_;
@synthesize textField = textField_;
@synthesize photoWheelName = photoWheelName_;

- (void)dealloc
{
   [textField_ release];
   [photoWheelName_ release];
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

   if ([self photoWheelName]) {
      [self setTitle:@"Edit"];
      [[self textField] setText:[self photoWheelName]];
   } else {
      [self setTitle:@"New"];
   }
   
   UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
   [[self navigationItem] setRightBarButtonItem:saveButton];
   [saveButton release];
}

- (void)viewDidUnload 
{
   [self setTextField:nil];
   [super viewDidUnload];
}

- (void)save
{
   [self setPhotoWheelName:[[self textField] text]];
   
   if ([self delegate] && [[self delegate] respondsToSelector:@selector(nameEditorDidSave:)]) {
      [[self delegate] nameEditorDidSave:self];
   }
}

@end
