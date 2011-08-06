//
//  FlickrViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 8/6/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import "FlickrViewController.h"
#import "ImageGridViewCell.h"
#import "SimpleFlickrAPI.h"
#import "ImageDownloader.h"
#import "Photo.h"
#import "PhotoAlbum.h"

@interface FlickrViewController ()
@property (nonatomic, strong) NSArray *flickrPhotos;
@property (nonatomic, strong) NSMutableArray *downloaders;
@end

@implementation FlickrViewController

@synthesize gridView = gridView_;
@synthesize overlayView = overlayView_;
@synthesize searchBar = searchBar_;
@synthesize activityIndicator = activityIndicator_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize objectID = objectID_;
@synthesize flickrPhotos = flickrPhotos_;
@synthesize downloaders = downloaders_;

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.flickrPhotos = [NSArray array];
   [[self overlayView] setAlpha:0.0];
   
   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayViewTapped:)];
   [[self overlayView] addGestureRecognizer:tap];
   
   [[self gridView] setAlwaysBounceVertical:YES];
   [[self gridView] setAllowsMultipleSelection:YES];
}

- (void)viewDidUnload
{
   [self setGridView:nil];
   [self setOverlayView:nil];
   [self setSearchBar:nil];
   [self setActivityIndicator:nil];
   [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

#pragma mark - Save Photos

- (void)saveContextAndExit
{
   NSManagedObjectContext *context = [self managedObjectContext];
   NSError *error = nil;
   if (![context save:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
   
   [self dismissModalViewControllerAnimated:YES];
}

- (void)saveSelectedPhotos
{
   NSManagedObjectContext *context = [self managedObjectContext];
   id photoAlbum = [context objectWithID:[self objectID]];
   NSAssert(photoAlbum, @"nil photo album");

   NSArray *indexes = [[self gridView] indexesForSelectedCells];
   __block NSInteger count = [indexes count];
   
   if (count == 0) {
      [self dismissModalViewControllerAnimated:YES];
      return;
   }

   ImageDownloaderCompletionBlock completion = ^(UIImage *image, NSError *error) {
      NSLog(@"block: count: %i", count);
      if (image) {
         Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
         [newPhoto setDateAdded:[NSDate date]];
         [newPhoto saveImage:image];
         [newPhoto setPhotoAlbum:photoAlbum];
      } else {
         NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
      }
      
      count--;
      if (count == 0) {
         [self saveContextAndExit];
      }
   };
   
   for (NSNumber *indexNumber in indexes) {
      NSInteger index = [indexNumber integerValue];
      NSDictionary *flickrPhoto = [[self flickrPhotos] objectAtIndex:index];
      NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"url_m"]];
      NSLog(@"URL: %@", URL);
      ImageDownloader *downloader = [[ImageDownloader alloc] init];
      [downloader downloadImageAtURL:URL completion:completion];
      
      [[self downloaders] addObject:downloader];
   }
}

#pragma mark - Actions

- (IBAction)save:(id)sender
{
   void (^animations)(void) = ^ {
      [[self overlayView] setAlpha:0.4];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      if (finished) {
         [[self activityIndicator] startAnimating];
      }
   };
   
   [UIView animateWithDuration:0.2 animations:animations completion:completion];
   [self saveSelectedPhotos];
}

- (IBAction)cancel:(id)sender
{
   [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Overlay Methods

- (void)overlayViewTapped:(UITapGestureRecognizer *)recognizer
{
   [[self overlayView] setAlpha:0.0];
   [[self searchBar] resignFirstResponder];
}

- (void)showsOverlay:(BOOL)showsOverlay
{
   CGFloat alpha = showsOverlay ? 0.4 : 0.0;
   void (^animations)(void) = ^ {
      [[self overlayView] setAlpha:alpha];
      [[self searchBar] setShowsCancelButton:showsOverlay animated:YES];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      if (finished) {
      }
   };
   
   [UIView animateWithDuration:0.2 animations:animations completion:completion];
}

#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString:(NSString *)searchString
{
   SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
   NSArray *photos = [flickr photosWithSearchString:searchString];

   NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
   for (NSInteger index = 0; index < [photos count]; index++) {
      ImageDownloader *downloader = [[ImageDownloader alloc] init];
      [downloaders addObject:downloader];
   }
   
   [self setDownloaders:downloaders];
   [self setFlickrPhotos:photos];
   [[self gridView] reloadData];
   [[self searchBar] resignFirstResponder];
}

#pragma mark - UISearchBarDelegate Methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
   [self showsOverlay:YES];
   return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
   [searchBar resignFirstResponder];
   [self showsOverlay:NO];
   [self fetchFlickrPhotoWithSearchString:[searchBar text]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
   [searchBar resignFirstResponder];
   [self showsOverlay:NO];
}

#pragma mark - GridViewDataSource Methods

- (NSInteger)gridViewNumberOfCells:(GridView *)gridView
{
   NSInteger count = [[self flickrPhotos] count];
   return count;
}

- (GridViewCell *)gridView:(GridView *)gridView cellAtIndex:(NSInteger)index
{
   ImageGridViewCell *cell = [gridView dequeueReusableCell];
   if (cell == nil) {
      cell = [ImageGridViewCell imageGridViewCellWithSize:CGSizeMake(75, 75)];
   }
   
   ImageDownloaderCompletionBlock completion = ^(UIImage *image, NSError *error) {
      if (image) {
         [cell setImage:image withShadow:NO];
      } else {
         NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
      }
   };
   
   ImageDownloader *downloader = [[self downloaders] objectAtIndex:index];
   UIImage *image = [downloader image];
   if (image) {
      [cell setImage:image withShadow:NO];
   } else {
      NSDictionary *flickrPhoto = [[self flickrPhotos] objectAtIndex:index];
      NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"url_sq"]];
      [downloader downloadImageAtURL:URL completion:completion];
   }
   
   return cell;
}

- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return CGSizeMake(75, 75);
}

- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index
{
   id cell = [gridView cellAtIndex:index];
   [cell setSelected:YES];
}

- (void)gridView:(GridView *)gridView didDeselectCellAtIndex:(NSInteger)index
{
   id cell = [gridView cellAtIndex:index];
   [cell setSelected:NO];
}

@end
