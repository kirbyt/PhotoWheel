//
//  PhotoWheelView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/20/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTGridView.h"

typedef enum  {
   PhotoWheelStyleWheel,
   PhotoWheelStyleCarousel,
} PhotoWheelStyle;

@class PhotoAlbum;

@interface PhotoWheelView : KTGridViewCell
{
    
}

@property (nonatomic, assign, readonly) NSInteger nubCount;
@property (nonatomic, assign) PhotoWheelStyle style;
@property (nonatomic, retain) PhotoAlbum *photoWheel;

- (id)initWithNubCount:(NSInteger)nubCount;

@end
