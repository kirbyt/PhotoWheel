//
//  PhotoNubMenuViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/10/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoNubMenuViewController.h"
#import "UIDevice+KTDeviceExtensions.h"

@interface PhotoNubMenuViewController ()
@property (nonatomic, retain) NSArray *data;
- (void)pickFromCamera;
- (void)pickFromLibrary;
- (void)pickFromFlickr;
@end

@implementation PhotoNubMenuViewController

@synthesize data = data_;

- (void)dealloc
{
   [data_ release], data_ = nil;
   [super dealloc];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   NSMutableArray *newData = [[NSMutableArray alloc] init];
   if ([UIDevice kt_hasCamera]) {
      [newData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Camera", @"text", @"pickFromCamera", @"selector", nil]];
   }
   [newData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Library", @"text", @"pickFromLibrary", @"selector", nil]];
   [newData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Flickr", @"text", @"pickFromFlickr", @"selector", nil]];
   [self setData:newData];
   [newData release];
}


#pragma mark -
#pragma mark Actions

- (void)pickFromCamera
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)pickFromLibrary
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)pickFromFlickr
{
   NSLog(@"%s", __PRETTY_FUNCTION__);
}


#pragma mark -
#pragma mark UITableViewDelegate and UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   NSInteger count = [[self data] count];
   return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSString *CellIdentifier = NSStringFromClass([self class]);
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
      [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
   }
   
   // Configure the cell.
   NSDictionary *dict = [[self data] objectAtIndex:[indexPath row]];
   [[cell textLabel] setText:[dict objectForKey:@"text"]];
   
   return cell;
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSDictionary *dict = [[self data] objectAtIndex:[indexPath row]];
   SEL selector = NSSelectorFromString([dict objectForKey:@"selector"]);
   [self performSelector:selector];
}


@end
