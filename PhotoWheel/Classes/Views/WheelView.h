//
//  PhotoWheelView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/20/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
   WheelStyleWheel,
   WheelStyleCarousel,
} WheelStyle;


@protocol WheelViewDataSource;
@class WheelViewNub;

@interface WheelView : UIView
{
    
}

@property (nonatomic, assign) IBOutlet id<WheelViewDataSource> dataSource;
@property (nonatomic, assign) WheelStyle style;
@property (nonatomic, assign) CGFloat topAtDegrees;
@property (nonatomic, assign) NSInteger selectedIndex;

- (id)initWithStyle:(WheelStyle)style;
- (WheelViewNub *)dequeueReusableNub;
- (void)reloadData;
- (void)selectNubAtIndex:(NSInteger)index;

@end


@protocol WheelViewDataSource <NSObject>
@required
- (NSInteger)wheelViewNumberOfNubs:(WheelView *)wheelView;
- (WheelViewNub *)wheelView:(WheelView *)wheelView nubAtIndex:(NSInteger)index;
@optional
- (void)wheelView:(WheelView *)wheelView didSelectNubAtIndex:(NSInteger)index;
@end


@interface WheelViewNub : UIView 
{
}

@end