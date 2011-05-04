//
//  AboutViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 5/4/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

- (id)init
{
   self = [super initWithNibName:@"AboutView" bundle:nil];
   if (self) {
      [self setModalPresentationStyle:UIModalPresentationFormSheet];
   }
   return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   [[self view] setBounds:CGRectMake(0, 0, 400, 400)];
}

- (IBAction)done:(id)sender
{
   [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

@end
