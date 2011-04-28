//
//  DetailViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 3/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAlbum;
@class PhotoWheelView;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> 
{
}


@property (nonatomic, retain) IBOutlet PhotoWheelView *photoWheelView;
@property (nonatomic, retain) PhotoAlbum *photoWheel;

@end
