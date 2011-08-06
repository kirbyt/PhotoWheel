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
@synthesize managedObjectContext = managedObjectContext_;
@synthesize objectID = objectID_;
@synthesize flickrPhotos = flickrPhotos_;
@synthesize downloaders = downloaders_;

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.flickrPhotos = [NSArray array];
}

- (void)viewDidUnload
{
   [self setGridView:nil];
   [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
   [self dismissModalViewControllerAnimated:YES];
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
      NSString *urlString = [flickrPhoto objectForKey:@"url_t"];
      NSURL *URL = [NSURL URLWithString:urlString];
      
      ImageDownloader *downloader = [[ImageDownloader alloc] init];
      [downloader setDelegate:self];
      [downloader setURL:URL];
      
      [downloaders addObject:downloader];
   }
   
   [self setDownloaders:downloaders];
   [self setFlickrPhotos:photos];
   [[self gridView] reloadData];
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
   [searchBar resignFirstResponder];
   [self fetchFlickrPhotoWithSearchCriteria:[searchBar text]];
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
      cell = [ImageGridViewCell imageGridViewCell];
   }
   
   ImageDownloader *downloader = [[self downloaders] objectAtIndex:index];
   UIImage *image = [downloader image];
   [cell setImage:image withShadow:NO];
   
   return cell;
}

- (CGSize)gridViewCellSize:(GridView *)gridView
{
   return [ImageGridViewCell size];
}

- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSInteger)index
{
   
}

#pragma mark - ImageDownloaderDelegate Methods

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader
{
   NSInteger index = [[self downloaders] indexOfObject:downloader];
   [[self gridView] reloadCellAtIndex:index];
}

- (void)imageDownloader:(ImageDownloader *)downloader didFailWithError:(NSError *)error
{
   
}


@end
