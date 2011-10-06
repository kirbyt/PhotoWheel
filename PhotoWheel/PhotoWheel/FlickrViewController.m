//
//  FlickrViewController.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "FlickrViewController.h"                                           // 1
#import "ImageGridViewCell.h"
#import "SimpleFlickrAPI.h"
#import "ImageDownloader.h"
#import "Photo.h"
#import "PhotoAlbum.h"

@interface FlickrViewController ()
@property (nonatomic, strong) NSArray *flickrPhotos;                       // 2
@property (nonatomic, strong) NSMutableArray *downloaders;                 // 3
@property (nonatomic, assign) NSInteger showOverlayCount;                  // 4
@end

@implementation FlickrViewController

@synthesize gridView = _gridView;
@synthesize overlayView = _overlayView;
@synthesize searchBar = _searchBar;
@synthesize activityIndicator = _activityIndicator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize objectID = _objectID;
@synthesize flickrPhotos = _flickrPhotos;
@synthesize downloaders = _downloaders;
@synthesize showOverlayCount = _showOverlayCount;

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.flickrPhotos = [NSArray array];
   [[self overlayView] setAlpha:0.0];                                      // 5
   
   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                  initWithTarget:self 
                                  action:@selector(overlayViewTapped:)];   // 6
   [[self overlayView] addGestureRecognizer:tap];
   
   [[self gridView] setAlwaysBounceVertical:YES];
   [[self gridView] setAllowsMultipleSelection:YES];                       // 7
}

- (void)viewDidUnload
{
   [self setGridView:nil];
   [self setOverlayView:nil];
   [self setSearchBar:nil];
   [self setActivityIndicator:nil];
   [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

- (BOOL)disablesAutomaticKeyboardDismissal                                 // 8
{
   return NO;
}

#pragma mark - Save photos

- (void)saveContextAndExit
{
   NSManagedObjectContext *context = [self managedObjectContext];
   NSError *error = nil;
   if (![context save:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. 
       You should not use this function in a shipping application, although 
       it may be useful during development. If it is not possible to recover 
       from the error, display an alert panel that instructs the user to quit 
       the application by pressing the Home button.
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
   
   NSArray *indexes = [[self gridView] indexesForSelectedCells];
   __block NSInteger count = [indexes count];                              // 9
   
   if (count == 0) {                                                       // 10
      [self dismissModalViewControllerAnimated:YES];
      return;
   }
   
   ImageDownloaderCompletionBlock completion = 
      ^(UIImage *image, NSError *error) {                                  // 11
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
      
      count--;                                                             // 12
      if (count == 0) {
         [self saveContextAndExit];
      }
   };
   
   for (NSNumber *indexNumber in indexes) {                                // 13
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

- (IBAction)save:(id)sender                                                // 14
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
   [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Overlay methods

- (void)showOverlay:(BOOL)showOverlay                                      // 15
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
            // Do other clean if needed.
         }
      };
      
      [UIView animateWithDuration:0.2 animations:animations 
                       completion:completion];
   }
}

- (void)showOverlay                                                        // 16
{
   self.showOverlayCount += 1;
   BOOL showOverlay = (self.showOverlayCount > 0);
   [self showOverlay:showOverlay];
}

- (void)hideOverlay                                                        // 17
{
   self.showOverlayCount -= 1;
   BOOL showOverlay = (self.showOverlayCount > 0);
   [self showOverlay:showOverlay];
   if (self.showOverlayCount < 0) {
      self.showOverlayCount = 0;
   }
}

- (void)overlayViewTapped:(UITapGestureRecognizer *)recognizer             // 18
{
   [self hideOverlay];
   [[self searchBar] resignFirstResponder];
}

#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString:(NSString *)searchString
{
   [[self activityIndicator] startAnimating];                              // 19
   [self showOverlay];
   [[self overlayView] setUserInteractionEnabled:NO];
   
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
      NSArray *photos = [flickr photosWithSearchString:searchString];      // 20
      
      NSMutableArray *downloaders = [[NSMutableArray alloc] 
                                     initWithCapacity:[photos count]];
      for (NSInteger index = 0; index < [photos count]; index++) {
         ImageDownloader *downloader = [[ImageDownloader alloc] init];     // 21
         [downloaders addObject:downloader];
      }
      
      [self setDownloaders:downloaders];                                   // 22
      [self setFlickrPhotos:photos];                                       // 23
      
      dispatch_async(dispatch_get_main_queue(), ^{
         [[self gridView] reloadData];                                     // 24
         [self hideOverlay];
         [[self overlayView] setUserInteractionEnabled:YES];
         [[self searchBar] resignFirstResponder];
         [[self activityIndicator] stopAnimating];
      });
   });
}

#pragma mark - UISearchBarDelegate methods                                 // 25

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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar              // 26
{
   [self fetchFlickrPhotoWithSearchString:[searchBar text]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
   [searchBar resignFirstResponder];
   [self hideOverlay];
}

#pragma mark - GridViewDataSource methods                                  // 27

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
      [[cell selectedIndicator] setImage:
       [UIImage imageNamed:@"addphoto.png"]];                              // 28
   }
   
   ImageDownloaderCompletionBlock completion = 
      ^(UIImage *image, NSError *error) {                                  // 29
      if (image) {
         [[cell imageView] setImage:image];
      } else {
         NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
      }
   };
   
   ImageDownloader *downloader = [[self downloaders] objectAtIndex:index];
   UIImage *image = [downloader image];                                    // 30
   if (image) {
      [[cell imageView] setImage:image];
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
