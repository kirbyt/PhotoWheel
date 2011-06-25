//
//  WheelView.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 6/24/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WheelViewDataSource;
@class WheelViewNub;

typedef enum  {
   WheelViewStyleWheel,
   WheelViewStyleCarousel,
} WheelViewStyle;


@interface WheelView : UIView

@property (nonatomic, strong) IBOutlet id<WheelViewDataSource> dataSource;
@property (nonatomic, assign) WheelViewStyle style;

//- (WheelViewNub *)dequeueReusableNub;
//- (void)reloadData;

@end


@protocol WheelViewDataSource <NSObject>
@required
- (NSInteger)wheelViewNumberOfNubs:(WheelView *)wheelView;
- (WheelViewNub *)wheelView:(WheelView *)wheelView nubAtIndex:(NSInteger)index;
@end


@interface WheelViewNub : UIView
@end