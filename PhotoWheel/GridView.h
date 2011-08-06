//
//  GridView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 7/18/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GridViewCell;
@protocol GridViewDataSource;


@interface GridView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet id<GridViewDataSource> dataSource;


- (id)dequeueReusableCell;
- (void)reloadData;
- (void)reloadCellAtIndex:(NSInteger)index;
- (GridViewCell *)cellAtIndex:(NSInteger)index;
- (NSInteger)indexForSelectedCell;

@end


@protocol GridViewDataSource <NSObject>
@required
- (NSInteger)gridViewNumberOfCells:(GridView *)gridView;
- (GridViewCell *)gridView:(GridView *)gridView cellAtIndex:(NSInteger)index;
- (CGSize)gridViewCellSize:(GridView *)gridView;

@optional
- (NSInteger)gridViewCellsPerRow:(GridView *)gridView;
- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index;
@end


@interface GridViewCell : UIView
{
   
}

@end

