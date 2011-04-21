//
//  DetailViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "PhotoWheelView.h"


@interface DetailViewController ()
@end


@implementation DetailViewController

@synthesize photoWheelView = photoWheelView_;
@synthesize photoWheel = photoWheel_;

- (void)dealloc
{
   [photoWheelView_ release], photoWheelView_ = nil;
   [photoWheel_ release], photoWheel_ = nil;
   
   [super dealloc];
}

- (void)viewDidLoad
{
   [super viewDidLoad];

   [[self photoWheelView] setPhotoWheel:[self photoWheel]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
   return YES;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
   
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
   [self setPhotoWheelView:nil];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)setPhotoWheel:(PhotoWheel *)photoWheel
{
   if (photoWheel_ != photoWheel) {
      [photoWheel retain];
      [photoWheel_ release];
      photoWheel_ = photoWheel;
      
      [[self photoWheelView] setPhotoWheel:[self photoWheel]];
   }
}


@end
