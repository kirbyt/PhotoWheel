//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 6/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoBrowserViewController.h"

@implementation PhotoBrowserViewController

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
   UINavigationBar *navBar = [[self navigationController] navigationBar];
   [navBar setBarStyle:UIBarStyleBlack];
   [navBar setTranslucent:YES];
   
   [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];
   [[self navigationController] setNavigationBarHidden:YES animated:YES];
}


@end
