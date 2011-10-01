//
//  WheelView.m
//  PhotoWheelPrototype
//
//  Created by Kirby Turner on 9/24/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "WheelView.h"
#import <QuartzCore/QuartzCore.h>
#import "SpinGestureRecognizer.h"

#pragma mark - WheelViewCell

@interface WheelViewCell ()
@property (nonatomic, assign) NSInteger indexInWheelView;
@end

@implementation WheelViewCell
@synthesize indexInWheelView = indexInWheelView_;
@end


#pragma mark - WheelView

@interface WheelView ()
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, strong) NSMutableSet *reusableCells;

// The visible cell indexes are stored in a mutable dictionary
// instead of a mutable array because the number of visible cells
// can change. Using an array requires additional logic to maintain
// the dimensions of the array. This is avoided by using the 
// dictionary where the key represents the element index number.
@property (nonatomic, strong) NSMutableDictionary *visibleCellIndexes;
@end

@implementation WheelView

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize style = _style;
@synthesize currentAngle = _currentAngle;
@synthesize selectedIndex = _selectedIndex;
@synthesize reusableCells = _reusableCells;
@synthesize visibleCellIndexes = _visibleCellIndexes;
@synthesize angleOffset = _angleOffset;

- (void)commonInit
{
   [self setSelectedIndex:-1];
   [self setCurrentAngle:0.0];
   
   [self setVisibleCellIndexes:[[NSMutableDictionary alloc] init]];
   
   SpinGestureRecognizer *spin = [[SpinGestureRecognizer alloc] 
                                  initWithTarget:self action:@selector(spin:)];
   [self addGestureRecognizer:spin];
   
   self.reusableCells = [[NSMutableSet alloc] init];
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

- (NSInteger)numberOfCells
{
   NSInteger cellCount = 0;
   id<WheelViewDataSource> dataSource = [self dataSource];
   if ([dataSource respondsToSelector:@selector(wheelViewNumberOfCells:)]) {
      cellCount = [dataSource wheelViewNumberOfCells:self];
   }
   return cellCount;
}

- (NSInteger)numberOfVisibleCells
{
   NSInteger cellCount = [self numberOfCells];
   NSInteger numberOfVisibleCells = cellCount;
   id<WheelViewDelegate> delegate = [self delegate];
   if (delegate && 
       [delegate respondsToSelector:@selector(wheelViewNumberOfVisibleCells:)]) 
   {
      numberOfVisibleCells = [delegate wheelViewNumberOfVisibleCells:self];
   }
   return numberOfVisibleCells;
}

- (BOOL)isSelectedItemForAngle:(CGFloat)angle
{
   // The selected item is one whose angle is
   // at or near 0 degrees.
   //
   // To calculate the selected item based on the 
   // angle, we must convert the angle to the 
   // relative angle between 0 and 360 degrees.
   
   CGFloat relativeAngle = fabsf(fmodf(angle, 360.0));
   
   // Pad the selection point so it does not
   // have to be exact.
   CGFloat padding = 20.0;   // Allow 20 degrees on either side.
   
   BOOL isSelectedItem = 
      relativeAngle >= (360.0 - padding) || relativeAngle <= padding;
   return isSelectedItem;
}

- (BOOL)isIndexVisible:(NSInteger)index
{
   NSNumber *cellIndex = [NSNumber numberWithInteger:index];
   __block BOOL visible = NO;
   void (^enumerateBlock) (id, id, BOOL *) = ^(id key, id obj, BOOL *stop) {
      if ([obj isEqual:cellIndex]) {
         visible = YES;
         *stop = YES;
      }
   };
   [[self visibleCellIndexes] enumerateKeysAndObjectsUsingBlock:enumerateBlock];
   return visible;
}

- (void)queueNonVisibleCells
{
   NSArray *subviews = [self subviews];
   for (id view in subviews) {
      if ([view isKindOfClass:[WheelViewCell class]]) {
         NSInteger index = [(WheelViewCell *)view indexInWheelView];
         BOOL visible = [self isIndexVisible:index];
         if (!visible) {
            [[self reusableCells] addObject:view];
            [view removeFromSuperview];
         }
      }
   }
}

- (NSInteger)cellIndexForIndex:(NSInteger)index
{
   NSInteger numberOfCells = [self numberOfCells];
   NSInteger numberOfVisibleCells = [self numberOfVisibleCells];
   NSInteger offset = MAX([self selectedIndex], 0);
   
   NSInteger cellIndex;
   if (index < (numberOfVisibleCells/2)) {
      cellIndex = index + offset;
      if (cellIndex > numberOfCells - 1) cellIndex = cellIndex - numberOfCells;
   } else {
      cellIndex = offset - (numberOfVisibleCells - index);
      if (cellIndex < 0) cellIndex = numberOfCells + cellIndex;
   }
   
   return cellIndex;
}

- (NSSet*)cellIndexesToDisplay
{
   NSInteger numberOfVisibleCells = [self numberOfVisibleCells];
   NSMutableSet *cellIndexes = 
      [[NSMutableSet alloc] initWithCapacity:numberOfVisibleCells];
   for (NSInteger index = 0; index < numberOfVisibleCells; index++)
   {
      NSInteger cellIndex = [self cellIndexForIndex:index];
      [cellIndexes addObject:[NSNumber numberWithInteger:cellIndex]];
   }
   return cellIndexes;
}

- (void)setAngle:(CGFloat)angle
{
   [self queueNonVisibleCells];
   NSSet *cellIndexesToDisplay = [self cellIndexesToDisplay];
   
   // The following code is inspired by the carousel example at
   // http://stackoverflow.com/questions/5243614/3d-carousel-effect-on-the-ipad
   
   CGPoint center = CGPointMake(CGRectGetMidX([self bounds]), 
                                CGRectGetMidY([self bounds]));
   CGFloat radiusX = MIN([self bounds].size.width, 
                         [self bounds].size.height) * 0.35;
   CGFloat radiusY = radiusX;
   if ([self style] == WheelViewStyleCarousel) {
      radiusY = radiusX * 0.30;
   }
   
   NSInteger numberOfVisibleCells = [self numberOfVisibleCells];
   float angleToAdd = 360.0f / numberOfVisibleCells;
   
   // If there are more cells than the number of visible cells,
   // we wrap the cells. Wrapping allows all cells to display
   // within a finite number of visible cells. Cells are displayed in 
   // sequential order. When the end is reached, the display wraps
   // to the beginning. 
   // 
   // Because there is a finite number of visible cells, one cell
   // is replaced with a wrapping cell as the user scrolls through
   // (spins) the wheel. At any given time there is one and only one
   // cell that requires replacing. The cell to replace is determined
   // by comparing the contents of visibleCellIndexes to
   // cellIndexesToDisplay.
   // visibleCellIndexes can contain one index not found in
   // cellIndexesToDisplay.
   // This is the index that is replaced. It is replaced with the one
   // index in cellIndexesToDisplay not found in visibleCellIndexes.
   
   BOOL wrap = [self numberOfCells] > numberOfVisibleCells;
   
   // Lay out visible cells.
   for (NSInteger index = 0; index < numberOfVisibleCells; index++)
   {
      NSNumber *cellIndexNumber;
      if (wrap) {
         cellIndexNumber = [[self visibleCellIndexes] 
                            objectForKey:[NSNumber numberWithInteger:index]];
         if (cellIndexNumber == nil) {
            // First time through, visibleCellIndexes is empty, hence the nil
            // cellIndexNumber. Initialize it with the appropriate cell
            // index.
            cellIndexNumber = 
               [NSNumber numberWithInteger:[self cellIndexForIndex:index]];
         }
      } else {
         // Cell indexes are sequential when wrapping is turned off.
         cellIndexNumber = [NSNumber numberWithInteger:index];
      }
      
      
      if (wrap && ![cellIndexesToDisplay containsObject:cellIndexNumber]) {
         // Replace the wrapping cell index.
         __block NSNumber *replacementNumber = nil;
         NSArray *array = [[self visibleCellIndexes] allValues];
         void (^enumerateBlock) (id, BOOL *) = ^(id obj, BOOL *stop) {
            if (![array containsObject:obj]) {
               replacementNumber = obj;
               *stop = YES;
            }
         };
         [cellIndexesToDisplay enumerateObjectsUsingBlock:enumerateBlock];
         
         cellIndexNumber = replacementNumber;
      }
      
      NSInteger cellIndex = [cellIndexNumber integerValue];
      WheelViewCell *cell = [self cellAtIndex:cellIndex];
      
      if (cell == nil) {
         cellIndex = -1;   // No cell, no cell index.
      }
      
      // If index is not within the visible indexes, the
      // cell is missing from the view and it must be added.
      BOOL visible = [self isIndexVisible:cellIndex];
      if (!visible) {
         [[self visibleCellIndexes] setObject:cellIndexNumber 
                                       forKey:[NSNumber numberWithInteger:index]];
         [cell setIndexInWheelView:cellIndex];
         [self addSubview:cell];
      }
      
      // Set the selected index if it has changed.
      if (cellIndex != [self selectedIndex] && 
          [self isSelectedItemForAngle:angle])
      {
         [self setSelectedIndex:cellIndex];
         if ([[self dataSource] 
              respondsToSelector:@selector(wheelView:didSelectCellAtIndex:)]) 
         {
            [[self dataSource] wheelView:self didSelectCellAtIndex:cellIndex];
         }
      }
      
      float angleInRadians = ((angle + [self angleOffset]) + 180.0) * M_PI / 180.0f;
      
      // Get a position based on the angle
      float xPosition = center.x + (radiusX * sinf(angleInRadians)) 
                        - (CGRectGetWidth([cell frame]) / 2);
      float yPosition = center.y + (radiusY * cosf(angleInRadians)) 
                        - (CGRectGetHeight([cell frame]) / 2);
      
      float scale = 0.75f + 0.25f * (cosf(angleInRadians) + 1.0);
      
      // Apply location and scale
      if ([self style] == WheelViewStyleCarousel) {
         [cell setTransform:CGAffineTransformScale(
                     CGAffineTransformMakeTranslation(xPosition, yPosition), 
                     scale, scale)];         
         // Tweak alpha using the same system as applied for scale, this time
         // with 0.3 the minimum and a semicircle range of 0.5
         [cell setAlpha:(0.3f + 0.5f * (cosf(angleInRadians) + 1.0))];
         
      } else {
         [cell setTransform:CGAffineTransformMakeTranslation(xPosition, 
                                                             yPosition)];
         [cell setAlpha:1.0];
      }
      
      [[cell layer] setZPosition:scale];         
      
      // Work out what the next angle is going to be
      angle += angleToAdd;
   }
}

- (void)layoutSubviews
{
   [self setAngle:[self currentAngle]];
}

- (void)setStyle:(WheelViewStyle)newStyle
{
   if (_style != newStyle) {
      _style = newStyle;
      
      [UIView beginAnimations:@"WheelViewStyleChange" context:nil];
      [self setAngle:[self currentAngle]];
      [UIView commitAnimations];
   }
}

- (void)spin:(SpinGestureRecognizer *)recognizer
{
   CGFloat angleInRadians = -[recognizer rotation];
   CGFloat degrees = 180.0 * angleInRadians / M_PI;   // Radians to degrees
   [self setCurrentAngle:[self currentAngle] + degrees];
   [self setAngle:[self currentAngle]];
}

- (id)dequeueReusableCell
{
   id view = [[self reusableCells] anyObject];
   if (view != nil) {
      [[self reusableCells] removeObject:view];
   }
   return view;
}

- (void)queueReusableCells
{
   for (UIView *view in [self subviews]) {
      if ([view isKindOfClass:[WheelViewCell class]]) {
         [[self reusableCells] addObject:view];
         [view removeFromSuperview];
      }
   }
   
   [[self visibleCellIndexes] removeAllObjects];
   [self setSelectedIndex:-1];
}

- (void)reloadData
{
   [self queueReusableCells];
   [self layoutSubviews];
}

- (WheelViewCell *)cellAtIndex:(NSInteger)index
{
   if (index < 0 || index > [self numberOfCells] - 1) {
      return nil;
   }
   
   WheelViewCell *cell = nil;
   BOOL visible = [self isIndexVisible:index];
   if (visible) {
      for (id view in [self subviews]) {
         if ([view isKindOfClass:[WheelViewCell class]]) {
            if ([view indexInWheelView] == index) {
               cell = view;
               break;
            }
         }
      }
   }
   
   if (cell == nil) {
      cell = [[self dataSource] wheelView:self cellAtIndex:index];
   }
   
   return cell;
}

- (void)setAngleOffset:(CGFloat)angleOffset
{
   if (_angleOffset != angleOffset) {
      _angleOffset = -angleOffset;
      [self layoutSubviews];
   }
}

@end
