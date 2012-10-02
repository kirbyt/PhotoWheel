//
//  FlickrViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
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
@property (nonatomic, assign) NSInteger showOverlayCount;
@end

@implementation FlickrViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [[self gridView] setAllowsMultipleSelection:YES];
   
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

- (BOOL)disablesAutomaticKeyboardDismissal
{
   return NO;
}

#pragma mark - Save photos

- (void)saveContextAndExit:(NSManagedObjectContext *)context
{
   NSError *error = nil;
   ZAssert([context save:&error], @"Core Data save error: %@\n%@", [error localizedDescription], [error userInfo]);
   [context reset];
   
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSelectedPhotos
{
   NSManagedObjectContext *mainContext = [self managedObjectContext];
   NSPersistentStoreCoordinator *coordinator = [mainContext persistentStoreCoordinator];
   // Create a separate context for saving the data. This is done so the
   // context can be reset and work around the annoying _deleteExternalReferenceFromPermanentLocation
   // bug.
   NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
   [context setPersistentStoreCoordinator:coordinator];

   id photoAlbum = [context objectWithID:[self objectID]];
   
   NSArray *indexPaths = [[self gridView] indexPathsForSelectedItems];
   __block NSInteger count = [indexPaths count];
   
   if (count == 0) {
      [self dismissViewControllerAnimated:YES completion:nil];
      return;
   }
   
   ImageDownloaderCompletionBlock completion = 
      ^(UIImage *image, NSError *error) {
      DLog(@"block: count: %i", count);
      if (image) {
         Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
         [newPhoto setDateAdded:[NSDate date]];
         [newPhoto saveImage:image];
         [newPhoto setPhotoAlbum:photoAlbum];
      } else {
         DLog(@"Image download error: %@\n%@",[error localizedDescription], [error userInfo]);
      }
      
      count--;
      if (count == 0) {
         [self saveContextAndExit:context];
      }
   };
   
   for (NSIndexPath *indexPath in indexPaths) {
      NSDictionary *flickrPhoto = [[self flickrPhotos] objectAtIndex:[indexPath item]];
      NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"url_m"]];
      DLog(@"URL: %@", URL);
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
      
      [UIView animateWithDuration:0.2 animations:animations completion:completion];
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
      
      NSMutableArray *downloaders = [[NSMutableArray alloc] 
                                     initWithCapacity:[photos count]];
      for (NSInteger index = 0; index < [photos count]; index++) {
         ImageDownloader *downloader = [[ImageDownloader alloc] init];
         [downloaders addObject:downloader];
      }
      
      [self setDownloaders:downloaders];
      [self setFlickrPhotos:photos];
      
      dispatch_async(dispatch_get_main_queue(), ^{
         [[self gridView] reloadData];
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

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   NSInteger count = [[self flickrPhotos] count];
   return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   ImageGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageGridViewCell" forIndexPath:indexPath];
 
   ImageDownloaderCompletionBlock completion = ^(UIImage *image, NSError *error) {
      if (image) {
         [[cell imageView] setImage:image];
      } else {
         DLog(@"Image download error: %@\n%@", [error localizedDescription], [error userInfo]);
      }
   };

   ImageDownloader *downloader = [[self downloaders] objectAtIndex:[indexPath item]];
   UIImage *image = [downloader image];
   if (image) {
      [[cell imageView] setImage:image];
   } else {
      NSDictionary *flickrPhoto = [[self flickrPhotos] objectAtIndex:[indexPath item]];
      NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"url_sq"]];
      [downloader downloadImageAtURL:URL completion:completion];
   }

   if ([cell isSelected]) {
      [[cell selectedImageView] setImage:[UIImage imageNamed:@"addphoto.png"]];
   } else {
      [[cell selectedImageView] setImage:nil];
   }
   
   return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   ImageGridViewCell *cell = (ImageGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
   [[cell selectedImageView] setImage:[UIImage imageNamed:@"addphoto.png"]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
   ImageGridViewCell *cell = (ImageGridViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
   [[cell selectedImageView] setImage:nil];
}

@end
