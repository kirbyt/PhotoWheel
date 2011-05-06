//
//  AddPhotoViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 5/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAlbumViewController;

@interface AddPhotoViewController : UIViewController
{
    
}

@property (nonatomic, assign) PhotoAlbumViewController *photoAlbumViewController;

- (IBAction)addFromCamera:(id)sender;
- (IBAction)addFromLibrary:(id)sender;
- (IBAction)addFromFlickr:(id)sender;

@end
