//
//  GridView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GridViewCell;
@protocol GridViewDataSource;


@interface GridView : UIScrollView <UIScrollViewDelegate>
{
    
}

@property (nonatomic, assign) IBOutlet id<GridViewDataSource> dataSource;


- (id)dequeueReusableView;
- (void)reloadData;

@end


@protocol GridViewDataSource <NSObject>
@required
- (NSInteger)gridViewNumberOfViews:(GridView *)gridView;
- (GridViewCell *)gridView:(GridView *)gridView viewAtIndex:(NSInteger)index;
- (CGSize)gridViewCellSize:(GridView *)gridView;

@optional
- (NSInteger)gridViewCellsPerRow:(GridView *)gridView;
- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index;
@end


@interface GridViewCell : UIView
{
   
}

@end

