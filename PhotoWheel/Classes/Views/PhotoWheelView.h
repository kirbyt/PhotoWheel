//
//  PhotoWheelView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/20/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
   PhotoWheelStyleWheel,
   PhotoWheelStyleCarousel,
} PhotoWheelStyle;

@class PhotoWheel;

@interface PhotoWheelView : UIView 
{
    
}

@property (nonatomic, assign, readonly) NSInteger nubCount;
@property (nonatomic, assign) PhotoWheelStyle style;
@property (nonatomic, retain) PhotoWheel *photoWheel;

- (id)initWithNubCount:(NSInteger)nubCount;

@end
