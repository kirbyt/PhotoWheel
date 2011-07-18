//
//  WheelView.h
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 7/1/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WheelViewDataSource;
@class WheelViewCell;

typedef enum  {
   WheelViewStyleWheel,
   WheelViewStyleCarousel,
} WheelViewStyle;


@interface WheelView : UIView

@property (nonatomic, strong) IBOutlet id<WheelViewDataSource> dataSource;
@property (nonatomic, assign) WheelViewStyle style;
@property (nonatomic, assign) CGFloat selectAtDegrees;
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)reloadData;

@end


@protocol WheelViewDataSource <NSObject>
@required
- (NSInteger)wheelViewNumberOfCells:(WheelView *)wheelView;
- (WheelViewCell *)wheelView:(WheelView *)wheelView cellAtIndex:(NSInteger)index;
@optional
- (void)wheelView:(WheelView *)wheelView didSelectCellAtIndex:(NSInteger)index;
@end


@interface WheelViewCell : UIView
@end