//
//  GridView.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/21/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "GridView.h"
#import "WheelView.h"


@interface GridView ()
@property (nonatomic, retain) NSMutableSet *reusableViews;
@property (nonatomic, assign) NSInteger firstVisibleIndex;
@property (nonatomic, assign) NSInteger lastVisibleIndex;
@property (nonatomic, assign) NSInteger previousItemsPerRow;
@end

@implementation GridView

@synthesize dataSource = dataSource_;
@synthesize reusableViews = reusableViews_;
@synthesize firstVisibleIndex = firstVisibleIndex_;
@synthesize lastVisibleIndex = lastVisibleIndex_;
@synthesize previousItemsPerRow = previousItemsPerRow_;

- (void)dealloc
{
   [reusableViews_ release], reusableViews_ = nil;
   [super dealloc];
}

- (void)commonInit
{
   // We keep a collection of reusable views. This 
   // improves scrolling performance by not requiring
   // creation of the view each and every time.
   NSMutableSet *newSet = [[NSMutableSet alloc] init];
   [self setReusableViews:newSet];
   [newSet release];
   
   // We have no views visible at first so we
   // set index values high and low to trigger
   // the display during layoutSubviews.
   [self setFirstVisibleIndex:NSIntegerMax];
   [self setLastVisibleIndex:NSIntegerMin];
   [self setPreviousItemsPerRow:NSIntegerMin];
   
   [self setDelaysContentTouches:YES];
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

- (GridViewCell *)dequeueReusableView
{
   GridViewCell *view = [[self reusableViews] anyObject];
   if (view != nil) {
      // The only object retaining the view is the reusableView
      // set, so we retain/autorelease it before returning it.
      // This prevents the view from immediately deallocating
      // when removed from the set.
      [[view retain] autorelease];
      [[self reusableViews] removeObject:view];
   }
   return view;
}

- (void)queueReusableViews
{
   for (UIView *view in [self subviews]) {
      if ([view isKindOfClass:[WheelView class]]) {
         [[self reusableViews] addObject:view];
         [view removeFromSuperview];
      }
   }
   
   [self setFirstVisibleIndex:NSIntegerMax];
   [self setLastVisibleIndex:NSIntegerMin];
}

- (void)reloadData
{
   [self queueReusableViews];
   [self setNeedsLayout];
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
      [self queueReusableViews];
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
   NSInteger viewCount = [[self dataSource] gridViewNumberOfViews:self];
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
      // If the index is between the first and last then the
      // view is not missing.
      BOOL isViewMissing = !(index >= [self firstVisibleIndex] && index < [self lastVisibleIndex]);
      
      if (isViewMissing) {
         GridViewCell *view = [[self dataSource] gridView:self viewAtIndex:index];
         
         // Set the frame so the view is inserted into the correct position.
         CGRect newFrame = CGRectMake(x, y, viewSize.width, viewSize.height);
         [view setFrame:newFrame];
         
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


@end

#pragma mark - GridViewCell

@implementation GridViewCell

@end