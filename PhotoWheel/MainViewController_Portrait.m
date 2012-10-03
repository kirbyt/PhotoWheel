//
//  MainViewController_Portrait.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/3/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "MainViewController_Portrait.h"

@interface MainViewController_Portrait ()
@property (nonatomic, assign, getter = isShowingLandscapeView) BOOL showingLandscapeView;
@end

@implementation MainViewController_Portrait

- (void)awakeFromNib
{
   [self setShowingLandscapeView:NO];
   [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(orientationChanged:)
                                                name:UIDeviceOrientationDidChangeNotification
                                              object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
   UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
   if (UIDeviceOrientationIsLandscape(deviceOrientation) && ![self isShowingLandscapeView]) {
      UIViewController *landscapeViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"MainViewController_Landscape"];
      [self presentViewController:landscapeViewController animated:NO completion:nil];
      [self setShowingLandscapeView:YES];
   }
   else if (UIDeviceOrientationIsPortrait(deviceOrientation) && [self isShowingLandscapeView]) {
      [self dismissViewControllerAnimated:NO completion:nil];
      [self setShowingLandscapeView:NO];
   }
}

@end
