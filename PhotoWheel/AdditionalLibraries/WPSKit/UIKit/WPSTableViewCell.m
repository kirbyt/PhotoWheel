/**
 **   WPSTableViewCell
 **
 **   Created by Kirby Turner.
 **   Copyright 2011 White Peak Software. All rights reserved.
 **
 **   Permission is hereby granted, free of charge, to any person obtaining 
 **   a copy of this software and associated documentation files (the 
 **   "Software"), to deal in the Software without restriction, including 
 **   without limitation the rights to use, copy, modify, merge, publish, 
 **   distribute, sublicense, and/or sell copies of the Software, and to permit 
 **   persons to whom the Software is furnished to do so, subject to the 
 **   following conditions:
 **
 **   The above copyright notice and this permission notice shall be included 
 **   in all copies or substantial portions of the Software.
 **
 **   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
 **   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 **   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
 **   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
 **   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 **   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 **   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **
 **   This code is based on the smart table view cell code
 **   presented in the book iOS Receipts.
 **   http://pragprog.com/titles/cdirec/ios-recipes
 **
 **/

#import "WPSTableViewCell.h"

@implementation WPSTableViewCell

#pragma mark - Cell Generation

+ (NSString *)cellIdentifier 
{
   return NSStringFromClass([self class]);
}

+ (id)cellForTableView:(UITableView *)tableView 
{
   NSString *cellID = [self cellIdentifier];
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
   if (cell == nil) {
      cell = [[self alloc] initWithCellIdentifier:cellID];
   }
   return cell;    
}

+ (id)cellForTableView:(UITableView *)tableView fromNib:(UINib *)nib 
{
   NSString *cellID = [self cellIdentifier];
   UITableViewCell *cell = [tableView 
                            dequeueReusableCellWithIdentifier:cellID];
   if (cell == nil) {
      NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
      NSAssert2(([nibObjects count] > 0) && 
                [[nibObjects objectAtIndex:0] isKindOfClass:[self class]],
                @"Nib '%@' does not appear to contain a valid %@", 
                [self nibName], NSStringFromClass([self class]));
      cell = [nibObjects objectAtIndex:0];
   }
   return cell;    
}

+ (id)cellFromDefaultNibForTableView:(UITableView *)tableView
{
   return [self cellForTableView:tableView fromNib:[self nib]];
}

- (id)initWithCellIdentifier:(NSString *)cellID 
{
   return [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
}

#pragma mark - NIB Support
+ (UINib *)nib 
{
   NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
   return [UINib nibWithNibName:[self nibName] bundle:classBundle];
}

+ (NSString *)nibName 
{
   return [self cellIdentifier];
}

@end
