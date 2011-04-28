//
//  PhotoWheelViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 3/31/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoAlbum;

typedef enum  {
   PhotoWheelStyleWheel,
   PhotoWheelStyleCarousel,
} PhotoWheelStyle;


@interface PhotoWheelViewController : UIViewController
{
}

@property (nonatomic, retain) PhotoAlbum *photoWheel;
@property (nonatomic, assign) PhotoWheelStyle style;

- (void)showImageBrowserFromPoint:(CGPoint)point startAtIndex:(NSInteger)index;

@end
