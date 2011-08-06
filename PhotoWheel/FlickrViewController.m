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

@interface FlickrViewController ()
@property (nonatomic, strong) NSArray *flickrPhotos;
@property (nonatomic, strong) NSArray *downloaders;
@end

@implementation FlickrViewController

@synthesize gridView = gridView_;
@synthesize overlayView = overlayView_;
@synthesize searchBar = searchBar_;
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
}

- (void)viewDidUnload
{
   [self setGridView:nil];
   [self setSearchBar:nil];
   [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
   return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
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

- (void)fetchFlickrPhotoWithSearchCriteria:(NSString *)searchCriteria
{
   SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
   NSString *userId = [flickr userIdForUsername:@"Kirby Turner"];
   NSArray *photoSets = [flickr photoSetListWithUserId:userId];
   
   NSString *photoSetId;
   for (NSDictionary *photoSet in photoSets) {
      NSDictionary *titleDict = [photoSet objectForKey:@"title"];
      NSString *titleContent = [titleDict objectForKey:@"_content"];
      if ([titleContent isEqualToString:@"Rowan"]) {
         photoSetId = [photoSet objectForKey:@"id"];
         break;
      }
   }
   
   NSArray *photos = [flickr photosWithPhotoSetId:photoSetId];
   NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
   for (NSInteger index = 0; index < [photos count]; index++) {
      NSDictionary *flickrPhoto = [photos objectAtIndex:index];
      NSString *urlString = [flickrPhoto objectForKey:@"url_sq"];
      NSURL *URL = [NSURL URLWithString:urlString];
      
      ImageDownloader *downloader = [[ImageDownloader alloc] init];
      [downloader setDelegate:self];
      [downloader setURL:URL];
      
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
   [self fetchFlickrPhotoWithSearchCriteria:[searchBar text]];
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
   
   ImageDownloader *downloader = [[self downloaders] objectAtIndex:index];
   UIImage *image = [downloader image];
   [cell setImage:image withShadow:NO];
   
   return cell;
}

- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return CGSizeMake(75, 75);
}

- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index
{
   
}

#pragma mark - ImageDownloaderDelegate Methods

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader
{
   NSInteger index = [[self downloaders] indexOfObject:downloader];
   id cell = [[self gridView] cellAtIndex:index];
   [cell setImage:[downloader image] withShadow:NO];
}

- (void)imageDownloader:(ImageDownloader *)downloader didFailWithError:(NSError *)error
{
   
}


@end
