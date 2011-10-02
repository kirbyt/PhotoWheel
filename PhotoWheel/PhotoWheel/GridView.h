//
//  GridView.h
//  PhotoWheel
//
//  Created by Kirby Turner on 9/29/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GridViewCell;                                                     // 1
@protocol GridViewDataSource;                                            // 2


@interface GridView : UIScrollView <UIScrollViewDelegate>                // 3

@property (nonatomic, strong) IBOutlet id<GridViewDataSource> dataSource;// 4
@property (nonatomic, assign) BOOL allowsMultipleSelection;              // 5


- (id)dequeueReusableCell;                                               // 6
- (void)reloadData;                                                      // 7
- (GridViewCell *)cellAtIndex:(NSInteger)index;                          // 8
- (NSInteger)indexForSelectedCell;                                       // 9
- (NSArray *)indexesForSelectedCells;                                    // 10

@end


@protocol GridViewDataSource <NSObject>
@required
- (NSInteger)gridViewNumberOfCells:(GridView *)gridView;
- (GridViewCell *)gridView:(GridView *)gridView cellAtIndex:(NSInteger)index;
- (CGSize)gridViewCellSize:(GridView *)gridView;

@optional
- (NSInteger)gridViewCellsPerRow:(GridView *)gridView;
- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index;
- (void)gridView:(GridView *)gridView didDeselectCellAtIndex:(NSInteger)index;
@end


@interface GridViewCell : UIView
@property (nonatomic, assign, getter = isSelected) BOOL selected;       // 11
@end
