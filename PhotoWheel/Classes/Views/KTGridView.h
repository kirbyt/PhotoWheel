//
//  PhotoWheelScrollView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KTGridViewCell;
@protocol KTGridViewDataSource;


@interface KTGridView : UIScrollView <UIScrollViewDelegate>
{
    
}

@property (nonatomic, assign) IBOutlet id<KTGridViewDataSource> dataSource;


- (KTGridViewCell *)dequeueReusableView;
- (void)reloadData;

@end


@protocol KTGridViewDataSource <NSObject>
@required
- (NSInteger)ktGridViewNumberOfViews:(KTGridView *)gridView;
- (KTGridViewCell *)ktGridView:(KTGridView *)gridView viewAtIndex:(NSInteger)index;
- (CGSize)ktGridViewCellSize:(KTGridView *)gridView;

@optional
- (NSInteger)ktGridViewCellsPerRow:(KTGridView *)gridView;
@end


@interface KTGridViewCell : UIView
{
   
}

@end

