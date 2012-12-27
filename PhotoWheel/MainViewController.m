//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 11/2/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "MainViewController.h"
#import "AlbumsViewController.h"
#import "PhotosViewController.h"
#import "PhotoBrowserViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()
@property (nonatomic, weak) IBOutlet UIView *albumsView;
@property (nonatomic, weak) IBOutlet UIView *photosView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, assign, readwrite) CGRect selectedPhotoFrame;
@property (nonatomic, strong, readwrite) UIImage *selectedPhotoImage;
- (IBAction)pushPhotoBrowser:(id)sender;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   [self rotateToInterfaceOrientation:[self interfaceOrientation]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushPhotoBrowser:(id)sender
{
   [self performSegueWithIdentifier:@"PushPhotoBrowser" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   id destinationVC = [segue destinationViewController];
   if ([destinationVC isKindOfClass:[AlbumsViewController class]]) {
      UIApplication *app = [UIApplication sharedApplication];
      AppDelegate *appDelegate = (AppDelegate *)[app delegate];

      NSManagedObjectContext *context = [appDelegate managedObjectContext];

      [destinationVC setManagedObjectContext:context];
      
   } else if ([[segue identifier] isEqualToString:@"PushPhotoBrowser"]) {
      [destinationVC setPhotos:[sender photos]];
      [destinationVC setStartAtIndex:[sender selectedPhotoIndex]];
      
      id sourceVC = [segue sourceViewController];
      CGRect frame = [sender selectedPhotoFrame];
      frame = [[self view] convertRect:frame fromView:[sender view]];
      [sourceVC setSelectedPhotoFrame:frame];
      [sourceVC setSelectedPhotoImage:[sender selectedPhotoImage]];
   }
}

#pragma mark - Rotation and Auto Layout

- (void)updateViewConstraints
{
   [super updateViewConstraints];
   [self updateViewConstraintsForInterfaceOrientation:[self interfaceOrientation]];
}

- (void)updateViewConstraintsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   UIView *parentView = [self view];
   UIView *albumsView = [self albumsView];
   UIView *photosView = [self photosView];
   UIImageView *backgroundImageView = [self backgroundImageView];
   UIButton *infoButton = [self infoButton];
   NSDictionary *views = NSDictionaryOfVariableBindings(photosView, albumsView, backgroundImageView, infoButton);
   
   [parentView removeConstraints:[parentView constraints]];
   
   ADD_CONSTRAINT(parentView, @"V:|-0-[backgroundImageView]-0-|", views)
   ADD_CONSTRAINT(parentView, @"H:|-0-[backgroundImageView]-0-|", views)
   
   if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
      ADD_CONSTRAINT(parentView, @"V:[infoButton]-17-|", views)
      ADD_CONSTRAINT(parentView, @"H:[infoButton]-25-|", views)
      
      ADD_CONSTRAINT(parentView, @"V:[photosView(719)]", views)
      ADD_CONSTRAINT(parentView, @"H:|-18-[photosView(738)]", views)
      [parentView addConstraint:
       [NSLayoutConstraint constraintWithItem:photosView
                                    attribute:NSLayoutAttributeCenterY
                                    relatedBy:NSLayoutRelationEqual
                                       toItem:parentView
                                    attribute:NSLayoutAttributeCenterY
                                   multiplier:1.0f
                                     constant:0.0f]];
      
      ADD_CONSTRAINT(parentView, @"V:|-100-[albumsView(550)]", views)
      ADD_CONSTRAINT(parentView, @"H:|-700-[albumsView(551)]", views)
      
   } else {
      ADD_CONSTRAINT(parentView, @"H:[infoButton]-26-|", views)
      ADD_CONSTRAINT(parentView, @"V:[infoButton]-28-|", views)
      
      ADD_CONSTRAINT(parentView, @"V:|-18-[photosView(716)]", views)
      ADD_CONSTRAINT(parentView, @"H:[photosView(717)]", views)
      [parentView addConstraint:
       [NSLayoutConstraint constraintWithItem:photosView
                                    attribute:NSLayoutAttributeCenterX
                                    relatedBy:NSLayoutRelationEqual
                                       toItem:parentView
                                    attribute:NSLayoutAttributeCenterX
                                   multiplier:1.0f constant:0.0f]];
      
      ADD_CONSTRAINT(parentView, @"V:|-680-[albumsView(550)]", views)
      ADD_CONSTRAINT(parentView, @"H:|-109-[albumsView(551)]", views)
   }
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   [self updateViewConstraintsForInterfaceOrientation:toInterfaceOrientation];
   
   UIImage *image = nil;
   if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
      image = [UIImage imageNamed:@"background-landscape-right-grooved"];
   } else {
      image = [UIImage imageNamed:@"background-portrait-grooved"];
   }
   [[self backgroundImageView] setImage:image];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
   [self rotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
