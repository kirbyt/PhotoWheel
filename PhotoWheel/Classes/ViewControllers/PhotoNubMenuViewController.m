//
//  PhotoNubMenuViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 4/10/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "PhotoNubMenuViewController.h"
#import "PhotoNubViewController.h"
#import "UIDevice+KTDeviceExtensions.h"

@interface PhotoNubMenuViewController ()
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) UIImagePickerController *imagePicker;
- (void)pickFromCamera;
- (void)pickFromLibrary;
- (void)pickFromFlickr;
@end


@implementation PhotoNubMenuViewController

@synthesize viewController = viewController_;
@synthesize data = data_;
@synthesize imagePicker = imagePicker_;

- (void)dealloc
{
   [data_ release], data_ = nil;
   [imagePicker_ release], imagePicker_ = nil;
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
   UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
   [imagePicker setDelegate:self];
   [imagePicker setAllowsEditing:NO];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   [[[self viewController] popoverController] setContentViewController:imagePicker];
   [imagePicker release];
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


#pragma mark -
#pragma mark UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   [[[self viewController] popoverController] dismissPopoverAnimated:YES];
   
   NSDictionary *dict = [info objectForKey:UIImagePickerControllerMediaMetadata];
   NSLog(@"dict: %@", dict);
   
//   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
   [[[self viewController] popoverController] dismissPopoverAnimated:YES];
}


@end
