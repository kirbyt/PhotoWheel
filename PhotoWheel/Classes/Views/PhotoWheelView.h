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


@interface PhotoWheelView : UIView 
{
    
}

@property (nonatomic, assign, readonly) NSInteger nubCount;
@property (nonatomic, assign) PhotoWheelStyle style;

- (id)initWithNubCount:(NSInteger)nubCount;

@end
