//
//  GridView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 7/18/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "GridView.h"

#pragma mark - GridViewCell

@interface GridViewCell ()
@property (nonatomic, assign) NSInteger indexInGrid;
@end

@implementation GridViewCell
@synthesize indexInGrid = indexInGrid_;
@end


#pragma mark - GridView

@interface GridView ()
@property (nonatomic, strong) NSMutableSet *reusableViews;
@property (nonatomic, assign) NSInteger firstVisibleIndex;
@property (nonatomic, assign) NSInteger lastVisibleIndex;
@property (nonatomic, assign) NSInteger previousItemsPerRow;
@property (nonatomic, strong) NSMutableSet *selectedCells;
@end

@implementation GridView

@synthesize dataSource = dataSource_;
@synthesize reusableViews = reusableViews_;
@synthesize firstVisibleIndex = firstVisibleIndex_;
@synthesize lastVisibleIndex = lastVisibleIndex_;
@synthesize previousItemsPerRow = previousItemsPerRow_;
@synthesize selectedCells = selectedCells_;
@synthesize allowsMultipleSelection = allowsMultipleSelection_;

- (void)commonInit
{
   // We keep a collection of reusable views. This 
   // improves scrolling performance by not requiring
   // creation of the view each and every time.
   self.reusableViews = [[NSMutableSet alloc] init];
   
   // We have no views visible at first so we
   // set index values high and low to trigger
   // the display during layoutSubviews.
   [self setFirstVisibleIndex:NSIntegerMax];
   [self setLastVisibleIndex:NSIntegerMin];
   [self setPreviousItemsPerRow:NSIntegerMin];
   
   [self setDelaysContentTouches:YES];
   [self setClipsToBounds:YES];
   [self setAlwaysBounceVertical:YES];
   
   [self setAllowsMultipleSelection:NO];
   self.selectedCells = [[NSMutableSet alloc] init];
   
   [self setAllowsMultipleSelection:NO];
   self.selectedCells = [[NSMutableSet alloc] init];
   
   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
   [self addGestureRecognizer:tap];
}

- (id)init
{
   self = [super init];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      [self commonInit];
   }
   return self;
}

- (id)dequeueReusableCell
{
   id view = [[self reusableViews] anyObject];
   if (view != nil) {
      [[self reusableViews] removeObject:view];
   }
   return view;
}

- (void)queueReusableCells
{
   for (UIView *view in [self subviews]) {
      if ([view isKindOfClass:[GridViewCell class]]) {
         [[self reusableViews] addObject:view];
         [view removeFromSuperview];
      }
   }
   
   [self setFirstVisibleIndex:NSIntegerMax];
   [self setLastVisibleIndex:NSIntegerMin];
   [[self selectedCells] removeAllObjects];
}

- (void)reloadData
{
   [self queueReusableCells];
   [self setNeedsLayout];
}

- (GridViewCell *)cellAtIndex:(NSInteger)index
{
   GridViewCell *cell = nil;
   if (index >= [self firstVisibleIndex] && index <= [self lastVisibleIndex]) {
      for (id view in [self subviews]) {
         if ([view isKindOfClass:[GridViewCell class]]) {
            if ([view indexInGrid] == index) {
               cell = view;
               break;
            }
         }
      }
   }
   
   if (cell == nil) {
      cell = [[self dataSource] gridView:self cellAtIndex:index];
   }
   
   return cell;
}

