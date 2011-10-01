//
//  AboutViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/8/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (IBAction)done:(id)sender
{
   [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

@end
