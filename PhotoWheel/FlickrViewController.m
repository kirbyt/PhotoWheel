//
//  FlickrViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 12/16/12.
//  Copyright (c) 2012 White Peak Software Inc. All rights reserved.
//

#import "FlickrViewController.h"
#import "SimpleFlickrAPI.h"
#import "ImageDownloader.h"
#import "Photo.h"
#import "PhotoAlbum.h"

@interface FlickrViewController ()
@property (nonatomic, strong) NSArray *flickrPhotos;
@property (nonatomic, strong) NSMutableArray *downloaders;
@property (nonatomic, assign) NSInteger showOverlayCount;
@end

@implementation FlickrViewController

- (void)viewDidLoad
{
   [super viewDidLoad];

   [self setFlickrPhotos:[NSArray array]];
   [[self overlayView] setAlpha:0.0];
   
   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayViewTapped:)];
   [[self overlayView] addGestureRecognizer:tap];
   
   [[self collectionView] setAlwaysBounceVertical:YES];
   [[self collectionView] setAllowsMultipleSelection:YES];
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
   return NO;
}

#pragma mark - Save photos

- (void)saveContextAndExit
{
   PhotoAlbum *photoAlbum = [self photoAlbum];
   NSManagedObjectContext *context = [photoAlbum managedObjectContext];
   NSError *error = nil;
   ZAssert([context save:&error], @"Unresolved error %@, %@", error, [error userInfo]);
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSelectedPhotos
{
   PhotoAlbum *photoAlbum = [self photoAlbum];
   NSManagedObjectContext *context = [photoAlbum managedObjectContext];
   
   NSArray *indexes = [[self collectionView] indexPathsForSelectedItems];
   __block NSInteger count = [indexes count];
   
   if (count == 0) {
      [self dismissViewControllerAnimated:YES completion:nil];
      return;
   }
   
   ImageDownloaderCompletionBlock completion =
   ^(UIImage *image, NSError *error) {
      NSLog(@"block: count: %i", count);
      if (image) {
         Photo *newPhoto = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Photo"
                            inManagedObjectContext:context];
         [newPhoto setDateAdded:[NSDate date]];
         [newPhoto saveImage:image];
         [newPhoto setPhotoAlbum:photoAlbum];
      } else {
         NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__,
               [error localizedDescription]);
      }
      
      count--;
      if (count == 0) {
         [self saveContextAndExit];
      }
   };
   
   for (NSIndexPath *indexPath in indexes) {
      NSInteger index = [indexPath item];
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
   [[self overlayView] setUserInteractionEnabled:NO];
   
   void (^animations)(void) = ^ {
      [[self overlayView] setAlpha:0.4];
      [[self activityIndicator] startAnimating];
   };
   
   [UIView animateWithDuration:0.2 animations:animations];
   
   [self saveSelectedPhotos];
}

- (IBAction)cancel:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Overlay methods

- (void)showOverlay:(BOOL)showOverlay
{
   BOOL isVisible = ([[self overlayView] alpha] > 0.0);
   if (isVisible != showOverlay) {
      CGFloat alpha = showOverlay ? 0.4 : 0.0;
      void (^animations)(void) = ^ {
         [[self overlayView] setAlpha:alpha];
         [[self searchBar] setShowsCancelButton:showOverlay animated:YES];
      };
      
      void (^completion)(BOOL) = ^(BOOL finished) {
         if (finished) {
            // Do other cleanup if needed.
         }
      };
      
      [UIView animateWithDuration:0.2 animations:animations
                       completion:completion];
   }
}

- (void)showOverlay
{
   self.showOverlayCount += 1;
   BOOL showOverlay = (self.showOverlayCount > 0);
   [self showOverlay:showOverlay];
}

- (void)hideOverlay
{
   self.showOverlayCount -= 1;
   BOOL showOverlay = (self.showOverlayCount > 0);
   [self showOverlay:showOverlay];
   if (self.showOverlayCount < 0) {
      self.showOverlayCount = 0;
   }
}

- (void)overlayViewTapped:(UITapGestureRecognizer *)recognizer
{
   [self hideOverlay];
   [[self searchBar] resignFirstResponder];
}

#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString:(NSString *)searchString
{
   [[self activityIndicator] startAnimating];
   [self showOverlay];
   [[self overlayView] setUserInteractionEnabled:NO];
   
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
      NSArray *photos = [flickr photosWithSearchString:searchString];
      
      NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
      for (NSInteger index = 0; index < [photos count]; index++) {
         ImageDownloader *downloader = [[ImageDownloader alloc] init];
         [downloaders addObject:downloader];
      }
      
      [self setDownloaders:downloaders];
      [self setFlickrPhotos:photos];
      
      dispatch_async(dispatch_get_main_queue(), ^{
         [[self collectionView] reloadData];
         [self hideOverlay];
         [[self overlayView] setUserInteractionEnabled:YES];
         [[self searchBar] resignFirstResponder];
         [[self activityIndicator] stopAnimating];
      });
   });
}

#pragma mark - UISearchBarDelegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
   [self showOverlay];
   return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
   [searchBar resignFirstResponder];
   [self hideOverlay];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
   [self fetchFlickrPhotoWithSearchString:[searchBar text]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
   [searchBar resignFirstResponder];
   [self hideOverlay];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   NSInteger count = [[self flickrPhotos] count];
   return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

   UIImageView *photoImageView = (UIImageView *)[cell viewWithTag:1];
   UIImageView *selectedImageView = (UIImageView *)[cell viewWithTag:2];
   
   NSArray *selectedIndexPaths = [collectionView indexPathsForSelectedItems];
   BOOL isSelected = [selectedIndexPaths containsObject:indexPath];
   [selectedImageView setHidden:!isSelected];
   
   ImageDownloaderCompletionBlock completion =
   ^(UIImage *image, NSError *error) {
      if (image) {
         [photoImageView setImage:image];
      } else {
         NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__,
               [error localizedDescription]);
      }
   };

   NSInteger index = [indexPath item];
   NSArray *downloaders = [self downloaders];
   ImageDownloader *downloader = [downloaders objectAtIndex:index];
   UIImage *image = [downloader image]; 
   if (image) {
      [photoImageView setImage:image];
   } else {
      NSDictionary *flickrPhoto = [[self flickrPhotos] objectAtIndex:index];
      NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"url_sq"]];
      [downloader downloadImageAtURL:URL completion:completion];
   }
   
   return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
   UIImageView *selectedImageView = (UIImageView *)[cell viewWithTag:2];
   [selectedImageView setHidden:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
   UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
   UIImageView *selectedImageView = (UIImageView *)[cell viewWithTag:2];
   [selectedImageView setHidden:YES];
}

@end