- (void)layoutSubviews
{
   [super layoutSubviews];
   
   CGRect visibleBounds = [self bounds];
   NSInteger visibleWidth = visibleBounds.size.width;
   NSInteger visibleHeight = visibleBounds.size.height;
   
   CGSize viewSize = [[self dataSource] gridViewCellSize:self];
   
   // Do some math to determine which rows and columns
   // are visible.
   NSInteger itemsPerRow = NSIntegerMin;
   if ([[self dataSource] respondsToSelector:@selector(gridViewCellsPerRow:)]) {
      itemsPerRow = [[self dataSource] gridViewCellsPerRow:self];
   }
   if (itemsPerRow == NSIntegerMin) {
      // Calculate the number of items per row.
      itemsPerRow = floor(visibleWidth / viewSize.width);
   }
   if (itemsPerRow != [self previousItemsPerRow]) {
      // Force re-load of grid views. Unfortunately this means
      // visible views will reload, which can hurt performance
      // when the view isn't cached. Need to find a better 
      // approach some day.
      [self queueReusableCells];
   }
   [self setPreviousItemsPerRow:itemsPerRow];
   
   // Ensure a minimum amount of space between views.
   NSInteger minimumSpace = 5;
   if (visibleWidth - itemsPerRow * viewSize.width < minimumSpace) {
      itemsPerRow--;
   }
   
   if (itemsPerRow < 1) itemsPerRow = 1;  // Ensure at least one view per row.
   
   NSInteger spaceWidth = round((visibleWidth - viewSize.width * itemsPerRow) / (itemsPerRow + 1));
   NSInteger spaceHeight = spaceWidth;
   
   // Calculate the content size for the scroll view.
   NSInteger viewCount = [[self dataSource] gridViewNumberOfCells:self];
   NSInteger rowCount = ceil(viewCount / (float)itemsPerRow);
   NSInteger rowHeight = viewSize.height + spaceHeight;
   CGSize contentSize = CGSizeMake(visibleWidth, (rowHeight * rowCount + spaceHeight));
   [self setContentSize:contentSize];
   
   NSInteger numberOfVisibleRows = visibleHeight / rowHeight;
   NSInteger topRow = MAX(0, floorf(visibleBounds.origin.y / rowHeight));
   NSInteger bottomRow = topRow + numberOfVisibleRows;
   
   CGRect extendedVisibleBounds = CGRectMake(visibleBounds.origin.x, MAX(0, visibleBounds.origin.y), visibleBounds.size.width, visibleBounds.size.height + rowHeight);
   
   // Recycle all views that are no longer visible.
   for (UIView *view in [self subviews]) {
      if ([view isKindOfClass:[GridViewCell class]]) {
         CGRect viewFrame = [view frame];
         
         // If the view doesn't intersect, it's not visible, so recycle it.
         if (!CGRectIntersectsRect(viewFrame, extendedVisibleBounds)) {
            [[self reusableViews] addObject:view];
            [view removeFromSuperview];
         }
      }
   }
   
   /////////////
   // Whew! We're now ready to layout the subviews.
   
   NSInteger startAtIndex = MAX(0, topRow * itemsPerRow);
   NSInteger stopAtIndex = MIN(viewCount, (bottomRow * itemsPerRow) + itemsPerRow);
   
   // Set the initial origin.
   NSInteger x = spaceWidth;
   NSInteger y = spaceHeight + (topRow * rowHeight);
   
   // Iterate through the needed views adding any views that are missing.
   for (NSInteger index = startAtIndex; index < stopAtIndex; index++) {
      
      // Set the frame so the view is placed into the correct position.
      GridViewCell *view = [self cellAtIndex:index];
      CGRect newFrame = CGRectMake(x, y, viewSize.width, viewSize.height);
      [view setFrame:newFrame];
      
      // If the index is between the first and last then the
      // view is not missing.
      BOOL isViewMissing = !(index >= [self firstVisibleIndex] && index < [self lastVisibleIndex]);
      if (isViewMissing) {
         [view setIndexInGrid:index];
         [self addSubview:view];
      }
      
      // Adjust the position.
      if ((index+1) % itemsPerRow == 0) {
         // Start new row.
         x = spaceWidth;
         y += viewSize.height + spaceHeight;
      } else {
         x += viewSize.width + spaceWidth;
      }
   }
   
   // Finally, remember which view indexes are visiable.
   [self setFirstVisibleIndex:startAtIndex];
   [self setLastVisibleIndex:stopAtIndex];
}

- (void)didTap:(UITapGestureRecognizer *)recognizer
{
   // Need to figure out if the user tapped a cell or not.
   // If a cell was tapped then let the data source know
   // which cell was tapped.
   
   CGPoint touchPoint = [recognizer locationInView:self];
   
   for (id view in [self subviews]) {
      if ([view isKindOfClass:[GridViewCell class]]) {
         if (CGRectContainsPoint([view frame], touchPoint)) {

            NSInteger previousIndex = -1;
            NSInteger selectedIndex = -1;
            
            NSMutableSet *selectedCells = [self selectedCells];
            if ([self allowsMultipleSelection] == NO) {
               // Out the old.
               previousIndex = [[selectedCells anyObject] indexInGrid];
               [selectedCells removeAllObjects];
               
               // And in with the new.
               selectedIndex = [view indexInGrid];
               [selectedCells addObject:view];

            } else {
               if ([selectedCells containsObject:view]) {
                  previousIndex = [view indexInGrid];
                  [selectedCells removeObject:view];
               } else {
                  selectedIndex = [view indexInGrid];
                  [selectedCells addObject:view];
               }
            }
            
            id <GridViewDataSource> dataSource = [self dataSource];
            if (previousIndex >= 0) {
               if ([dataSource respondsToSelector:@selector(gridView:didDeselectCellAtIndex:)]) {
                  [dataSource gridView:self didDeselectCellAtIndex:previousIndex];
               }
            }
            if (selectedIndex >= 0) {
               if ([dataSource respondsToSelector:@selector(gridView:didSelectCellAtIndex:)]) {
                  [dataSource gridView:self didSelectCellAtIndex:selectedIndex];
               }
            }
            
            break;
         }
      }
   }
}

- (NSInteger)indexForSelectedCell
{
   NSInteger selectedIndex = -1;
   GridViewCell *selectedCell = [[self selectedCells] anyObject];
   if (selectedCell) {
      selectedIndex = [selectedCell indexInGrid];
   }
   return selectedIndex;
}

- (NSArray *)indexesForSelectedCells
{
   NSArray *selectedIndexes = nil;
   NSInteger count = [[self selectedCells] count];
   if (count > 0) {
      NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:count];
      for (GridViewCell *cell in [self selectedCells]) {
         NSInteger indexInGrid = [cell indexInGrid];
         [mutableArray addObject:[NSNumber numberWithInteger:indexInGrid]];
      }
      selectedIndexes = [NSArray arrayWithArray:mutableArray];
   }
   return selectedIndexes;
}

@end

