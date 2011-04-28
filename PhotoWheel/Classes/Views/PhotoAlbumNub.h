//
//  PhotoAlbumNub.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/28/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"


@interface PhotoAlbumNub : WheelViewNub
{
    
}

+ (PhotoAlbumNub *)photoAlbumNub;

- (void)setImage:(UIImage *)image;
- (void)setTitle:(NSString *)title;

@end
