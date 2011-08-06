//
//  AboutViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (IBAction)done:(id)sender 
{
   [self dismissModalViewControllerAnimated:YES];
}

@end
